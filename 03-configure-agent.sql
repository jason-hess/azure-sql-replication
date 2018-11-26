/* 

Summary: Configure the Log Reader Agent

The Replication Log Reader Agent is an executable that monitors the transaction log of each database 
configured for transactional replication and copies the transactions marked for replication from the 
transaction log into the distribution database.

Note: This script requires the $(AgentUsername) and $(AgentPassword) variables to be passed in

*/

set nocount on;
set xact_abort on;

use master;

--
-- Configure Log Reader Agent
--

declare @WindowsIntegratedAuthentication bit = 1;
exec sp_addlogreader_agent 
	@job_login = '$(AgentUsername)', 
	@job_password = '$(AgentPassword)',
	@publisher_security_mode = @WindowsIntegratedAuthentication;