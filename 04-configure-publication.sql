/* 

Summary: Enable Transactional Replication on $(DatabaseToReplicate).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseToReplicate ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @databaseToReplicate sysname = '$(DatabaseToReplicate)';

use $(DatabaseToReplicate);

exec sp_addpublication 
	@publication = @databaseToReplicate, 
	@sync_method = N'concurrent', 
	@compress_snapshot = N'true', 
	@repl_freq = N'continuous', 
	@status = N'active', 
	@independent_agent = N'true', 
	@immediate_sync = N'false', 
	@allow_sync_tran = N'false', 
	@replicate_ddl = 1
GO