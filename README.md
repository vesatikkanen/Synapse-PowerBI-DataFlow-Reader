# Synapse-PowerBI-DataFlow-Reader
Entities for Synapse On-Demand SQL that allow reading Power BI DataFlow data from Azure Storage

# Usage
Work-in-process.... Better documentation coming. Also all datatypes needs to be double checked.

## Installation
You install the scripts by running all the script in numeric order.
1. 01-Schema-powerbi.sql - creates powerbi -schema
2. 02-View-powerbi.PowerBIModels.sql - creates view that is used to iterate over model.json files. On this file you need to change the Datalake account to be your correct one!
3. 03-StoredProcedure-powerbi.createModelView.sql - creates procedure that generates actual views on top of your dataflow data.

## Usage

You use scripts by executing stored procedure [powerbi].[createModelView]

Stored procedure takes 3 parameters. WorkspaceName, Dataflowname, Entityname. All parameters are strings. 

Example: EXECUTE [powerbi].[createModelView] 'Synapse Integrated','Testi taulu','test'

This will generate view for Dataflow that is in workspace called "Synapse Integrated". Dataflow name is "Testi taulu" and entity name is "test".

It will generate view called: [powerbi].[Synapse Integrated_Testi taulu_test].

You can select from the view by running: select * from [powerbi].[Synapse Integrated_Testi taulu_test]

## Refresh data

When you process your data at Power BI data is not immediately updated at Synapse view. You must rerun the [powerbi].[createModelView] and then data is refreshed.


## Licence and all the good stuff

You may visit licence file and read the small print... But really. Feel free to use the tool if it makes you happy. If I've missed something please guide me! And finally, Do the right thing. Please mention where you got the script.