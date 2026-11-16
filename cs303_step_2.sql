INSERT INTO clinic (address, phone_number, operating_hours)
VALUES
    ('125 Main Street, Sherbrooke, QC', '819-555-0101', 'Monday-Friday 08:00-18:00'),
    ('480 Saint-Joseph Street, Montreal, QC', '819-555-0102', 'Monday-Saturday 09:00-17:00');

INSERT INTO veterinarian (name, license_number, primary_clinic_id, specialization)
VALUES
    ('Amélie Roy', 'VET-1001', 1, 'General practice'),
    ('Marc Gagnon', 'VET-1002', 1, 'Dentistry'),
    ('Sophie Nguyen', 'VET-1003', 2, NULL);

INSERT INTO owner (name)
VALUES
    ('Julie Tremblay'),
    ('Alex Morin'),
    ('Sarah Chen'),
    ('David Roy');

INSERT INTO contactInformation (type, information)
VALUES
    ('Email', 'amelie.roy@pawpoint.example'), -- Amelie Roy
    ('Email', 'marc.gagnon@pawpoint.example'), -- Marc Gagnon
    ('Email', 'sophie.nguyen@pawpoint.example'), -- Sophie Nguyen
    ('Email', 'julie.tremblay@example.com'), -- Julie Tremblay
    ('Phone', '819-555-0121'), -- Julie Tremblay
    ('Email', 'alex.morin@example.com'), -- Alex Morin
    ('Phone', '819-555-0122'), -- Alex Morin
    ('Email', 'sarah.chen@example.com'), -- Sarah Chen
    ('Email', 'david.roy@example.com'), -- David Roy
    ('Phone', '819-555-0124'); -- David Roy

INSERT INTO veterinarianContact (veterinarian_id, contact_id)
VALUES
    (1, 1), -- Amélie Roy's email
    (2, 2), -- Marc Gagnon's email
    (3, 3); -- Sophie Nguyen's email


INSERT INTO ownerContact (owner_id, contact_id)
VALUES
    (1, 4), -- Julie Tremblay's email
    (1, 5), -- Julie Tremblay's phone
    (2, 6), -- Alex Morin's email
    (2, 7), -- Alex Morin's phone
    (3, 8), -- Sarah Chen's email
    (4, 9), -- David Roy's email
    (4, 10); -- David Roy's phone

INSERT INTO patient (name, species, breed, date_of_birth, weight)
VALUES
    ('Lupin', 'Dog', 'Long Haired Dachshund', '2020-03-26', 21.50),
    ('Luna', 'Cat', 'Domestic Shorthair', '2021-08-03', 4.20),
    ('Milo', 'Dog', 'Long Haired Dachshund', '2023-02-17', 26.80),
    ('Garfield', 'Cat', 'Maine Coon', '2022-06-25', 6.10),
    ('Daisy', 'Dog', 'Golden Retriever', '2024-03-10', 23.40);

INSERT INTO patientOwner (owner_id, patient_id)
VALUES
    (1, 1), -- Lupin -> Julie
    (2, 1), -- Lupin -> Alex
    (1, 2), -- Luna -> Julie
    (3, 3), -- Milo -> Sarah
    (4, 4), -- Garfield -> David
    (4, 5); -- Daisy -> David


INSERT INTO allergy (patient_id, allergy_type, allergy_details)
VALUES
    (1, 'Pollen', 'Seasonal pollen sensitivity.'),
    (3, 'Chicken allergy', 'Chicken sensitivity identified through an elimination diet.'),
    (3, 'Dust Mites', 'Dust mite sensitivity.');

INSERT INTO visit (clinic_id, veterinarian_id, patient_id, date, time, reason, diagnosis)
VALUES
    (1, 1, 1, '2026-09-03', '09:00', 'Annual wellness examination', 'Healthy adult dog'),
    (1, 1, 2, '2026-09-03', '10:00', 'Annual examination and vaccination', 'Healthy adult cat'),
    (2, 3, 3, '2026-09-08', '11:00', 'Persistent itching', 'Allergic dermatitis'),
    (1, 2, 4, '2026-09-12', '09:00', 'Dental assessment and cleaning', 'Gingivitis with dental calculus'),
    (2, 3, 1, '2026-10-02', '14:00', 'Seasonal itching', 'Seasonal allergic dermatitis'),
    (2, 3, 3, '2026-10-08', '11:00', 'Dermatitis follow-up', 'Improved; continue maintenance treatment'),
    (1, 1, 1, '2026-10-15', '15:30', 'Right ear discomfort', 'Right-sided otitis externa'),
    (2, 3, 5, '2026-11-20', '10:30', 'Canceled wellness appointment', NULL);

INSERT INTO prescription (visit_id, medication_name, dosage, frequency, duration, date_prescribed, is_refillable, total_refills, used_refills)
VALUES
    (3, 'Rash meds', '50mg', 'Twice daily', '4 weeks', '2026-09-08', TRUE, 4, 1),
    (5, 'Antibiotic', '25mg', 'Once daily', '2 weeks', '2026-10-02', FALSE, 0, 0),
    (7, 'Anti-inflammatory', '150mg', 'Up to 4 times daily', '4 weeks', '2026-10-15', TRUE, 6, 0);

INSERT INTO treatment (visit_id, standard_code, base_price)
VALUES
    (1, 'EXAM-GENERAL', 80.00),
    (2, 'EXAM-GENERAL', 80.00),
    (2, 'VACCINE-FELINE', 45.00),
    (3, 'CONSULT-DERM', 110.00),
    (4, 'EXAM-GENERAL', 80.00),
    (4, 'DENTAL-CLEAN', 350.00),
    (5, 'CONSULT-DERM', 110.00),
    (6, 'FOLLOWUP-DERM', 65.00),
    (7, 'EXAM-GENERAL', 80.00),
    (7, 'EAR-CYTOLOGY', 40.00);

INSERT INTO price (treatment_id, price)
VALUES
    (1, 80.00),
    (2, 75.00),
    (3, 45.00),
    (4, 110.00),
    (5, 80.00),
    (6, 350.00),
    (7, 100.00),
    (8, 60.00),
    (9, 85.00),
    (10, 40.00);

BEGIN;

-- Update Lupin's weight to 25 lbs
UPDATE patient
SET weight = 25
WHERE name = 'Lupin'
RETURNING name, breed, weight, weight_unit;
-- Output:
--  name  |         breed         | weight | weight_unit
-- -------+-----------------------+--------+-------------
--  Lupin | Long Haired Dachshund |  25.00 | lbs


-- Attempt to remove Lupin's first appointment.
-- A treatment references this visit, deletion is not allowed.
DELETE FROM visit
WHERE reason = 'Canceled wellness appointment'
RETURNING visit_id, patient_id, date, reason;
-- Output:
-- ERROR:  update or delete on table "visit" violates RESTRICT setting of foreign key constraint "treatment_visit_id_fkey" on table "treatment"
-- DETAIL:  Key (visit_id)=(1) is referenced from table "treatment".

-- Remove Daisy's canceled appointment.
-- No treatments or prescriptions reference this visit, deletion is allowed.
DELETE FROM visit
WHERE reason = 'Canceled wellness appointment'
RETURNING visit_id, patient_id, date, reason;
-- Output:
--  visit_id | patient_id |    date    |            reason
-- ----------+------------+------------+-------------------------------
--         8 |          5 | 2026-11-20 | Canceled wellness appointment

COMMIT;