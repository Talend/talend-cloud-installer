\set version '0.1'
-- this first line is very important for Puppet management, do not remove it, and increase version number on any change on the file

-- clean everything before indexing
VACUUM ANALYZE;

-- New indexes for activemq
CREATE INDEX IF NOT EXISTS tmp_activemq_msgs_p_desc_idx ON activemq_msgs (id DESC);
CREATE INDEX IF NOT EXISTS tmp_activemq_msgs_pc_asc_idx ON activemq_msgs (id ASC, container);
CREATE INDEX IF NOT EXISTS tmp_activemq_msgs_pcx_asc_idx ON activemq_msgs (id ASC, xid NULLS FIRST, container);
CREATE INDEX IF NOT EXISTS tmp_activemq_msgs_pcp_idx ON activemq_msgs (id, container, priority);
CREATE INDEX IF NOT EXISTS tmp_activemq_msgs_pxpc_asc_desc_idx ON activemq_msgs (id ASC,xid NULLS FIRST, priority DESC, container);
CREATE INDEX IF NOT EXISTS tmp_activemq_acks_c_idx ON activemq_acks (container);

--- tuning autovacuum for activemq_msgs table
ALTER TABLE activemq_msgs SET (autovacuum_vacuum_cost_limit = 2000);
ALTER TABLE activemq_msgs SET (autovacuum_vacuum_cost_delay = 10);
ALTER TABLE activemq_msgs SET (autovacuum_vacuum_scale_factor = 0);
ALTER TABLE activemq_msgs SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE activemq_msgs SET (autovacuum_analyze_threshold = 1000);
ALTER TABLE activemq_msgs SET (autovacuum_analyze_scale_factor = 0.01);

INSERT INTO tmp_activemq_optimizations (change_date, filename, version)
    VALUES (now(), 'postgresql_optimizations.sql', :'version');
