//				AAD Reloaded

main() { }

//				REVISION:
					#define 	GAMEMODE_VERSION 		"0.0.1"
					#define		GAMEMODE_STAGE			"PRE-ALPHA"

//				LAST UPDATE: (Times are written in GMT +1)
					#define		LAST_UPDATE 		"07-AUG-2013 23:35"
					
//				PRE-PROCESSOR DEFINES:
					#define		GAMEMODE_TEXT		"AAD Reloaded "GAMEMODE_VERSION""
					#define 	GAMEMODE_DEBUG		1
					#define 	GAMEMODE_FOLDER		"AAD-R/"
					
// 				INCLUDES:
					#include 	<a_samp>
					#include 	<sqlitei>
					#include 	<sscanf2>
					#include 	<streamer>
					#include 	<zcmd>
					#include    <YSI\y_iterate>
					
//				FORWARDS:
//					N/A
	
//				STRUCTURES:

enum playerStructure {
	pInfoLabel,
	pAdminLevel,
	Float: pHealth,
	Float: pArmour,
	pTotalKills,
	pTotalDeaths,
	pSessionKills,
	pSessionDeaths
};
	
//				GLOBAL VARIABLES:		
					new			globalStringVar[128];
					
//				PUBLICS:

public OnGameModeInit() {

	#if GAMEMODE_DEBUG == 1
		print("DEBUG: \"OnGameModeInit()\" executed.");
	#endif
	
	// Setting the GameModeText for the server browser.
	SetGameModeText(GAMEMODE_TEXT);
	#if GAMEMODE_DEBUG == 1
		print("DEBUG: GameModeText set to \""GAMEMODE_TEXT"\".");
	#endif		
	
	// Retrieving the current hostname and storing it under localServerHostname.
	new localServerHostname[128];
	
	GetServerVarAsString("hostname", localServerHostname, sizeof(localServerHostname));
	
	// Formatting the RCON command to change the hostname.
	format(globalStringVar, sizeof(globalStringVar), "hostname %s ["GAMEMODE_STAGE"]", localServerHostname);
	
	// Executing the RCON command (es. hostname Server Name [PRE-ALPHA]).
	SendRconCommand(globalStringVar);	
	#if GAMEMODE_DEBUG == 1
		printf("DEBUG: Server Hostname set to \"%s ["GAMEMODE_STAGE"]\".", localServerHostname);
	#endif
	
	if(!fexist(""GAMEMODE_FOLDER"AAD-Reloaded.db")) {
	
		#if GAMEMODE_DEBUG == 1
			printf("DEBUG: The database \""GAMEMODE_FOLDER"AAD-Reloaded.db\" does not exist, creating..", localServerHostname);
		#endif
		
		new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"AAD-Reloaded.db");
		db_query(gamemodeDatabase, "CREATE TABLE `accounts` IF NOT EXISTS \
								(`account_id` INTEGER PRIMARY KEY  NOT NULL  UNIQUE , \
								`account_name` VARCHAR, \
								`account_password` VARCHAR, \
								`account_kills` INTEGER NOT NULL  DEFAULT 0, \
								`account_deaths` INTEGER NOT NULL  DEFAULT 0)");

		if(!fexist(""GAMEMODE_FOLDER"AAD-Reloaded.db")) {
		
			#if GAMEMODE_DEBUG == 1
				print("DEBUG: The database \""GAMEMODE_FOLDER"AAD-Reloaded.db\" has failed to create - maybe the folder does not exist.");
				print("DEBUG: Gamemode terminated.");
			#endif
			
			SendRconCommand("exit");
			
		} else {
		
			#if GAMEMODE_DEBUG == 1
				print("DEBUG: The database \""GAMEMODE_FOLDER"AAD-Reloaded.db\" has been created.");
			#endif
			
		}
	}
	return 1;
}

public OnGameModeExit() {

	#if GAMEMODE_DEBUG == 1
		print("DEBUG: \"OnGameModeExit()\" executed.");
	#endif	
	return 1;
}

public OnPlayerConnect(playerid) {

	#if GAMEMODE_DEBUG == 1
		printf("DEBUG: \"OnPlayerConnect(%d)\" executed.", playerid);
	#endif
	return 1;
}