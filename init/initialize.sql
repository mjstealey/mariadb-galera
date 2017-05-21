CREATE DATABASE ICAT CHARACTER SET latin1 COLLATE latin1_general_cs;
CREATE USER 'irods'@'localhost' IDENTIFIED BY 'temppassword';
GRANT ALL ON ICAT.* TO 'irods'@'localhost';
SHOW GRANTS FOR 'irods'@'localhost';