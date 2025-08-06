-- Sample SQL script to create the destination table
-- Modify this script based on your CSV file structure

-- Create the destination table
CREATE TABLE dbo.ImportedData (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Column1 NVARCHAR(255),
    Column2 NVARCHAR(255),
    Column3 INT,
    Column4 DECIMAL(10,2),
    Column5 DATETIME2,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Create indexes for better performance (optional)
CREATE INDEX IX_ImportedData_Column1 ON dbo.ImportedData(Column1);
CREATE INDEX IX_ImportedData_CreatedDate ON dbo.ImportedData(CreatedDate);

-- Grant permissions to the Data Factory service principal (if using managed identity)
-- GRANT INSERT, SELECT, DELETE ON dbo.ImportedData TO [your-data-factory-name];

PRINT 'Table dbo.ImportedData created successfully';