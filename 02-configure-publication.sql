/* 

Summary: Enable Transactional Replication on $(DatabaseToPublish).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseToPublish <DatabaseToPublish, sysname, ISMIS>

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @DatabaseToPublish sysname = '$(DatabaseToPublish)';

use master;

--
-- Configure $(DatabaseToPublish) for Replication
--

declare @tmptblReplicatedDatabase table (
	DatabaseToPublish sysname,
	DatabaseId int,
	IsEnabledForTransactionalReplication bit,
	IsEnabledForMergeReplication bit,
	IsDbOwner bit,
	IsDatabaseReadOnly bit
);

insert into @tmptblReplicatedDatabase exec sp_helpreplicationdboption;

declare @IsEnabledForTransactionalReplication bit = (
	select IsEnabledForTransactionalReplication from @tmptblReplicatedDatabase
);

if( @IsEnabledForTransactionalReplication <> @True ) begin

	print 'Enabling Transactional Replication on ' + @DatabaseToPublish + '...'
	exec sp_replicationdboption @dbname = @DatabaseToPublish, @optname = 'publish', @value = 'true'

end;

--
-- Configure Log Reader Agent
--

-- Note: This requires a service account that is passed into SqlPackage.exe or SQLCMD.EXE

declare @WindowsIntegratedAuthentication bit = 1;
exec sp_addlogreader_agent 
	@job_login = '$(AgentUsername)', 
	@job_password = '$(AgentPassword)',
	@publisher_security_mode = @WindowsIntegratedAuthentication;

-- Create a new transactional publication with the required properties. 
EXEC sp_addpublication 
	@publication = @publication, 
	@status = N'active',
	@allow_push = N'true',
	@allow_pull = N'true',
	@independent_agent = N'true';

-- Create a new snapshot job for the publication, using a default schedule.
EXEC sp_addpublication_snapshot 
	@publication = @publication, 
	@job_login = @login, 
	@job_password = @password,
	-- Explicitly specify the use of Windows Integrated Authentication (default) 
	-- when connecting to the Publisher.
	@publisher_security_mode = 1;
GO