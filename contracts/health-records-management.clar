;; ================================================
;; Decentralized Medical Record Storage Contract
;;
;; This smart contract allows for the decentralized storage and management of medical records
;; on the Stacks blockchain. It ensures that medical records are securely stored and only accessible
;; by authorized parties such as the physician who created the record. =================================================

;; Storage Variables
(define-data-var total-records uint u0) ;; Tracks the total number of medical records

;; Maps to Store Medical Records and Access Permissions
(define-map medical-records
  { record-id: uint }
  {
    patient-name: (string-ascii 64),  ;; Name of the patient
    physician-id: principal,          ;; ID of the physician (owner)
    record-size: uint,                ;; Size of the medical record
    creation-date: uint,              ;; Block height at which the record was created
    notes: (string-ascii 128),        ;; Notes related to the medical record
    tags: (list 10 (string-ascii 32)) ;; Tags associated with the record
  }
)

(define-map access-permissions
  { record-id: uint, user-id: principal }
  { is-access-granted: bool } ;; Whether a user has access to a specific record
)

;; Error Codes for Various Contract Operations
(define-constant ERR_RECORD_NOT_FOUND (err u301))      ;; Error for record not found
(define-constant ERR_RECORD_EXISTS (err u302))         ;; Error when a record already exists
(define-constant ERR_INVALID_NAME (err u303))          ;; Invalid name error
(define-constant ERR_INVALID_SIZE (err u304))          ;; Invalid size error
(define-constant ERR_NOT_AUTHORIZED (err u305))        ;; Not authorized error
(define-constant ERR_INVALID_PHYSICIAN (err u306))     ;; Invalid physician error
(define-constant ERR_OWNER_ONLY (err u300))            ;; Only the owner can modify error
(define-constant ERR_TAG_INVALID (err u307))           ;; Invalid tag error
(define-constant ERR_PERMISSION_DENIED (err u308))     ;; Permission denied error

;; Contract Owner Constant
(define-constant contract-owner tx-sender) ;; The address of the contract owner (deployer)
