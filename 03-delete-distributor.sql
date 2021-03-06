/* 

Summary: Disable Transactional Replication on this Server.

The aim of this script is to completely remove replication from this server.

*/

:setvar DatabaseName ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @distributionDatabaseName sysname = 'distribution'
declare @replicatedDatabase sysname = '$(DatabaseName)';

use master;

-- 
-- Disable Replication on $(DatabaseName)
--

exec sp_removedbreplication @replicatedDatabase;

-- 
-- Disable Replication on the server
--

EXEC sp_dropdistpublisher @@servername;

-- Delete the distribution database.
EXEC sp_dropdistributiondb 'distribution';

-- Remove the local server as a Distributor.
EXEC sp_dropdistributor;

-- exec sp_dropdistributor @no_checks = 1;