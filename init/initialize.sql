CREATE DATABASE ICAT;
CREATE USER 'irods'@'localhost' IDENTIFIED BY 'testpassword';
GRANT ALL ON ICAT.* to 'irods'@'localhost';