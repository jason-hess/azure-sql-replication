# 
# Summary: Configure the Log Reader Agent.  
#
# Background: The Replication Log Reader Agent is an executable that monitors the transaction log of each database 
#             configured for transactional replication and copies the transactions marked for replication from the 
#             transaction log into the distribution database.
#
# Note: Because the `sys.sp_addlogreader_agent` requires the Username and Password of the agent, this script has
#       been written so that those values are not stored in source control.  The intent of this script is to be
#       run on the Developer environment.
#

$scriptRoot = $PSScriptRoot

$agentUsername = Read-Host 'Log Reader Agent Username'
$agentPasswordAsSecureString = Read-Host 'Log Reader Agent Password' -AsSecureString

$agentPasswordAsBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($agentPasswordAsSecureString)            
$agentPasswordAsNotSecureString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($agentPasswordAsBSTR)        

$sqlcmdExe = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.exe'
$useTrustedConnection = '-E'
& $sqlcmdExe -v AgentUsername=$agentUsername -v AgentPassword=$agentPasswordAsNotSecureString -i "$scriptRoot\03-configure-agent.sql" $useTrustedConnection -S .