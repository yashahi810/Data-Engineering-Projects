-- Watermark table: tracks the last loaded value to support incremental data loading.
-- Used by the ADF pipeline's Lookup activities (last_load / current_load)
-- to determine which new rows to pull from the source on each run.
CREATE TABLE water_table
(
    last_load VARCHAR(2000)
)

-- Seed with an initial watermark value before the first incremental run
-- INSERT INTO water_table (last_load) VALUES ('0')
