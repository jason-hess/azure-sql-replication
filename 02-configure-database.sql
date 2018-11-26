/* 

Summary: Enable Transactional Replication on $(DatabaseToReplicate).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseToReplicate ISMIS
:setvar DistributionDatabase distributor

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @databaseToReplicate sysname = '$(DatabaseToReplicate)';
declare @distributionDatabase sysname = '$(DistributionDatabase)';

use master;

--
-- Configure $(DatabaseToReplicate) for Replication
--

declare @tmptblReplicatedDatabase table (
	DatabaseToReplicate sysname,
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

	print 'Enabling Transactional Replication on ' + @databaseToReplicate + '...'
	exec sp_replicationdboption @dbname = @databaseToReplicate, @optname = 'publish', @value = 'true'

end;

-- Execute sp_addlogreader_agent to create the agent job. 
EXEC sp_addlogreader_agent 
	@job_login = @login, 
	@job_password = @password,
	-- Explicitly specify the use of Windows Integrated Authentication (default) 
	-- when connecting to the Publisher.
	@publisher_security_mode = 1;

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