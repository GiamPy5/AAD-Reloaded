//				AAD Reloaded

main() { }

//				REVISION:
					#define 	GAMEMODE_VERSION 		"0.0.1"
					#define		GAMEMODE_STAGE			"PRE-ALPHA"

//				LAST UPDATE: (Times are written in GMT +1)
					#define		LAST_UPDATE 		"07-AUG-2013 23:35"
					
//				PRE-PROCESSOR DEFINES:
					#define		GAMEMODE_TEXT		"AAD Reloaded "GAMEMODE_VERSION""
					
// 				INCLUDES:
					#include 	<a_samp>
					#include    <a_zones>
					#include 	<a_mysql>
					#include 	<sscanf2>
					#include 	<streamer>
					#include 	<zcmd>
					#include    <YSI\y_iterate>
					
//				FORWARDS:
//				N/A
					
//				GLOBAL VARIABLES:		
					new			globalStringVar[128];
					
//				PUBLICS:

public OnGameModeInit() {

	// Setting the GameModeText for the server browser.
	SetGameModeText(GAMEMODE_TEXT);
	
	// Retrieving the current hostname and storing it under localServerHostname.
	new localServerHostname[128];
	
	GetServerVarAsString("hostname", localServerHostname, sizeof(localServerHostname));
	
	// Formatting the RCON command to change the hostname.
	format(globalStringVar, sizeof(globalStringVar), "hostname %s ["GAMEMODE_STAGE"]", localServerHostname);
	
	// Executing the RCON command (es. hostname Server Name [PRE-ALPHA]).
	SendRconCommand(globalStringVar);	
	return 1;
}