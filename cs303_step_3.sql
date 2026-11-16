-- JOIN queries (at least 3)
--      A query to get the phone number to reach Lupin's owners (INNER JOINS)
SELECT patient.name AS patient_name, owner.name AS owner_name, contactInformation.information AS contact_info
FROM patient 
JOIN patientOwner ON patient.patient_id = patientOwner.patient_id
JOIN owner ON patientOwner.owner_id = owner.owner_id
JOIN ownerContact ON owner.owner_id = ownerContact.owner_id
JOIN contactInformation ON ownerContact.contact_id = contactInformation.contact_id
WHERE patient.name = 'Lupin' AND contactInformation.type = 'Phone';

--      Which treatment did each patient receive on which date, and what was actually charged? (INNER JOIN)
SELECT patient.name AS patient_name, treatment.standard_code as treatment, visit.date, price.price
FROM patient
JOIN visit ON patient.patient_id = visit.patient_id
JOIN treatment ON visit.visit_id = treatment.visit_id
JOIN price ON treatment.treatment_id = price.treatment_id;

--      List of every animal, it's owner(s), and any recorded allergy. Include those without allergies. (LEFT JOIN)
SELECT patient.name, owner.name, allergy.allergy_type, allergy.allergy_details
FROM patient
JOIN patientOwner on patient.patient_id = patientOwner.patient_id
JOIN owner on patientOwner.owner_id = owner.owner_id
LEFT JOIN allergy on patient.patient_id = allergy.patient_id;

-- Aggregate queries (at least 2)
--      Total amount charged by each clinic
SELECT clinic.clinic_id, clinic.address, SUM(price.price) AS "Total sales"
FROM clinic
JOIN visit ON clinic.clinic_id = visit.clinic_id
JOIN treatment ON treatment.visit_id = visit.visit_id
JOIN price on treatment.treatment_id = price.treatment_id
GROUP BY clinic.clinic_id;

--      List animals that had more than one visit
SELECT patient.name, COUNT(visit.visit_id) AS "Number of visits"
FROM patient
JOIN visit ON patient.patient_id = visit.patient_id
GROUP BY patient.patient_id;

-- Subquery
--      Which treatments cost more than the average treatment actual price?
SELECT treatment.standard_code, price.price AS actual_cost, ROUND((SELECT AVG(price.price) FROM price), 2) AS average_cost
FROM treatment
JOIN price ON treatment.treatment_id = price.treatment_id
WHERE price.price > (
    SELECT AVG(price.price) FROM price
)
GROUP BY treatment.standard_code, price.price;

-- View
--      Let the staff see prescriptions and remaining refills and patient information
CREATE VIEW prescription_view AS
SELECT patient.*, prescription.medication_name, prescription.frequency, prescription.duration, prescription.is_refillable, prescription.total_refills, prescription.used_refills
FROM patient
JOIN visit ON patient.patient_id = visit.patient_id
JOIN prescription ON visit.visit_id = prescription.visit_id
ORDER BY patient.patient_id;

--      Verify the view works
SELECT * FROM prescription_view;

-- Stored Proc x1
--      Safely add a prescription refill. Only allows an update if the prescription is refillable and used_refills is lesser than total_refills.
CREATE OR REPLACE PROCEDURE record_refill(p_prescription_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE prescription
    SET used_refills = used_refills + 1
    WHERE prescription_id = p_prescription_id
        AND is_refillable IS TRUE
        AND used_refills < total_refills;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Prescription % does not exist or has no more available refills, or does not allow refills.', p_prescription_id;
    END IF;
END;
$$;

--      First let's look at the current prescription values for Lupin's first visit (visit_id = 7)
SELECT patient.name, prescription.prescription_id, prescription.medication_name, prescription.is_refillable, prescription.total_refills, prescription.used_refills
FROM prescription
JOIN visit ON visit.visit_id = prescription.visit_id
JOIN patient ON patient.patient_id = visit.patient_id
WHERE visit.visit_id = 5;

--      First let's look at the current prescription values for Lupin's second visit (visit_id = 5)
SELECT patient.name, prescription.prescription_id, prescription.medication_name, prescription.is_refillable, prescription.total_refills, prescription.used_refills
FROM prescription
JOIN visit ON visit.visit_id = prescription.visit_id
JOIN patient ON patient.patient_id = visit.patient_id
WHERE visit.visit_id = 7;

--      To test, call record_refill(<some number>);
--      Lupin's first visit prescription, not refillable
CALL record_refill(2);

--      Lupin's second visit prescription, refillable
CALL record_refill(3);

-- Trigger x1
--      When a treatment is recorded, automatically create a price record for it with the price equal to base_price as default. Can be modified later by staff for special price or something
--      First, create the triggered function:
CREATE OR REPLACE FUNCTION create_price_after_treatment_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO price (treatment_id, price)
    VALUES (NEW.treatment_id, NEW.base_price);

    RETURN NEW;
END;
$$;

--      Then create the trigger and reference the previously created function
CREATE TRIGGER create_price_after_treatment
AFTER INSERT ON treatment
FOR EACH ROW
EXECUTE FUNCTION create_price_after_treatment_function();

--      Check the current price list. Should have 10 items.
SELECT * FROM price;

--      Insert a new treatment. Should trigger the trigger after insertion, thus creating a new price in the price table.
INSERT INTO treatment (visit_id, standard_code, base_price)
VALUES (1, 'Chamomille Calming Treatment', 5);

--      We should now have 11 prices with the last one being $5.
SELECT * FROM price;