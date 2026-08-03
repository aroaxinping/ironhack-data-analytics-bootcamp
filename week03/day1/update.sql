USE lab_mysql;

SET SQL_SAFE_UPDATES = 0;

UPDATE customers SET email = 'ppicasso@gmail.com' WHERE name = 'Pablo Picasso';
UPDATE customers SET email = 'lincoln@us.gov' WHERE name = 'Abraham Lincoln';
UPDATE customers SET email = 'hello@napoleon.me' WHERE name = 'Napoléon Bonaparte';

SET SQL_SAFE_UPDATES = 1;
