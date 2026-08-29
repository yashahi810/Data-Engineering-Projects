**SalesData.csv** — 	full source dataset (1,849 records) used for initial/full load testing. **Date\_ID** values range from DT00001 to DT01247 and are used by the pipeline's watermark logic to identify new records on each run.

**IncrementalSales\_batch.csv** — 	A 200-record synthetic batch generated to test and demonstrate the pipeline's incremental loading behavior. It continues the same schema and **Date\_ID** sequence as SalesData.csv, starting at DT01248.

