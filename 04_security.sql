-- RUN AS MYSQL ADMINISTRATOR ONLY. Change all sample passwords before real use.
USE crownfield_eye;
CREATE ROLE IF NOT EXISTS 'clinical_admin', 'doctor_role', 'reception_role', 'patient_role';
GRANT SELECT,INSERT,UPDATE,DELETE ON crownfield_eye.* TO 'clinical_admin';
GRANT SELECT ON crownfield_eye.patient TO 'doctor_role';
GRANT SELECT ON crownfield_eye.appointment TO 'doctor_role';
GRANT SELECT,UPDATE ON crownfield_eye.prescription_item TO 'doctor_role';
GRANT SELECT ON crownfield_eye.patient TO 'reception_role';
GRANT SELECT,INSERT,UPDATE ON crownfield_eye.appointment TO 'reception_role';
-- A patient-specific view: DO NOT grant SELECT on base tables to patient_role.
CREATE OR REPLACE VIEW patient_op001_appointments AS
SELECT appointment_id, appointment_date, appointment_time, status
FROM appointment
WHERE patient_id = 'OP001';
GRANT SELECT ON crownfield_eye.patient_op001_appointments TO 'patient_role';
-- Limitation: fixed patient view is for demonstration only. Production requires identity-bound row-level authorisation.
SHOW GRANTS FOR 'doctor_role';
SHOW GRANTS FOR 'reception_role';
SHOW GRANTS FOR 'patient_role';
-- SHA2 here demonstrates a salted hash. For real password storage use Argon2id/bcrypt/scrypt at application level.
SELECT patient_id,password_salt,password_hash FROM patient LIMIT 2;
