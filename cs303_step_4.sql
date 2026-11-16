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
--    name   |      name
-- ----------+----------------
--  Lupin    | Julie Tremblay
--  Lupin    | Alex Morin
--  Luna     | Julie Tremblay
--  Milo     | Sarah Chen
--  Garfield | David Roy
--  Daisy    | David Roy
--  Caramel  | Sarah Chen  <- This is our new cat and owner association
-- (7 rows)

-- Rollback
--      We can attempt to do the same thing again, but with an owner that doesn't exist, with id = 999
BEGIN TRANSACTION;

INSERT INTO patient (name, species, breed, date_of_birth, weight, weight_unit)
VALUES ('Macha', 'Cat', 'Big Green Cat', '2026-05-02', 95.3, 'kg');

INSERT INTO patientOwner (owner_id, patient_id)
VALUES (999, currval(pg_get_serial_sequence('patient', 'patient_id'))); -- New owner doesn't exist

COMMIT; -- Should give the following error:
-- BEGIN
-- INSERT 0 1
-- ERROR:  insert or update on table "patientOwner" violates foreign key constraint "patientowner_owner_id_fkey"
-- DETAIL:  Key (owner_id)=(999) is not present in table "owner".

ROLLBACK;

SELECT * FROM patient;
-- Output shows that the new patient Macha has not been added to the patient table:
--  patient_id |   name   | species |         breed         | date_of_birth | weight | weight_unit
-- ------------+----------+---------+-----------------------+---------------+--------+-------------
--           2 | Luna     | Cat     | Domestic Shorthair    | 2021-08-03    |   4.20 | lbs
--           3 | Milo     | Dog     | Long Haired Dachshund | 2023-02-17    |  26.80 | lbs
--           4 | Garfield | Cat     | Maine Coon            | 2022-06-25    |   6.10 | lbs
--           5 | Daisy    | Dog     | Golden Retriever      | 2024-03-10    |  23.40 | lbs
--           1 | Lupin    | Dog     | Long Haired Dachshund | 2020-03-26    |  25.00 | lbs
--           9 | Caramel  | Cat     | Big Orange Cat        | 2026-05-01    |   5.30 | kg
-- (6 rows)

--      Verify transaction hasn't worked
SELECT patient.name, owner.name FROM patientOwner
JOIN patient on patient.patient_id = patientOwner.patient_id
JOIN owner ON owner.owner_id = patientOwner.owner_id;
-- Output
--    name   |      name
-- ----------+----------------
--  Lupin    | Julie Tremblay
--  Lupin    | Alex Morin
--  Luna     | Julie Tremblay
--  Milo     | Sarah Chen
--  Garfield | David Roy
--  Daisy    | David Roy
--  Caramel  | Sarah Chen
-- (7 rows)  <- No new patient/owner association