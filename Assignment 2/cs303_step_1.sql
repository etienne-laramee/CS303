CREATE TABLE clinic (
    clinic_id SERIAL PRIMARY KEY,
    address VARCHAR NOT NULL,
    phone_number VARCHAR NOT NULL,
    operating_hours VARCHAR NOT NULL
);

CREATE TABLE veterinarian (
    veterinarian_id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    license_number VARCHAR NOT NULL UNIQUE,
    primary_clinic_id INTEGER NOT NULL REFERENCES Clinic (clinic_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    specialization VARCHAR
);

CREATE TABLE contactInformation (
    contact_id SERIAL PRIMARY KEY,
    type VARCHAR NOT NULL,
    information VARCHAR NOT NULL
);

CREATE TABLE owner (
    owner_id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

CREATE TABLE veterinarianContact (
    veterinarian_id INTEGER NOT NULL REFERENCES Veterinarian (veterinarian_id) ON DELETE CASCADE ON UPDATE CASCADE,
    contact_id INTEGER NOT NULL REFERENCES ContactInformation (contact_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (veterinarian_id, contact_id)
);

CREATE TABLE ownerContact (
    owner_id INTEGER NOT NULL REFERENCES Owner (owner_id) ON DELETE CASCADE ON UPDATE CASCADE,
    contact_id INTEGER NOT NULL REFERENCES ContactInformation (contact_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (owner_id, contact_id)
);

CREATE TABLE patient (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    species VARCHAR NOT NULL,
    breed VARCHAR NOT NULL,
    date_of_birth DATE NOT NULL,
    weight DECIMAL(6,2) NOT NULL CHECK (weight > 0), -- No negative weight
    weight_unit VARCHAR NOT NULL DEFAULT 'lbs' CHECK (weight_unit IN ('kg', 'lbs')) -- Allow kg or lbs, default to lbs
);

CREATE TABLE patientOwner (
    owner_id INTEGER NOT NULL REFERENCES Owner (owner_id) ON DELETE CASCADE ON UPDATE CASCADE,
    patient_id INTEGER NOT NULL REFERENCES Patient (patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (owner_id, patient_id) -- This assures the combination of owner to patient is unique
);

CREATE TABLE allergy (
    allergy_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES Patient (patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    allergy_type VARCHAR NOT NULL,
    allergy_details VARCHAR
);

CREATE TABLE visit (
    visit_id SERIAL PRIMARY KEY,
    clinic_id INTEGER NOT NULL REFERENCES Clinic (clinic_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    veterinarian_id INTEGER NOT NULL REFERENCES Veterinarian (veterinarian_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    patient_id INTEGER NOT NULL REFERENCES Patient (patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    date DATE NOT NULL,
    time TIME NOT NULL,
    reason VARCHAR NOT NULL,
    diagnosis VARCHAR
);

CREATE TABLE prescription (
    prescription_id SERIAL PRIMARY KEY,
    visit_id INTEGER NOT NULL REFERENCES Visit (visit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    medication_name VARCHAR NOT NULL,
    dosage VARCHAR,
    frequency VARCHAR,
    duration VARCHAR,
    date_prescribed DATE NOT NULL,
    is_refillable BOOLEAN NOT NULL,
    total_refills INTEGER NOT NULL DEFAULT 0 CHECK (total_refills >= 0), -- No negative refills
    used_refills INTEGER NOT NULL DEFAULT 0 CHECK (used_refills BETWEEN 0 AND total_refills), -- Assures used refills are not more than total, or negative
    CHECK (is_refillable OR total_refills = 0) -- If not refillable, total_refills must be 0
);

CREATE TABLE treatment (
    treatment_id SERIAL PRIMARY KEY,
    visit_id INTEGER NOT NULL REFERENCES Visit (visit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    standard_code VARCHAR NOT NULL,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0) -- Base price cannot be negative
);

CREATE TABLE price (
    price_id SERIAL PRIMARY KEY,
    treatment_id INTEGER NOT NULL UNIQUE REFERENCES Treatment (treatment_id) ON DELETE RESTRICT ON UPDATE CASCADE, -- One price per treatment (Unique constraint)
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0) -- Price cannot be negative
);
