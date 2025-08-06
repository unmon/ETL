-- Sample SQL script to create the destination table
-- Modify this script based on your CSV file structure

-- Create the destination table
CREATE TABLE dbo.ImportedData (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(255) NOT NULL,
    Department NVARCHAR(100) NOT NULL,
    EmployeeID INT NOT NULL,
    AnnualSalary DECIMAL(10,2) NOT NULL,
    HireDate DATETIME2 NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Create indexes for better performance (optional)
CREATE INDEX IX_ImportedData_EmployeeName ON dbo.ImportedData(EmployeeName);
CREATE INDEX IX_ImportedData_Department ON dbo.ImportedData(Department);
CREATE INDEX IX_ImportedData_EmployeeID ON dbo.ImportedData(EmployeeID);
CREATE INDEX IX_ImportedData_CreatedDate ON dbo.ImportedData(CreatedDate);

-- Grant permissions to the Data Factory service principal (if using managed identity)
-- GRANT INSERT, SELECT, DELETE ON dbo.ImportedData TO [your-data-factory-name];

PRINT 'Table dbo.ImportedData created successfully';