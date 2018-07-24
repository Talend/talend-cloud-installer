-- table to trace current optimization status
CREATE TABLE IF NOT EXISTS tmp_activemq_optimizations (
  change_date  date,
  filename     varchar(256),
  version      varchar(10)
)
