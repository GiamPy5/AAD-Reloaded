//				AAD Reloaded - "AAD Reloaded is an Attack and Defense gamemode written in PAWN for the SA:MP modification."

main() { }

//				REVISION:
					#define 	GAMEMODE_VERSION 		"0.0.1"
					#define		GAMEMODE_STAGE			"PRE-ALPHA"

//				LAST UPDATE: (Times are written in GMT +1)
					#define		LAST_UPDATE 		"07-AUG-2013 23:35"
					
// 				INCLUDES:
					#include 	<a_samp>
					#include 	<sqlitei>
					#include 	<sscanf2>
					#include 	<streamer>
					#include 	<zcmd>
					#include    <YSI\y_iterate>					
					
//				PRE-PROCESSOR DEFINES:
					#undef 		MAX_PLAYERS
					#define 	MAX_PLAYERS			40 // Specify the amount of your server slots.
					
					#undef		MAX_VEHICLES
					#define 	MAX_VEHICLES		120 // Specify the amount of vehicles that may be spawned - usually it's three times the MAX_PLAYERS variable.
					
					#define 	MAX_BASES			10 // Currently only 10 bases may be loaded in the gamemode.
					
					#define		GAMEMODE_TEXT		"AAD Reloaded "GAMEMODE_VERSION""
					#define 	GAMEMODE_DEBUG		1
					#define 	GAMEMODE_FOLDER		"AAD-R/"
					
//				FORWARDS:
//					N/A
	
//				STRUCTURES:

enum playerStructure {
	pAdminLevel,
	pTotalKills,
	pTotalDeaths,
	pSessionKills,
	pSessionDeaths,
	Text3D: pInfoLabel, // Con
	Float: pHealth,
	Float: pArmour
};

enum baseStructure {
	bDatabaseID,
	bTimesPlayed,
	bName[64],
	Float: bAtkSpawn[4], // Attack team spawn.
	Float: bDefSpawn[4], // Defense team spawn.
	Float: bCheckSpawn[3] // Checkpoint spawn.
};

					new playerVariables[MAX_PLAYERS][playerStructure];
					new baseVariables[MAX_BASES][baseStructure];

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
	
	if(!fexist(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db")) {
	
		#if GAMEMODE_DEBUG == 1
			printf("DEBUG: The database \""GAMEMODE_FOLDER"Database/AAD-Reloaded.db\" does not exist, creating..", localServerHostname);
		#endif
		
		new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db");
		
		// Creating the table 'accounts' and adding the colums 'account_id', 'account_name', 'account_password', 'account_kills' and 'account_deaths'.
		db_query(gamemodeDatabase, "CREATE TABLE IF NOT EXISTS `accounts` (`account_id` INTEGER PRIMARY KEY NOT NULL UNIQUE)");
		db_query(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_name` VARCHAR");
		db_query(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_password` VARCHAR");
		db_query(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_kills` INTEGER NOT NULL DEFAULT 0");
		db_query(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_deaths` INTEGER NOT NULL  DEFAULT 0");
		
		if(!fexist(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db")) {
		
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