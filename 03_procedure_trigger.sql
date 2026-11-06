USE crownfield_eye;
DELIMITER //
CREATE PROCEDURE set_dosage(IN p_item_id INT, IN p_new_dose VARCHAR(60))
BEGIN
  IF p_new_dose IS NULL OR TRIM(p_new_dose)='' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Dose cannot be blank'; END IF;
  UPDATE prescription_item SET dose=p_new_dose WHERE item_id=p_item_id;
  IF ROW_COUNT()=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Item not found or dose unchanged'; END IF;
END//
CREATE TRIGGER trg_dose_audit AFTER UPDATE ON prescription_item FOR EACH ROW
BEGIN
  IF NOT (OLD.dose <=> NEW.dose) THEN
    INSERT INTO dose_audit(item_id,old_dose,new_dose,changed_by) VALUES (NEW.item_id,OLD.dose,NEW.dose,CURRENT_USER());
  END IF;
END//
CREATE TRIGGER trg_appointment_date BEFORE INSERT ON appointment FOR EACH ROW
BEGIN
  IF NEW.appointment_date < '2020-01-01' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Appointment date is outside supported range'; END IF;
END//
DELIMITER ;
-- Q5: parameterised stored procedure (run after schema; creates an audit row)
CALL set_dosage(1,'2 drops');
SELECT * FROM prescription_item WHERE item_id=1;
-- Q6: meaningful audit trigger evidence
SELECT * FROM dose_audit ORDER BY audit_id DESC LIMIT 5;
-- Trigger rejection test: uncomment only when ready; expected ERROR 1644
-- INSERT INTO appointment(patient_id,clinician_id,clinic_id,appointment_date,appointment_time) VALUES('OP001','CL001','CK001','1900-01-01','08:00');
-- Controlled transaction testing; rollback preserves original data
START TRANSACTION;
UPDATE appointment SET status='rescheduled' WHERE appointment_id=3;
SELECT * FROM appointment WHERE appointment_id=3;
ROLLBACK;
-- DELETE permitted only for a record with no dependants
START TRANSACTION;
INSERT INTO appointment(patient_id,clinician_id,clinic_id,appointment_date,appointment_time) VALUES('OP010','CL010','CK010','2027-06-01','08:00');
SET @temporary_appointment_id=LAST_INSERT_ID();
DELETE FROM appointment WHERE appointment_id=@temporary_appointment_id;
COMMIT;
