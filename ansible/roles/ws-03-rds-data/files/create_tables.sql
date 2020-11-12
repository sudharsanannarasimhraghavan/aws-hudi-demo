CREATE SCHEMA  IF NOT EXISTS  weathersvc;

CREATE TABLE IF NOT EXISTS weathersvc.weather_hourly_actl
(
   id                                    varchar,
   station_id                            varchar,
   apparenttemperaturefahrenheit         float8,
   cloudcoveragepercent                  bigint,
   datehrgmt                             varchar,
   datehrlwt                             varchar,
   diffusehorizontalradiationwsqm        bigint,
   directnormalirradiancewsqm            bigint,
   downwardsolarradiationwsqm            bigint,
   elevationfeet                         float8,
   elevationmeters                       float8,
   heatindexfahrenheit                   float8,
   latitude                              float8    NOT NULL,
   longitude                             float8    NOT NULL,
   mslpressuremillibars                  float8,
   precipitationprevioushourinches       float8,
   relativehumiditypercent               bigint,
   resolution                            float8,
   snowfallinches                        float8,
   surfaceairpressuremillibars           float8,
   surfacedewpointtemperaturefahrenheit  float8,
   surfacetemperaturefahrenheit          float8,
   surfacewetbulbtemperaturefahrenheit   float8,
   surfacewindgustsmph                   float8,
   timezone                              varchar,
   windchilltemperaturefahrenheit        float8,
   winddirectiondegrees                  bigint,
   windspeedmph                          float8,
   etl_date                              varchar,
   hour                                  integer,
   day                                   integer,
   year                                  integer,
   month                                 integer,
   hourly_audit_checksum                 varchar,
   hourly_audit                          varchar
);

CREATE TABLE IF NOT EXISTS weathersvc.weather_hourly_forecast_2day
(
   id                     varchar,
   cloudcover             float8,
   dayofweek              varchar,
   dayornight             varchar,
   expirationtimeutc      float8,
   iconcode               float8,
   iconcodeextend         float8,
   latitude               float8    NOT NULL,
   longitude              float8    NOT NULL,
   precipchance           float8,
   preciptype             varchar,
   pressuremeansealevel   float8,
   qpf                    float8,
   qpfsnow                float8,
   relativehumidity       float8,
   temperature            float8,
   temperaturedewpoint    float8,
   temperaturefeelslike   float8,
   temperatureheatindex   float8,
   temperaturewindchill   float8,
   uvdescription          varchar,
   uvindex                float8,
   validtimelocal         varchar,
   validtimeutc           float8,
   validtimeutcdt         varchar,
   visibility             float8,
   winddirection          float8,
   winddirectioncardinal  varchar,
   windgust               float8,
   windspeed              float8,
   wxphraselong           varchar,
   wxphraseshort          varchar,
   wxseverity             float8,
   validtimegmt           varchar,
   forecasttime           varchar,
   etl_date               varchar,
   hour                   integer,
   day                    integer,
   year                   integer,
   month                  integer,
   hourly_audit           varchar
);

CREATE TABLE IF NOT EXISTS weathersvc.weather_hourly_forecast_15day
(
   id                     varchar,
   cloudcover             float8,
   dayofweek              varchar,
   dayornight             varchar,
   expirationtimeutc      float8,
   iconcode               float8,
   iconcodeextend         float8,
   latitude               float8    NOT NULL,
   longitude              float8    NOT NULL,
   precipchance           float8,
   preciptype             varchar,
   pressuremeansealevel   float8,
   qpf                    float8,
   qpfsnow                float8,
   relativehumidity       float8,
   temperature            float8,
   temperaturedewpoint    float8,
   temperaturefeelslike   float8,
   temperatureheatindex   float8,
   temperaturewindchill   float8,
   uvdescription          varchar,
   uvindex                float8,
   validtimelocal         varchar,
   validtimeutc           float8,
   validtimeutcdt         varchar,
   visibility             float8,
   winddirection          float8,
   winddirectioncardinal  varchar,
   windgust               float8,
   windspeed              float8,
   wxphraselong           varchar,
   wxphraseshort          varchar,
   wxseverity             float8,
   validtimegmt           varchar,
   forecasttime           varchar,
   etl_date               varchar,
   day                    integer,
   hour                   integer,
   year                   integer,
   month                  integer,
   hourly_audit           varchar
);

CREATE TABLE IF NOT EXISTS weathersvc.wthr_metars_rpt
(
   stn_id     varchar(50),
   latitude   float8,
   longitude  float8,
   utility    varchar(50)
);


create table if not exists weathersvc.weather_hourly_actl_shortterm as select * from weathersvc.weather_hourly_actl limit 0;
create table if not exists weathersvc.weather_hourly_forecast_2day_shortterm as select * from weathersvc.weather_hourly_forecast_2day limit 0;
create table if not exists weathersvc.weather_hourly_forecast_15day_shortterm as select * from weathersvc.weather_hourly_forecast_15day limit 0;


CREATE OR REPLACE FUNCTION weathersvc.getdate()
  RETURNS timestamp with time zone
  LANGUAGE sql
AS
$body$
select now();
$body$
  STABLE
  COST 100;

