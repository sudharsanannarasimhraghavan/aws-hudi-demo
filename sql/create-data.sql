
CREATE TABLE
    covid_by_state(
        covid_by_state_id INTEGER NOT NULL AUTO_INCREMENT,
        date TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
        state VARCHAR(100),
        fips INTEGER,
        cases INTEGER,
        deaths INTEGER,
        CONSTRAINT orders_pk PRIMARY KEY(covid_by_state_id)
);


INSERT INTO covid_by_state(
    date,
    state,
    fips,
    cases,
    deaths)
VALUES(
    '2020-01-21',
    'New Jersey',
    34,
    1,
    0);


INSERT INTO covid_by_state(
    date,
    state,
    fips,
    cases,
    deaths)
VALUES('
    2020-01-21',
    'Texas',
    48,
    1,
    0);

INSERT INTO covid_by_state( date , state, fips, cases, deaths) VALUES('2020-01-21','Washington',53,10,0);

INSERT INTO covid_by_state( date , state, fips, cases, deaths) VALUES('2020-01-21','Illinois',17,20,0);

INSERT INTO covid_by_state( date , state, fips, cases, deaths) VALUES('2020-01-21','New York',99,33,0);


UPDATE hudi_demo_db.covid_by_state
    SET cases=24
    WHERE covid_by_state_id=1;
