

call mysql.rds_set_configuration('binlog retention hours', 24)


create table dev.retail_transactions(
tran_id INT,
tran_date DATE,
store_id INT,
store_city varchar(50),
store_state char(2),
item_code varchar(50),
quantity INT,
total FLOAT);

-- --------------------------------------------------------------------------------------------------------
-- initial records
insert into dev.retail_transactions values(1,'2019-03-17',1,'CHICAGO','IL','XXXXXX',5,106.25);
insert into dev.retail_transactions values(2,'2019-03-16',2,'NEW YORK','NY','XXXXXX',6,116.25);


-- --------------------------------------------------------------------------------------------------------
-- apply an insert, update and delete
insert into dev.retail_transactions values(15,'2019-03-16',7,'CHICAGO','IL','XXXXXX',17,126.25);
update dev.retail_transactions set store_city='SPRINGFIELD' where tran_id=1;
delete from dev.retail_transactions where tran_id=2;
insert into dev.retail_transactions values(4,'2019-03-17',4,'SAN FRANCISCO','CA','XXXXXX',8,136.25);


-- --------------------------------------------------------------------------------------------------------
-- another set of inserts and an update
update dev.retail_transactions set store_city='NEW YORK' where tran_id=1;
insert into dev.retail_transactions values(3,'2019-03-15',3,'SPRINGFIELD','IL','XXXXXX',7,126.25);
insert into dev.retail_transactions values(4,'2019-03-17',4,'SAN FRANCISCO','CA','XXXXXX',8,136.25);
insert into dev.retail_transactions values(5,'2019-03-11',1,'CHICAGO','IL','XXXXXX',9,146.25);

-- --------------------------------------------------------------------------------------------------------
insert into dev.retail_transactions values(6,'2019-03-18',1,'CHICAGO','IL','XXXXXX',10,156.25);
insert into dev.retail_transactions values(7,'2019-03-14',2,'NEW YORK','NY','XXXXXX',11,166.25);
insert into dev.retail_transactions values(8,'2019-03-11',1,'CHICAGO','IL','XXXXXX',12,176.25);
insert into dev.retail_transactions values(9,'2019-03-10',4,'SAN FRANCISCO','CA','XXXXXX',13,186.25);
insert into dev.retail_transactions values(10,'2019-03-13',1,'CHICAGO','IL','XXXXXX',14,196.25);
insert into dev.retail_transactions values(11,'2019-03-14',5,'CHICAGO','IL','XXXXXX',15,106.25);
insert into dev.retail_transactions values(12,'2019-03-15',6,'CHICAGO','IL','XXXXXX',16,116.25);
insert into dev.retail_transactions values(13,'2019-03-16',7,'CHICAGO','IL','XXXXXX',17,126.25);
insert into dev.retail_transactions values(14,'2019-03-16',7,'CHICAGO','IL','XXXXXX',17,126.25);