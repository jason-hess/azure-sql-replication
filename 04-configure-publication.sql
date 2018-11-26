/* 

Summary: Enable Transactional Replication on $(DatabaseToReplicate).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseToReplicate <DatabaseToReplicate, sysname, ISMIS>

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @databaseToReplicate sysname = '$(DatabaseToReplicate)';

use master;

-- Create a new transactional publication with the required properties. 
EXEC sp_addpublication 
	@publication = @publication, 
	@status = N'active',
	@allow_push = N'true',
	@allow_pull = N'true',
	@independent_agent = N'true';

