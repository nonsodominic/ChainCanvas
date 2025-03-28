;;CHAINCANVAS - NFT Marketplace Smart Contract

;; Errors
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-LISTING-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-LISTED (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-TRANSFER-FAILED (err u104))

;; Data Maps
(define-map marketplace-listings 
  {token-id: uint} 
  {
    seller: principal,
    price: uint,
    is-active: bool
  }
)

;; NFT Trait
(use-trait nft-trait .nft-trait.nft-trait)

;; List an NFT for sale
(define-public (list-nft 
  (nft-contract <nft-trait>) 
  (token-id uint) 
  (price uint)
)
  (begin
    ;; Ensure sender owns the NFT
    (asserts! (is-eq (contract-call? nft-contract get-owner token-id) (some tx-sender)) ERR-NOT-OWNER)
    
    ;; Check if already listed
    (asserts! (is-none (map-get? marketplace-listings {token-id: token-id})) ERR-ALREADY-LISTED)
    
    ;; Transfer NFT to marketplace contract
    (try! (contract-call? nft-contract transfer token-id tx-sender (as-contract tx-sender)))
    
    ;; Create listing
    (map-set marketplace-listings 
      {token-id: token-id} 
      {
        seller: tx-sender,
        price: price,
        is-active: true
      }
    )
    
    (ok true)
  )
)

;; Buy an NFT
(define-public (buy-nft 
  (nft-contract <nft-trait>) 
  (token-id uint)
)
  (let 
    (
      (listing (unwrap! (map-get? marketplace-listings {token-id: token-id}) ERR-LISTING-NOT-FOUND))
      (seller (get seller listing))
      (price (get price listing))
    )
    
    ;; Verify listing is active
    (asserts! (get is-active listing) ERR-LISTING-NOT-FOUND)
    
    ;; Check buyer has sufficient funds
    (asserts! (>= (stx-get-balance tx-sender) price) ERR-INSUFFICIENT-FUNDS)
    
    ;; Transfer payment to seller
    (try! (stx-transfer? price tx-sender seller))
    
    ;; Transfer NFT to buyer
    (as-contract 
      (contract-call? nft-contract transfer token-id (as-contract tx-sender) tx-sender)
    )
    
    ;; Update or remove listing
    (map-set marketplace-listings 
      {token-id: token-id} 
      {
        seller: seller,
        price: price,
        is-active: false
      }
    )
    
    (ok true)
  )
)

;; Cancel listing
(define-public (cancel-listing 
  (nft-contract <nft-trait>) 
  (token-id uint)
)
  (let 
    (
      (listing (unwrap! (map-get? marketplace-listings {token-id: token-id}) ERR-LISTING-NOT-FOUND))
    )
    
    ;; Ensure only seller can cancel
    (asserts! (is-eq tx-sender (get seller listing)) ERR-NOT-OWNER)
    
    ;; Transfer NFT back to seller
    (as-contract 
      (contract-call? nft-contract transfer token-id (as-contract tx-sender) tx-sender)
    )
    
    ;; Remove listing
    (map-delete marketplace-listings {token-id: token-id})
    
    (ok true)
  )
)

;; Get listing details
(define-read-only (get-listing (token-id uint))
  (map-get? marketplace-listings {token-id: token-id})
)