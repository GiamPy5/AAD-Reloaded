//	AAD Reloaded - "AAD Reloaded is an Attack and Defense gamemode written in PAWN for the SA:MP modification."

main() { }

//	REVISION:
	#define 	GAMEMODE_VERSION 				"0.0.1"
	#define		GAMEMODE_STAGE					"PRE-ALPHA"

//	LAST UPDATE: (Times are written in GMT +1)
	#define		LAST_UPDATE 					"08-AUG-2013 18:13"
					
// 	INCLUDES:
	#include 	<a_samp>
	#include 	<sqlitei>
	#include 	<sscanf2>
	#include 	<streamer>
	#include 	<zcmd>
	#include    <YSI\y_iterate>
					
//	PRE-PROCESSOR DEFINES:
	#undef 		MAX_PLAYERS
	#define 	MAX_PLAYERS						40 // Specify the amount of your server slots.
					
	#undef		MAX_VEHICLES
	#define 	MAX_VEHICLES					120 // Specify the amount of vehicles that may be spawned - usually it's three times the MAX_PLAYERS variable.
					
	#define 	MAX_BASES						10 // Currently only 10 bases may be loaded in the gamemode.
					
	#define		GAMEMODE_TEXT					"AAD Reloaded "GAMEMODE_VERSION""
	#define 	GAMEMODE_DEBUG					1
	#define 	GAMEMODE_FOLDER					"AAD-R/"
	
	#define 	STATUS_IDLE						0
	#define 	STATUS_DEATHMATCH				1
	#define 	STATUS_PLAYING					2
	
//	DIALOGS:
	#define 	DIALOG_ACCOUNT_REGISTER 		0
	#define 	DIALOG_ACCOUNT_LOGIN			1	
					
//	FORWARDS:
//	N/A

// 	NATIVES:
	native 		WP_Hash(buffer[], len, const str[]);
	
//	STRUCTURES:

enum playerStructure {
	pDatabaseID,
	pAdminLevel,
	pTotalKills,
	pTotalDeaths,
	pSessionKills,
	pSessionDeaths,
	
	bool: pStatus,	
	// Player statuses are the following ones:
	// STATUS_IDLE - used when the player is not into a /dm and is not playing a base / arena.
	// STATUS_DEATHMATCH - used when the player is into a /dm.
	// STATUS_PLAYING - used when the player is playign in a base / arena.
	
	Text3D: pInfoLabel, // Containing FPS, Ping and Packet Loss information of the player.
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

enum serverStructure {
	sHostname[128],
	sRoundPlaying, // Contains the current base / arena ID.
	sRoundType, // Contains the round type: base or arena.
	sAtkSkin,
	sDefSkin,
	bool: sRoundPaused,
	bool: sActiveRound,
	Float: sMainSpawn[4],
};

	new playerVariables[MAX_PLAYERS][playerStructure];
	new baseVariables[MAX_BASES][baseStructure];
	new serverVariables[serverStructure];

//	GLOBAL VARIABLES:
	new			globalString[128];
	new			globalDialog[2048];
	new			globalQuery[2048];
	
//	PUBLICS:

public OnGameModeInit() {

	#if GAMEMODE_DEBUG == 1
		print("DEBUG: \"OnGameModeInit()\" executed.");
	#endif
	
	// Setting the GameModeText for the server browser.
	SetGameModeText(GAMEMODE_TEXT);
	#if GAMEMODE_DEBUG == 1
		print("DEBUG: GameModeText set to \""GAMEMODE_TEXT"\".");
	#endif		
	
	// Retrieving the current hostname and storing it under serverVariables[sHostname].
	GetServerVarAsString("hostname", serverVariables[sHostname], 128);
	
	// Formatting the RCON command to change the hostname.
	format(globalString, sizeof(globalString), "hostname %s ["GAMEMODE_STAGE"]", serverVariables[sHostname]);
	
	// Executing the RCON command (es. hostname Server Name [PRE-ALPHA]).
	SendRconCommand(globalString);	
	#if GAMEMODE_DEBUG == 1
		printf("DEBUG: Server Hostname set to \"%s ["GAMEMODE_STAGE"]\".", serverVariables[sHostname]);
	#endif
	
	if(!fexist(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db")) {
	
		#if GAMEMODE_DEBUG == 1
			print("DEBUG: The database \""GAMEMODE_FOLDER"Database/AAD-Reloaded.db\" does not exist, creating..");
		#endif
		
		new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db");
		
		// Creating the table 'accounts' and adding the colums 'account_id', 'account_name', 'account_password', 'account_kills' and 'account_deaths'.
		db_exec(gamemodeDatabase, "CREATE TABLE IF NOT EXISTS `accounts` (`account_id` INTEGER PRIMARY KEY NOT NULL UNIQUE)");
		db_exec(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_name` VARCHAR");
		db_exec(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_password` VARCHAR");
		db_exec(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_kills` INTEGER NOT NULL DEFAULT 0");
		db_exec(gamemodeDatabase, "ALTER TABLE `accounts` ADD `account_deaths` INTEGER NOT NULL  DEFAULT 0");
		
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
		
		db_close(gamemodeDatabase);
	}
	
	AddPlayerClass(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
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
	
	format(globalString, sizeof(globalString), "{FFFFFF}* {DAE3DF}%s{FFFFFF} has joined the server.",  playerName(playerid));
	SendClientMessageToAll(-1, globalString);
	
	format(globalString, sizeof(globalString), "* {FFFFFF}Welcome in the server, {DAE3DF}%s{FFFFFF}.",  playerName(playerid));
	SendClientMessage(playerid, -1, globalString);
	
	new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db");		

	new DBStatement: databaseStatement = db_prepare(gamemodeDatabase, "SELECT `account_name` FROM `accounts` WHERE `account_name` = ?");
	stmt_bind_value(databaseStatement, 0, DB::TYPE_STRING, playerName(playerid));
	
	if(stmt_execute(databaseStatement)) {
	
		if(!stmt_rows_left(databaseStatement)) {
		
			format(globalDialog, sizeof(globalDialog), "{FFFFFF}In order to play in \"{DAE3DF}%s{FFFFFF}\" you must register an account.\nPlease, insert the password for your new account below:", serverVariables[sHostname]);
			ShowPlayerDialog(playerid, DIALOG_ACCOUNT_REGISTER, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Registration", globalDialog, "Register", "Quit");
			
		} else {
		
			format(globalDialog, sizeof(globalDialog), "{FFFFFF}This account already exists, if this is not yours please quit and change your nickname.\n\nIn order to play in \"{DAE3DF}%s{FFFFFF}\" you must login in your account.\nPlease, insert the password of your account:", serverVariables[sHostname]);
			ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Login", globalDialog, "Login", "Quit");

		}
	}
	
	stmt_close(databaseStatement);
	db_close(gamemodeDatabase);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {

	#if GAMEMODE_DEBUG == 1
		printf("DEBUG: \"OnPlayerDisconnect(%d, %d)\" executed.", playerid, reason);
	#endif
	
	switch(reason) {
		case 0: format(globalString, sizeof(globalString), "{FFFFFF}* {DAE3DF}%s{FFFFFF} has left the server (crashed).",  playerName(playerid));
		case 1: format(globalString, sizeof(globalString), "{FFFFFF}* {DAE3DF}%s{FFFFFF} has left the server (disconnected).",  playerName(playerid));
		case 2: format(globalString, sizeof(globalString), "{FFFFFF}* {DAE3DF}%s{FFFFFF} has left the server (kicked/banned).",  playerName(playerid));		
	}
	
	SendClientMessageToAll(-1, globalString);	
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	switch(dialogid) {
	
		case DIALOG_ACCOUNT_REGISTER: {
		
			if(response) {
		
				if(isnull(inputtext)) {
				
					format(globalDialog, sizeof(globalDialog), "{FF0000}You must insert a password.\n\n{FFFFFF}In order to play in \"{DAE3DF}%s{FFFFFF}\" you must register an account.\nPlease, insert the password for your new account below:", serverVariables[sHostname]);
					ShowPlayerDialog(playerid, DIALOG_ACCOUNT_REGISTER, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Registration", globalDialog, "Register", "Quit");				
					return 1;
				}
			
				new localHashedPassword[129];
				
				WP_Hash(localHashedPassword, sizeof(localHashedPassword), inputtext);
				
				new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db");
				
				new DBStatement: databaseStatement = db_prepare(gamemodeDatabase, "INSERT INTO `accounts` (`account_name`, `account_password`) VALUES(?, ?)");
				stmt_bind_value(databaseStatement, 0, DB::TYPE_STRING, playerName(playerid));
				stmt_bind_value(databaseStatement, 1, DB::TYPE_STRING, localHashedPassword);				
				stmt_execute(databaseStatement);			
				stmt_close(databaseStatement);
				
				db_close(gamemodeDatabase);
				
				format(globalString, sizeof(globalString), "* {FFFFFF}You've registered the account \"{7EEDC0}%s{FFFFFF}\", please login.",  playerName(playerid));
				SendClientMessage(playerid, -1, globalString);
				
				format(globalDialog, sizeof(globalDialog), "{FFFFFF}Please, insert the password of your account:", serverVariables[sHostname]);
				ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Login", globalDialog, "Register", "Quit");				
				
			}
			else
				Kick(playerid);				
				
			return 1;
		}
		
		case DIALOG_ACCOUNT_LOGIN: {
		
			if(response) {
			
				if(isnull(inputtext)) {
				
					format(globalDialog, sizeof(globalDialog), "{FF0000}You must insert a password.\n\n{FFFFFF}This account already exists, if this is not yours please quit and change your nickname.\n\nIn order to play in \"{DAE3DF}%s{FFFFFF}\" you must login in your account.\nPlease, insert the password of your account:", serverVariables[sHostname]);
					ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Login", globalDialog, "Register", "Quit");	
					return 1;
				}
				
				new localHashedPassword[129];
				
				WP_Hash(localHashedPassword, sizeof(localHashedPassword), inputtext);
				
				new DB: gamemodeDatabase = db_open(""GAMEMODE_FOLDER"Database/AAD-Reloaded.db");
				
				format(globalQuery, sizeof(globalQuery), "SELECT `account_name` FROM `accounts` WHERE `account_name` = '%s' AND `account_password` = '%s'", playerName(playerid), localHashedPassword);
				new DBResult: queryResult = db_query(gamemodeDatabase, globalQuery);
				
				if (!db_num_rows(queryResult)) {
				
					format(globalDialog, sizeof(globalDialog), "{FF0000}The password is wrong.\n\n{FFFFFF}This account already exists, if this is not yours please quit and change your nickname.\n\nIn order to play in \"{DAE3DF}%s{FFFFFF}\" you must login in your account.\nPlease, insert the password of your account:", serverVariables[sHostname]);
					ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "{FFFFFF}Account Login", globalDialog, "Login", "Quit");

				} else {

					db_get_field_assoc(queryResult, "account_id", playerVariables[playerid][pDatabaseID]);
					db_get_field_assoc(queryResult, "account_kills", playerVariables[playerid][pTotalKills]);
					db_get_field_assoc(queryResult, "account_deaths", playerVariables[playerid][pTotalDeaths]);
					
					SendClientMessage(playerid, -1, "* {FFFFFF}You've successfully logged in your account.");					
					
					// TODO: Create the team selection code.
				
				}
			}
			else
				Kick(playerid);
				
			return 1;
		}
	}
	
	return 0;
}

//	STOCKS:

stock playerName(playerid) {

	#if GAMEMODE_DEBUG == 1
		printf("DEBUG: \"playerName(%d)\" executed.", playerid);
	#endif

	new localName[MAX_PLAYER_NAME+1];
	
	GetPlayerName(playerid, localName, sizeof(localName));	
	return localName;
}