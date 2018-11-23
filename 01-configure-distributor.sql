/* 
Enable Transactional Replication on $(DatabaseName).  
The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by: 

1) enabling replication on the server 
2) enabling replication on the database 
*/

:setvar DatabaseName ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @distributionDatabaseName sysname = 'distribution'
declare @databaseToReplicate sysname = '$(DatabaseName)';

use master;

-- todo: check that agent is running, fail otherwise
-- todo: check that the sp_addserver contains the local server, fail otherwise

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

-- sp_addserver @server = @@servername, @local = 'local'

-- SELECT serverproperty('ServerName') 