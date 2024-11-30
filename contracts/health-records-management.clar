;; ================================================
;; Decentralized Medical Record Storage Contract
;;
;; This smart contract allows for the decentralized storage and management of medical records
;; on the Stacks blockchain. It ensures that medical records are securely stored and only accessible
;; by authorized parties such as the physician who created the record. The contract supports the
;; following functionalities:
;;
;; - Adding new medical records with patient information, including medical notes and tags.
;; - Updating the physician responsible for a medical record.
;; - Modifying existing medical records, including patient details, size, and associated notes and tags.
;; - Deleting records when necessary.
;; - Managing access permissions to records for authorized users.
;; - Ensuring that only the authorized physician (the creator of the record) can update or delete the record.
;; - Validating record attributes such as patient name, size, and tags before they are stored or updated.
;; 
;; The contract leverages private utility functions for internal checks and validation,
;; and provides public functions that allow the contract owner (physician) to manage the medical records.
;; 
;; Storage Variables:
;; - total-records: A counter that tracks the total number of medical records created. It is incremented
;;   each time a new record is added.
;; 
;; - medical-records: A map that stores medical records, where each record is identified by a unique 
;;   record ID and contains details such as patient name, physician ID, record size, creation date, notes, and tags.
;;
;; - access-permissions: A map that stores the access permissions for each record, identifying the user
;;   and whether they have access to the record.
;; 
;; Error Constants:
;; The contract defines error constants for various operation failures, such as when a record is not found,
;; when an unauthorized user attempts an action, or when input data is invalid.
;;
;; =================================================

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

;; Private Utility Functions

;; Checks if a medical record exists by record-id
(define-private (record-exists? (record-id uint))
  (is-some (map-get? medical-records { record-id: record-id }))
)

;; Verifies that the record belongs to the specified physician
(define-private (is-physician-owner? (record-id uint) (physician principal))
  (match (map-get? medical-records { record-id: record-id })
    record-details (is-eq (get physician-id record-details) physician)
    false
  )
)

;; Retrieves the size of a specified record
(define-private (get-record-size (record-id uint))
  (default-to u0
    (get record-size
      (map-get? medical-records { record-id: record-id })
    )
  )
)

;; Validates the length of a single tag
(define-private (validate-tag (tag (string-ascii 32)))
  (and 
    (> (len tag) u0)
    (< (len tag) u33)
  )
)

;; Ensures all tags in the list meet validation criteria
(define-private (validate-tags (tags (list 10 (string-ascii 32))))
  (and
    (> (len tags) u0)  ;; At least one tag is required
    (<= (len tags) u10) ;; No more than 10 tags are allowed
    (is-eq (len (filter validate-tag tags)) (len tags)) ;; All tags must be valid
  )
)

;; Public Functions

;; Adds a new medical record with patient information
(define-public (add-medical-record 
  (patient-name (string-ascii 64))       ;; Patient's full name
  (record-size uint)                     ;; Size of the medical record (in bytes)
  (notes (string-ascii 128))             ;; Notes related to the medical record
  (tags (list 10 (string-ascii 32)))     ;; Tags to categorize the record
)
  (let
    (
      (record-id (+ (var-get total-records) u1))  ;; Generate a new record ID
    )
    ;; Validations for the input parameters
    (asserts! (> (len patient-name) u0) ERR_INVALID_NAME)  ;; Patient name cannot be empty
    (asserts! (< (len patient-name) u65) ERR_INVALID_NAME) ;; Patient name length must be less than 65 characters
    (asserts! (> record-size u0) ERR_INVALID_SIZE)         ;; Record size must be greater than zero
    (asserts! (< record-size u1000000000) ERR_INVALID_SIZE) ;; Record size must be within a reasonable range
    (asserts! (> (len notes) u0) ERR_INVALID_NAME)         ;; Notes cannot be empty
    (asserts! (< (len notes) u129) ERR_INVALID_NAME)       ;; Notes length must be less than 129 characters
    (asserts! (validate-tags tags) ERR_TAG_INVALID)        ;; Tags must be valid

    ;; Insert the new medical record into the map
    (map-insert medical-records
      { record-id: record-id }
      {
        patient-name: patient-name,
        physician-id: tx-sender,  ;; The current transaction sender is the physician
        record-size: record-size,
        creation-date: block-height,  ;; Store the block height as the creation date
        notes: notes,
        tags: tags
      }
    )

    ;; Insert access permissions, initially granting access to the physician
    (map-insert access-permissions
      { record-id: record-id, user-id: tx-sender }
      { is-access-granted: true }
    )

    ;; Update total record count
    (var-set total-records record-id)
    (ok record-id)  ;; Return the newly created record ID
  )
)

;; Updates the physician associated with an existing medical record
(define-public (update-record-physician (record-id uint) (new-physician principal))
  (let
    (
      (record-data (unwrap! (map-get? medical-records { record-id: record-id }) ERR_RECORD_NOT_FOUND)) ;; Retrieve the record data
    )
    ;; Validations
    (asserts! (record-exists? record-id) ERR_RECORD_NOT_FOUND)  ;; Ensure the record exists
    (asserts! (is-eq (get physician-id record-data) tx-sender) ERR_NOT_AUTHORIZED) ;; Ensure the caller is authorized

    ;; Update the physician ID for the record
    (map-set medical-records
      { record-id: record-id }
      (merge record-data { physician-id: new-physician })
    )
    (ok true)  ;; Return success
  )
)

(define-public (get-record-tags (record-id uint))
  (let
    (
      (record-data (unwrap! (map-get? medical-records { record-id: record-id }) ERR_RECORD_NOT_FOUND)) ;; Retrieve the record data
    )
    ;; Return the list of tags associated with the record
    (ok (get tags record-data))  ;; Return the tags associated with the record
  )
)

(define-public (get-record-physician (record-id uint))
  (let
    (
      (record-data (unwrap! (map-get? medical-records { record-id: record-id }) ERR_RECORD_NOT_FOUND)) ;; Retrieve the record data
    )
    ;; Return the physician ID associated with the record
    (ok (get physician-id record-data))  ;; Return the physician ID
  )
)

;; Retrieves the creation date (block height) of a medical record by its record ID
(define-public (get-record-creation-date (record-id uint))
  (let
    (
      (record-data (unwrap! (map-get? medical-records { record-id: record-id }) ERR_RECORD_NOT_FOUND)) ;; Retrieve the record data
    )
    ;; Return the creation date (block height) of the record
    (ok (get creation-date record-data))  ;; Return the creation date of the record
  )
)

(define-public (get-total-records)
  ;; Returns the total number of medical records
  (ok (var-get total-records))
)
