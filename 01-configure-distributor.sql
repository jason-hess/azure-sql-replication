/* 

Summary: Enable Transactional Replication on $(DatabaseName).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the server and the database.

Note: In order to run this script, SQL Server Agent must be running.

*/

:setvar DatabaseName ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @distributionDatabaseName sysname = 'distribution'
declare @databaseToReplicate sysname = '$(DatabaseName)';

use master;

--
-- Ensure SQL Server Agent is Running
--

-- Note: To configure replication the SQL Server Agent must be running

if not exists( 
	select * from master.dbo.sysprocesses 
    where program_name = N'SQLAgent - Generic Refresher' ) begin

	throw 50000, 'SQL Server Agent must be running in order to enable replication', 1;

end;

-- 
-- Ensure the Server exists in metadata
--

-- Note: Sometimes when configuring replication the metadata can get out of correct state.
--       This is here just to fix the possibility of the server name not being in sys.servers.

if not exists( select * from sys.sysservers where srvname = @@servername ) begin

	-- Note: To test this section of code, run: sp_dropserver @@servername

	print 'Correcting sys.sysservers';

	exec sp_addserver @server = @@servername, @local = 'local';

end;

--
-- Configure the Server as a Replication Distributor 
--

declare @tmptblDistributor TABLE
(
  IsInstalled bit, 
  DistributionServer sysname null,
  IsDistributionDatabaseInstalled bit,
  IsDistributionPublisher bit,
  HasRemoteDistributionPublisher bit
);

insert into @tmptblDistributor exec sp_get_distributor;

declare @IsInstalled bit;
declare @IsDistributionDatabaseInstalled bit;
declare @IsDistributionPublisher bit;
declare @HasRemoteDistributionPublisher bit;

select 
	@IsInstalled = IsInstalled,
	@IsDistributionDatabaseInstalled = IsDistributionDatabaseInstalled,
	@IsDistributionPublisher = IsDistributionPublisher,
	@HasRemoteDistributionPublisher = HasRemoteDistributionPublisher
from
	@tmptblDistributor;

if( @IsInstalled <> @True ) begin

	print 'Configuring ' + @@servername + ' as a Replication Distributor...'
	
	declare @distributorName sysname = 'distributor';
	exec sp_adddistributor @distributor = @@servername;

end;

--
-- Add the Distributor Database
--

if( @IsDistributionDatabaseInstalled <> @True ) begin 
	
	-- add local distribution database
	exec sp_adddistributiondb @database = @distributionDatabaseName;
	
	reconfigure; 
end;

--
-- Configure this Server as Publisher
--

if( @IsDistributionPublisher <> @True ) begin 
	
	-- configure as publisher
	exec sp_adddistpublisher @publisher = @@servername, @distribution_db = @distributionDatabaseName

end;

--
-- Configure $(DatabaseName) for Replication
--

declare @tmptblReplicatedDatabase table (
	DatabaseName sysname,
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


-- select @@servername

-- select * from sys.sysservers

-- sp_helpserver

-- exec sp_dropdistributor @no_checks=1,@ignore_distributor=1

-- sp_dropserver @@servername

-- sp_addserver @server = @@servername, @local = 'local'

-- SELECT serverproperty('ServerName') 