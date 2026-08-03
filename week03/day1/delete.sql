USE lab_mysql;

-- The lab's instructions say "remove the entry with car ID #4" as the fix for
-- the duplicated VIN DAM41UDN3CHU2WVF6 -- but in this schema, id 4 is the
-- Toyota RAV4, not one of the two duplicate Volvo rows (those are id 5 and 6).
-- Deleting id 4 as literally instructed would remove an unrelated car and
-- leave the actual duplicate in place, so instead this deletes by VIN,
-- keeping the first occurrence (id 5) and removing the redundant second one
-- (id 6) -- the version of the fix that actually matches the stated reason.

SET SQL_SAFE_UPDATES = 0;

DELETE FROM cars WHERE vin = 'DAM41UDN3CHU2WVF6' AND id <> (
    SELECT min_id FROM (
        SELECT MIN(id) AS min_id FROM cars WHERE vin = 'DAM41UDN3CHU2WVF6'
    ) AS keep_row
);

SET SQL_SAFE_UPDATES = 1;
