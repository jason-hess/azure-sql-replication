/* 

Summary: Configure the Log Reader Agent

The Replication Log Reader Agent is an executable that monitors the transaction log of each database 
configured for transactional replication and copies the transactions marked for replication from the 
transaction log into the distribution database.

Note: This script requires the $(AgentUsername) and $(AgentPassword) variables to be passed in.  This
      account requires certain permissions.  
	  
	  See: https://docs.microsoft.com/en-us/sql/relational-databases/replication/security/replication-agent-security-model

*/

:setvar DatabaseToPublish ISMIS
:setvar DistributionDatabase distribution

set nocount on;
set xact_abort on;

---
-- Configure Permissions Required for Log Reader Agent User
--

use $(DatabaseToPublish);

exec sp_addrolemember 'db_owner', '$(AgentUsername)';

use $(DistributionDatabase);

exec sp_addrolemember 'db_owner', '$(AgentUsername)';

-- TODO: https://docs.microsoft.com/en-us/sql/relational-databases/replication/security/manage-logins-in-the-publication-access-list?view=sql-server-2017


--
-- Configure Log Reader Agent
--

use $(DatabaseToPublish);

declare @WindowsIntegratedAuthentication bit = 1;
exec sp_addlogreader_agent 
	@job_login = '$(AgentUsername)', 
	@job_password = '$(AgentPassword)',
	@publisher_security_mode = @WindowsIntegratedAuthentication;