set nocount on;
set xact_abort on;

declare @True bit = 1;

use master;

declare @tmptblDistributor TABLE
(
  IsInstalled bit, 
  DistributionServer sysname,
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
	declare @distributorName sysname = 'distributor';
	exec sp_adddistributor @distributorName;

end;