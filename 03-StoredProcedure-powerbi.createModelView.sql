IF EXISTS(select 1 from sys.procedures as p inner join sys.schemas as s on p.schema_id=s.schema_id where p.name='createModelView' and s.name='powerbi')
BEGIN
  DROP PROCEDURE [powerbi].[createModelView];
END

GO

CREATE PROCEDURE [powerbi].[createModelView] 
    @WorkspaceName nvarchar(200), @DataFlowName nvarchar(200),  @EntityName nvarchar(200)
AS
BEGIN
    /*
        Power BI Dataflow reader for Synapse.	
        
        Reader created by Vesa Tikkanen

        Do the right thing! Please keep this comment in your generated script.

    */


    --DECLARE @WorkspaceName nvarchar(200)='SynapseIntegrated';
    --DECLARE @DataFlowName nvarchar(200)='Currency';
    --DECLARE @EntityName nvarchar(200)='DimCurrency';

    DECLARE @columnsChar nvarchar(max)='';
    DECLARE @columnsCharSel nvarchar(max)='';


    -- chech if names of the workspace, dataflow or entity contains not compatible characters.
    IF CHARINDEX('[',@WorkspaceName)>0 OR CHARINDEX(']',@WorkspaceName)>0 OR
    CHARINDEX('[',@DataFlowName)>0 OR CHARINDEX(']',@DataFlowName)>0 OR 
    CHARINDEX('[',@EntityName)>0 OR CHARINDEX(']',@EntityName)>0
    BEGIN
        PRINT 'Escape characters detected. Cannot create.'
        RETURN
    END


    select @columnsChar = STRING_AGG(colname,', ')  from 
    (select  '[' + ColumnName + '] ' + CASE when ColumnDataTypeSQL='datetime2' then 'nvarchar(200)' else ColumnDataTypeSQL END as colname  from  [powerbi].[PowerBIModels] where WorkspaceName=@WorkspaceName
        and DataFlowName=@DataFlowName and EntityName=@EntityName
        ) as a;



    select @columnsCharSel = STRING_AGG(colname,', ')  from 
    (select  CASE when ColumnDataTypeSQL='datetime2' then 'convert(datetime2,[' + ColumnName + '],101) AS [' + ColumnName + '] ' else '[' + ColumnName + '] ' END as colname  from  [powerbi].[PowerBIModels] where WorkspaceName=@WorkspaceName
        and DataFlowName=@DataFlowName and EntityName=@EntityName
        ) as a;

    --select @columnsChar;


    DECLARE @sqlcmd nvarchar(max);

    SET @sqlcmd = N'DROP view if exists powerbi.[' + @WorkspaceName + '_' + @DataFlowName + '_' + @EntityName + N'];';
    EXECUTE sp_executesql @sqlcmd;
    --select @sqlcmd;

    select @sqlcmd = N'CREATE view powerbi.[' + @WorkspaceName + '_' + @DataFlowName + '_' + @EntityName + N']
    AS' + STRING_AGG(subselect,'

    UNION ALL

    ')  from 
    (select  

    N'

    SELECT
        ' + @columnsCharSel+ N'
    FROM
        OPENROWSET(
            BULK ''' + REPLACE(FileName,'%20',' ') + N''',
            FORMAT = ''CSV'',
            PARSER_VERSION=''2.0''
        ) 
        WITH (
    ' + @columnsChar + N'
    )
        
        AS [result]

    '
    as subselect  from  [powerbi].[PowerBIModels] where WorkspaceName=@WorkspaceName
        and DataFlowName=@DataFlowName and EntityName=@EntityName group by FileName
        ) as a;


    --select @sqlcmd;

    EXECUTE sp_executesql @sqlcmd;


END
GO


