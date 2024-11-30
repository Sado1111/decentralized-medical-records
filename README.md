# Decentralized Medical Record Storage Smart Contract

## Overview

This smart contract allows for the **decentralized storage** and management of **medical records** on the **Stacks blockchain**. It ensures that medical records are securely stored and can only be accessed by authorized parties such as the physician who created the record. The contract provides functionalities to add, update, modify, and delete medical records, and also supports managing access permissions.

### Key Features

- **Add new medical records** with patient details, medical notes, and tags.
- **Update physician** associated with a medical record.
- **Modify existing medical records**, including patient information, size, notes, and tags.
- **Delete records** when necessary.
- **Manage access permissions** for authorized users.
- Ensures that only the **authorized physician** (creator of the record) can update or delete the record.
- **Validates** record attributes such as patient name, size, and tags before storage or updates.

## Storage Variables

The contract uses the following storage variables:

1. **total-records**: A counter that tracks the total number of medical records created. It is incremented each time a new record is added.
2. **medical-records**: A map that stores medical records, where each record is identified by a unique record ID and contains details such as:
   - Patient name
   - Physician ID (creator)
   - Record size
   - Creation date
   - Notes
   - Tags
3. **access-permissions**: A map that stores the access permissions for each record, indicating whether a user has access to the record.

## Error Codes

The contract defines several error constants to handle common failures during contract operations:
- **ERR_RECORD_NOT_FOUND**: Record not found.
- **ERR_RECORD_EXISTS**: A record already exists.
- **ERR_INVALID_NAME**: Invalid name provided.
- **ERR_INVALID_SIZE**: Invalid record size.
- **ERR_NOT_AUTHORIZED**: Unauthorized access.
- **ERR_INVALID_PHYSICIAN**: Invalid physician specified.
- **ERR_OWNER_ONLY**: Only the record owner (physician) can modify the record.
- **ERR_TAG_INVALID**: Invalid tag format.
- **ERR_PERMISSION_DENIED**: Permission denied for accessing the record.

## Private Utility Functions

### 1. `record-exists?`
Checks if a medical record exists by its record ID.

### 2. `is-physician-owner?`
Verifies that the specified physician is the owner of the record.

### 3. `get-record-size`
Retrieves the size of a medical record by its record ID.

### 4. `validate-tag`
Validates the length of an individual tag.

### 5. `validate-tags`
Ensures that all tags in the list meet the validation criteria (at least one tag, no more than 10 tags, and all tags must be valid).

## Public Functions

### 1. `add-medical-record`
Adds a new medical record. The function requires:
- **patient-name**: Name of the patient.
- **record-size**: Size of the medical record in bytes.
- **notes**: Medical notes related to the record.
- **tags**: Tags associated with the record for categorization.

### 2. `update-record-physician`
Updates the physician responsible for an existing medical record.

### 3. `get-record-tags`
Retrieves the list of tags associated with a medical record.

### 4. `get-record-physician`
Returns the physician ID associated with a medical record.

### 5. `get-record-creation-date`
Retrieves the creation date (block height) of a medical record by its record ID.

### 6. `get-total-records`
Returns the total number of medical records created.

### 7. `get-record-size-by-id`
Retrieves the size of a medical record by its record ID.

### 8. `get-record-notes`
Returns the medical notes associated with a record.

### 9. `check-user-access`
Checks whether a user has access to a specific medical record.

### 10. `update-medical-record`
Modifies an existing medical record. The function allows updating:
- **new-patient-name**: The updated name of the patient.
- **new-size**: New size of the record.
- **new-notes**: New medical notes.
- **new-tags**: New tags for the record.

## Deployment and Usage

### Contract Deployment
Deploy the contract on the Stacks blockchain by uploading the contract to your Stacks network. Ensure the contract is associated with the correct contract owner (the deploying physician).

### Adding a New Record
To add a new record, call the `add-medical-record` function with the appropriate parameters. The record ID will be returned, which can be used for further interactions with the record.

### Updating an Existing Record
Only the original physician (owner) can update or modify a record. To update a record, use the `update-medical-record` function with the record ID and the new details.

### Access Control
Users can check if they have access to a record using the `check-user-access` function, providing the record ID and user principal.

## Security Considerations

The contract ensures that:
- Only the creator (physician) of a record can update or delete the record.
- Medical records are encrypted and stored securely.
- Tags are validated before being associated with a record to avoid malicious input.

## Contributing

Contributions are welcome! Feel free to fork the repository and submit issues or pull requests. Make sure to follow the guidelines for contributing and include tests where appropriate.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

