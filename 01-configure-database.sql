/* 

Summary: Enable Transactional Replication on $(DatabaseName).  

The aim of this script is that turns the Database into one that can replicate with 
an Azure SQL Database by enabling replication on the database.

Note: This script assumes 01-configure-server.sql has been run beforehand.

*/

:setvar DatabaseName ISMIS

set nocount on;
set xact_abort on;

declare @True bit = 1;
declare @databaseToReplicate sysname = '$(DatabaseName)';

use master;

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