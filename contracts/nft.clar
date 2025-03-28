;; ChainCanvas NFT Contract
;; Implements an NFT with compatible trait

(define-constant CONTRACT-OWNER tx-sender)

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

;; Track the last minted token ID
(define-data-var last-token-id uint u0)

;; Trait Definition (inline to match marketplace)
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

;; Mint a new NFT
(define-public (mint (recipient principal) (token-uri (string-ascii 256)))
  (let 
    (
      (new-token-id (+ (var-get last-token-id) u1))
    )
    (begin
      ;; Ensure only contract owner can mint
      (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u1))
      
      ;; Update last token ID
      (var-set last-token-id new-token-id)
      
      ;; Set token ownership
      (map-set token-ownership new-token-id recipient)
      
      ;; Set token URI
      (map-set token-uris new-token-id token-uri)
      
      (ok new-token-id)
    )
  )
)

;; Transfer an NFT
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; Ensure sender is the current owner
    (asserts! (is-eq (unwrap! (get-owner token-id) (err u1)) sender) (err u2))
    
    ;; Update token ownership
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