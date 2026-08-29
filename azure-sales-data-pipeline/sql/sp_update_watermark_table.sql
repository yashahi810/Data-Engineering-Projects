-- Stored procedure: updates the watermark table with the latest load value
-- after each successful incremental copy in the ADF pipeline.
-- Called by the "WatermarkUpdate" Stored Procedure activity in increm_data_pipeline.

DROP PROCEDURE IF EXISTS UpdateWatermarkTable
GO

CREATE PROCEDURE UpdateWatermarkTable
    @lastload VARCHAR(2000)
AS
BEGIN
    -- Start the transaction
    BEGIN TRANSACTION;

    -- Update the incremental watermark column in the table
    UPDATE water_table
    SET last_load = @lastload

    COMMIT TRANSACTION;
END
