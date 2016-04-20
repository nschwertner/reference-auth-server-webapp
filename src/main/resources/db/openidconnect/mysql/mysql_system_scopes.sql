--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

SET AUTOCOMMIT FALSE;

START TRANSACTION;

--
-- Insert scope information into the temporary tables.
-- 

INSERT INTO system_scope_TEMP (scope, description, icon, allow_dyn_reg, default_scope, structured, structured_param_description) VALUES
  ('openid', 'log in using your identity', 'user', true, true, false, null),
  ('profile', 'basic profile information', 'list-alt', true, true, false, null),
  ('smart/orchestrate_launch', 'Orchestrate a launch with EHR context', 'user', true, false, false, null),
  ('launch', 'Launch with an existing context', 'user', true, false, true, 'Launch from existing context'),
  ('launch/patient', 'Launch with patient context', 'user', true, false, true, 'Launch patient'),
  ('launch/encounter', 'Launch with encounter context', 'user', true, false, true, 'Launch encounter'),
  ('launch/resource', 'Launch with resource context', 'user', true, false, true, 'Launch resource'),
  ('launch/other', 'Launch with other context', 'user', true, false, true, 'Launch other'), 
  ('user/Patient.read', 'all FHIR permissions for user', 'user', true, false, false, null), 
  ('user/*.read', 'Read all FHIR data that you can access', 'user', true, false, false, null), 
  ('user/*.*', 'All FHIR permissions for data that you can access', 'user', true, false, false, null), 
  ('patient/*.read', 'Read all FHIR data for a single patient record', 'user', true, false, false, null), 
  ('patient/*.*', 'All FHIR permissions for a single patient record', 'user', true, false, false, null), 
  ('offline_access', 'offline access', 'time', true, true, false, null);
  
--
-- Merge the temporary scopes safely into the database. This is a two-step process to keep scopes from being created on every startup with a persistent store.
--

MERGE INTO system_scope
  USING (SELECT scope, description, icon, allow_dyn_reg, default_scope, structured, structured_param_description FROM system_scope_TEMP) AS vals(scope, description, icon, allow_dyn_reg, default_scope, structured, structured_param_description)
  ON vals.scope = system_scope.scope
  WHEN NOT MATCHED THEN
    INSERT (scope, description, icon, allow_dyn_reg, default_scope, structured, structured_param_description) VALUES(vals.scope, vals.description, vals.icon, vals.allow_dyn_reg, vals.default_scope, vals.structured, vals.structured_param_description);

COMMIT;

SET AUTOCOMMIT TRUE;
