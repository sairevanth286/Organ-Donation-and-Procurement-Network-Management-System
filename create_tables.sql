-- Drop the database and recreate it (if needed)
DROP DATABASE IF EXISTS DBMS_PROJECT;
CREATE DATABASE DBMS_PROJECT;

-- Select the newly created database
USE DBMS_PROJECT;

-- Create the 'login' table
CREATE TABLE login(
    username VARCHAR(20) NOT NULL,
    password VARCHAR(20) NOT NULL
);

-- Insert initial login data
INSERT INTO login VALUES ('admin','admin');

-- Create the 'User' table
CREATE TABLE User(
    User_ID int NOT NULL,
    Name varchar(20) NOT NULL,
    Date_of_Birth date NOT NULL,
    Medical_insurance int,
    Medical_history varchar(20),
    Street varchar(20),
    City varchar(20),
    State varchar(20),
    PRIMARY KEY(User_ID)
);

#table 2
CREATE TABLE User_phone_no(
    User_ID int NOT NULL,
    phone_no varchar(15),
    FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

#table 3
CREATE TABLE Organization(
  Organization_ID int NOT NULL,
  Organization_name varchar(20) NOT NULL,
  Location varchar(20),
  Government_approved int, # 0 or 1
  PRIMARY KEY(Organization_ID)
);

#table 4
CREATE TABLE Doctor(
  Doctor_ID int NOT NULL,
  Doctor_Name varchar(20) NOT NULL,
  Department_Name varchar(20) NOT NULL,
  organization_ID int NOT NULL,
  FOREIGN KEY(organization_ID) REFERENCES Organization(organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Doctor_ID)
);

CREATE TABLE Patient (
    Patient_ID int NOT NULL,
    organ_req varchar(20) NOT NULL,
    reason_of_procurement varchar(20),
    Doctor_ID int NOT NULL,
    User_ID int NOT NULL,
    FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
    FOREIGN KEY(Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE CASCADE,
    PRIMARY KEY(Patient_ID, organ_req)  -- Composite primary key
);


CREATE TABLE Donor(
  Donor_ID int NOT NULL,
  organ_donated varchar(20) NOT NULL,
  reason_of_donation varchar(20),
  Organization_ID int NOT NULL,
  User_ID int NOT NULL,
  FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Donor_ID, organ_donated),
  UNIQUE (Donor_ID)  -- Make Donor_ID unique for foreign key reference
);


CREATE TABLE Organ_available(
  Organ_ID int NOT NULL AUTO_INCREMENT,
  Organ_name varchar(20) NOT NULL,
  Donor_ID int NOT NULL,
  organ_donated varchar(20) NOT NULL,
  FOREIGN KEY(Donor_ID, organ_donated) REFERENCES Donor(Donor_ID, organ_donated) ON DELETE CASCADE,
  PRIMARY KEY(Organ_ID)
);


CREATE TABLE Transaction (
    Patient_ID int NOT NULL,
    organ_req varchar(20) NOT NULL,  -- Include organ_req to match the composite key
    Organ_ID int NOT NULL,
    Donor_ID int NOT NULL,
    Date_of_transaction date NOT NULL,
    Status int NOT NULL,  -- 0 or 1
    FOREIGN KEY(Patient_ID, organ_req) REFERENCES Patient(Patient_ID, organ_req) ON DELETE CASCADE,
    FOREIGN KEY(Donor_ID) REFERENCES Donor(Donor_ID) ON DELETE CASCADE,
    PRIMARY KEY(Patient_ID, organ_req, Organ_ID)  -- Composite primary key
);


#table 9
CREATE TABLE Organization_phone_no(
  Organization_ID int NOT NULL,
  Phone_no varchar(15),
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE
);

#table 10
CREATE TABLE Doctor_phone_no(
  Doctor_ID int NOT NULL,
  Phone_no varchar(15),
  FOREIGN KEY(Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE CASCADE
);

#table 11
CREATE TABLE Organization_head(
  Organization_ID int NOT NULL,
  Employee_ID int NOT NULL,
  Name varchar(20) NOT NULL,
  Date_of_joining date NOT NULL,
  Term_length int NOT NULL,
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Organization_ID,Employee_ID)
);
--
-- delimiter //
-- create trigger ADD_DONOR
-- after insert
-- on Donor
-- for each row
-- begin
-- insert into Organ_available(Organ_name, Donor_ID)
-- values (new.organ_donated, new.Donor_ID);
-- end//
-- delimiter ;
--
-- delimiter //
-- create trigger REMOVE_ORGAN
-- after insert
-- on Transaction
-- for each row
-- begin
-- delete from Organ_available
-- where Organ_ID = new.Organ_ID;
-- end//
-- delimiter ;

create table log (
  querytime datetime,
  comment varchar(255)
);

delimiter //
create trigger ADD_DONOR_LOG
after insert
on Donor
for each row
begin
insert into log values
(now(), concat("Inserted new Donor", cast(new.Donor_Id as char)));
end //

create trigger UPD_DONOR_LOG
after update
on Donor
for each row
begin
insert into log values
(now(), concat("Updated Donor Details", cast(new.Donor_Id as char)));
end //

delimiter //
create trigger DEL_DONOR_LOG
after delete
on Donor
for each row
begin
insert into log values
(now(), concat("Deleted Donor ", cast(old.Donor_Id as char)));
end //

create trigger ADD_PATIENT_LOG
after insert
on Patient
for each row
begin
insert into log values
(now(), concat("Inserted new Patient ", cast(new.Patient_Id as char)));
end //

create trigger UPD_PATIENT_LOG
after update
on Patient
for each row
begin
insert into log values
(now(), concat("Updated Patient Details ", cast(new.Patient_Id as char)));
end //

create trigger DEL_PATIENT_LOG
after delete
on Donor
for each row
begin
insert into log values
(now(), concat("Deleted Patient ", cast(old.Donor_Id as char)));
end //

create trigger ADD_TRASACTION_LOG
after insert
on Transaction
for each row
begin
insert into log values
(now(), concat("Added Transaction :: Patient ID : ", cast(new.Patient_ID as char), "; Donor ID : " ,cast(new.Donor_ID as char)));
end //

-- INSERT INTO User VALUES(10,'Random1','2000-01-01',1,NULL,'Street 1','City 1','State 1');
-- INSERT INTO User VALUES(20,'Random2','2000-01-02',1,NULL,'Street 2','City 2','State 2');
