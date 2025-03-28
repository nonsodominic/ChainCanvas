;; ChainCanvas NFT Contract
;; Advanced NFT implementation with extended features

(define-constant CONTRACT-OWNER tx-sender)

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-RECIPIENT (err u2))
(define-constant ERR-TOKEN-NOT-FOUND (err u3))
(define-constant ERR-ALREADY-BURNED (err u4))
(define-constant ERR-INVALID-ROYALTY (err u5))

;; Storage for token ownership
(define-map token-ownership 
  uint 
  principal
)

;; Storage for token URIs
(define-map token-uris 
  uint 
  (string-ascii 256)
)

;; Royalty storage
(define-map token-royalties
  uint
  {
    receiver: principal,
    percentage: uint
  }
)

;; Burned token tracking
(define-map burned-tokens
  uint
  bool
)

;; Track the last minted token ID
(define-data-var last-token-id uint u0)

;; Trait Definition
(define-trait nft-trait
  (
    ;; Transfer an NFT
    (transfer (uint principal principal) (response bool uint))
    
    ;; Get the owner of a specific token
    (get-owner (uint) (response (optional principal) uint))
    
    ;; Get the last token ID (total supply)
    (get-last-token-id () (response uint uint))
    
    ;; Get the URI for a specific token
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
  )
)

;; Validate recipient address
(define-private (is-valid-recipient (recipient principal))
  (and 
    (not (is-eq recipient tx-sender))  ;; Prevent self-transfer
    (not (is-eq recipient CONTRACT-OWNER))  ;; Prevent transfer to contract owner
    true
  )
)

;; Mint a new NFT with Royalty
(define-public (mint-with-royalty 
  (recipient principal) 
  (token-uri (string-ascii 256)) 
  (royalty-receiver principal)
  (royalty-percentage uint)
)
  (begin
    ;; Ensure only contract owner can mint
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    ;; Validate recipient
    (asserts! (is-valid-recipient recipient) ERR-INVALID-RECIPIENT)
    
    ;; Validate token URI is not empty
    (asserts! (> (len token-uri) u0) ERR-INVALID-RECIPIENT)
    
    ;; Validate royalty percentage (0-50%)
    (asserts! (and (>= royalty-percentage u0) (<= royalty-percentage u50)) ERR-INVALID-ROYALTY)
    
    ;; Increment and get new token ID
    (let 
      (
        (new-token-id (+ (var-get last-token-id) u1))
      )
      (begin
        ;; Update last token ID
        (var-set last-token-id new-token-id)
        
        ;; Set token ownership with validation
        (map-set token-ownership new-token-id recipient)
        
        ;; Set token URI with validation
        (map-set token-uris new-token-id token-uri)
        
        ;; Set royalty information
        (map-set token-royalties new-token-id {
          receiver: royalty-receiver,
          percentage: royalty-percentage
        })
        
        (ok new-token-id)
      )
    )
  )
)

;; Burn an NFT
(define-public (burn-nft (token-id uint))
  (begin
    ;; Ensure token exists
    (asserts! 
      (is-some (map-get? token-ownership token-id)) 
      ERR-TOKEN-NOT-FOUND
    )
    
    ;; Ensure token is not already burned
    (asserts! 
      (is-none (map-get? burned-tokens token-id)) 
      ERR-ALREADY-BURNED
    )
    
    ;; Ensure sender is the owner
    (asserts! 
      (is-eq 
        (unwrap! (get-owner token-id) ERR-TOKEN-NOT-FOUND) 
        tx-sender
      ) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Mark token as burned
    (map-set burned-tokens token-id true)
    
    ;; Remove ownership
    (map-delete token-ownership token-id)
    
    (ok true)
  )
)

;; Get Royalty Information
(define-read-only (get-royalty-info (token-id uint))
  (map-get? token-royalties token-id)
)

;; Transfer an NFT
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; Validate recipient
    (asserts! (is-valid-recipient recipient) ERR-INVALID-RECIPIENT)
    
    ;; Ensure token exists and not burned
    (asserts! 
      (is-some (map-get? token-ownership token-id)) 
      ERR-TOKEN-NOT-FOUND
    )
    
    ;; Ensure token is not burned
    (asserts! 
      (is-none (map-get? burned-tokens token-id)) 
      ERR-ALREADY-BURNED
    )
    
    ;; Ensure sender is the current owner
    (asserts! 
      (is-eq 
        (unwrap! (get-owner token-id) ERR-TOKEN-NOT-FOUND) 
        sender
      ) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Update token ownership with validation
    (map-set token-ownership token-id recipient)
    
    (ok true)
  )
)

;; Get the owner of a specific token
(define-read-only (get-owner (token-id uint))
  (map-get? token-ownership token-id)
)

;; Get the last token ID (total supply)
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; Get the URI for a specific token
(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? token-uris token-id))
)