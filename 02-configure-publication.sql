/* 

Summary: Enable Transactional Replication on $(DatabaseToPublish).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseToPublish ISMIS

set nocount on;
set xact_abort on;

use $(DatabaseToPublish);

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