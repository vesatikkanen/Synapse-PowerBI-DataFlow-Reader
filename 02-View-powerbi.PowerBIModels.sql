IF EXISTS(select 1 from sys.views as v INNER JOIN sys.schemas as s ON v.schema_id=s.schema_id where v.name='PowerBIModels' and s.name='powerbi')
BEGIN
    DROP VIEW [powerbi].[PowerBIModels]; 
END

GO

CREATE VIEW [powerbi].[PowerBIModels] AS
SELECT 

    /*
        Power BI Dataflow reader for Synapse.	
        
        Reader created by Vesa Tikkanen

        Do the right thing! Please keep this comment in your generated script.

    */

     [result].filepath(1) AS [WorkspaceName]
    ,[result].filepath(2) AS [DataFlowName]
    ,JSON_VALUE(jsoncontent, '$.name') as DataFlowInternalName
    ,convert(datetime2,JSON_VALUE(jsoncontent, '$.modifiedTime')) as modifiedTime 
    ,JSON_VALUE(entity.Value, '$.name') as entityName
    ,JSON_VALUE(partitions.Value, '$.location') as FileName
    ,JSON_VALUE(attributes.Value, '$.name') as ColumnName
    ,JSON_VALUE(attributes.Value, '$.dataType') as ColumnDataType
    ,
    CASE WHEN JSON_VALUE(attributes.Value, '$.dataType')='date' then 'date'
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='dateTime' then 'datetime2'
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='int64' then 'bigint'
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='string' then 'nvarchar(4000)'        
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='decimal' then 'decimal(18,6)'
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='boolean' then 'bit'
     WHEN JSON_VALUE(attributes.Value, '$.dataType')='double' then 'float'
    ELSE JSON_VALUE(attributes.Value, '$.dataType') END as ColumnDataTypeSQL
    
    ,[result].filepath() as modelFileName
FROM
    OPENROWSET(
        -- HERE CHANGE YOUR Azure Datalake Gen2 account that you're using for your DataFlow's
        BULK 'https://qdataflow.dfs.core.windows.net/powerbi/*/*/model.json',        	
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]
      CROSS APPLY OPENJSON(JSON_QUERY(jsoncontent, '$.entities')) as entity
      CROSS APPLY OPENJSON(entity.Value, '$.attributes') as attributes
      CROSS APPLY OPENJSON(entity.Value, '$.partitions') as partitions



