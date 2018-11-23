:setvar DatabaseName ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @distributionDatabaseName sysname = 'distribution'

use master;

-- todo: check that agent is running, fail otherwise
-- todo: check that the sp_addserver contains the local server, fail otherwise

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

	-- add a local distributor
	print 'Configuring this server as a Replication Distributor...'
	print ''
	declare @distributorName sysname = 'distributor';
	exec sp_adddistributor @distributor = @@servername;

end;

if( @IsDistributionDatabaseInstalled <> @True ) begin 
	
	-- add local distribution database
	exec sp_adddistributiondb @database = @distributionDatabaseName

end;

if( @IsDistributionPublisher <> @True ) begin 
	
	-- configure as publisher
	exec sp_adddistpublisher @publisher = @@servername, @distribution_db = @distributionDatabaseName

end;

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

	print 'Enabling Transactional Replication on $(DatabaseName)...'
	exec sp_replicationdboption @dbname = '$(DatabaseName)', @optname = 'publish', @value = 'true'

end;

-- select @@servername

-- select * from sys.sysservers

-- sp_helpserver

-- exec sp_dropdistributor @no_checks=1,@ignore_distributor=1

-- sp_addserver @server = @@servername, @local = 'local'

-- SELECT serverproperty('ServerName') 