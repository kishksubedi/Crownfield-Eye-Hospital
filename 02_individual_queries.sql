USE crownfield_eye;
-- Q1 Which clinicians have more than one appointment?
SELECT c.clinician_name,COUNT(*) AS appointment_count FROM clinician c JOIN appointment a ON a.clinician_id=c.clinician_id GROUP BY c.clinician_id,c.clinician_name HAVING COUNT(*)>1;
-- Q2 Which patient saw which clinician, and where?
SELECT p.full_name,c.clinician_name,k.clinic_name,a.appointment_date FROM appointment a JOIN patient p ON a.patient_id=p.patient_id JOIN clinician c ON a.clinician_id=c.clinician_id JOIN clinic k ON a.clinic_id=k.clinic_id ORDER BY a.appointment_date;
-- Q3 Which clinics have no appointments? LEFT JOIN retains them.
SELECT k.clinic_name,COUNT(a.appointment_id) AS appointment_count FROM clinic k LEFT JOIN appointment a ON k.clinic_id=a.clinic_id GROUP BY k.clinic_id,k.clinic_name ORDER BY k.clinic_name;
-- Q4 Which patients have more appointments than the average patient?
SELECT p.full_name,COUNT(a.appointment_id) AS visits FROM patient p LEFT JOIN appointment a ON a.patient_id=p.patient_id GROUP BY p.patient_id,p.full_name HAVING COUNT(a.appointment_id) > (SELECT COUNT(*)/COUNT(DISTINCT patient_id) FROM appointment);
-- Q5 and Q6 are in 03_procedure_trigger.sql. Capture screenshots of calls and tests there.
