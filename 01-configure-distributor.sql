set nocount on;
set xact_abort on;

use master;

declare @tmptblDistributor TABLE
(
  IsInstalled bit, 
  DistributionServer sysname,
  IsDistributionDatabaseInstalled bit,
  IsDistributionPublisher bit,
  HasRemoteDistributionPublisher bit
)

declare @cSuccessReturnValue int = 0;
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