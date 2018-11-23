use master;

declare @tmptblDistributor TABLE
(
  IsInstalled bit, 
  DistributionServer sysname,
  IsDistributionDatabaseInstalled bit,
  IsDistributionPublisher bit,
  HasRemoteDistributionPublisher bit
)

declare @returnValue int;
insert into @tmptblDistributor exec @returnValue = sp_get_distributor;
-- check error

