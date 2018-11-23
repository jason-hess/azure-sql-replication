set nocount on;
set xact_abort on;

declare @True bit = 1;

use master;

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

select * from @tmptblDistributor;

-- todo: check that agent is running, fail otherwise
-- todo: check that the sp_addserver contains the local server, fail otherwise

if( @IsInstalled <> @True ) begin

	-- add a local distributor
	declare @distributorName sysname = 'distributor';
	exec sp_adddistributor @distributor = @@servername;

end;

if( @IsDistributionDatabaseInstalled <> @True ) begin 
	
	-- add local distribution database
	declare @distributionDatabaseName sysname = 'distribution'
	exec sp_adddistributiondb @database = @distributionDatabaseName

end;

if( @IsDistributionPublisher <> @True ) begin 
	
end;

-- select @@servername

-- select * from sys.sysservers

-- sp_helpserver

-- exec sp_dropdistributor @no_checks=1,@ignore_distributor=1

-- sp_addserver @server = @@servername, @local = 'local'

-- SELECT serverproperty('ServerName') 