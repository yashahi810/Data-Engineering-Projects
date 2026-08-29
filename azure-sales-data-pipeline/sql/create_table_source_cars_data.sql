-- Source table: stores raw car sales data ingested from CSV via ADF Copy Activity
CREATE TABLE source_cars_data
(
    Branch_ID     VARCHAR(200),
    Dealer_ID     VARCHAR(200),
    Model_ID      VARCHAR(200),
    Revenue       BIGINT,
    Units_Sold    BIGINT,
    Date_ID       VARCHAR(200),
    Day           INT,
    Month         INT,
    Year          INT,
    BranchName    VARCHAR(200),
    DealerName    VARCHAR(200),
    Product_Name  VARCHAR(200)
)
