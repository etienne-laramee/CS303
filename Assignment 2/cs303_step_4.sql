-- Transaction
--      This transaction combines the insertion of a new patient in the DB and creates a new association to an existing owner.
--      It should be treated as a single atomic unit of work because without an owner, there is no way to communicate with a patient
BEGIN TRANSACTION;

INSERT INTO patient (name, species, breed, date_of_birth, weight, weight_unit)
VALUES ('Caramel', 'Cat', 'Big Orange Cat', '2026-05-01', 5.3, 'kg');

INSERT INTO patientOwner (owner_id, patient_id)
VALUES (3, currval(pg_get_serial_sequence('patient', 'patient_id'))); -- Sarah is the new owner of Caramel

COMMIT;

--      Verify transaction worked
SELECT patient.name, owner.name FROM patientOwner
JOIN patient on patient.patient_id = patientOwner.patient_id
JOIN owner ON owner.owner_id = patientOwner.owner_id;
-- Output:
-- name	    name
-- Lupin	Julie Tremblay
-- Lupin	Alex Morin
-- Luna	    Julie Tremblay
-- Milo	    Sarah Chen
-- Garfield	David Roy
-- Daisy	David Roy
-- Caramel	Sarah Chen  -- <- This is our new cat and owner association

-- Rollback
--      We can attempt to do the same thing again, but with an owner that doesn't exist, with id = 999
BEGIN TRANSACTION;

INSERT INTO patient (name, species, breed, date_of_birth, weight, weight_unit)
VALUES ('Macha', 'Cat', 'Big Green Cat', '2026-05-02', 95.3, 'kg');

INSERT INTO patientOwner (owner_id, patient_id)
VALUES (999, currval(pg_get_serial_sequence('patient', 'patient_id'))); -- New owner doesn't exist

COMMIT; -- Should give the following error:
-- Error: Your transaction is currently aborted due to an error. You must explicitly issue a ROLLBACK or ROLLBACK TO SAVEPOINT before executing further commands

ROLLBACK;

--      Verify transaction hasn't worked
SELECT patient.name, owner.name FROM patientOwner
JOIN patient on patient.patient_id = patientOwner.patient_id
JOIN owner ON owner.owner_id = patientOwner.owner_id;