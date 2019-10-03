#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>

public Plugin myinfo = 
{
	name = "Bot manager",
	author = "koraydemirci86@gmail.com",
	description = "Bot manager plugin",
	version = SOURCEMOD_VERSION,
	url = "http://www.insurgency.online/"
};

int g_iBotCount = 0; // Global bot count variable

public void OnConfigsExecuted()
{
	g_iBotCount = 0;
	
	int iTotalClient = GetClientCount(false);
	int iReqBotCount = 12 - iTotalClient;
	LogAction(0, -1, "OnConfigsExecuted: Client count: %d Req bot count: %d", iTotalClient, iReqBotCount);

	Handle hHibernateCVar = FindConVar("sv_hibernate_when_empty");
	if (hHibernateCVar == INVALID_HANDLE)
	{
		LogAction(0, -1, "OnConfigsExecuted: sv_hibernate_when_empty convar could not found!");
		return;
	}
	SetConVarInt(hHibernateCVar, 0); // disable hibernate
		
	if (iTotalClient < 12)
	{
		char szReply[512];
		ServerCommandEx(szReply, sizeof(szReply), "ins_bot_add 0"); // HACK: Force load for NavMesh; 'INSNextBot - NavMesh exists but not currently loaded.'
		LogAction(0, -1, "OnConfigsExecuted: 1- Bot add cmd reply: %s", szReply);		
		
		ServerCommandEx(szReply, sizeof(szReply), "ins_bot_add %d", iReqBotCount); // Add real required bots
		LogAction(0, -1, "OnConfigsExecuted: 2- Bot add cmd reply: %s", szReply);		
	}
}

public void OnClientAuthorized(int client, const char[] auth)
{
	int iTotalClient = GetClientCount(false);
	LogAction(0, -1, "OnClientConnected: %d(%s) | Total: %d", client, auth, iTotalClient);
	
	// bot
	if (IsFakeClient(client)) 
	{
		g_iBotCount++;
		return;
	}
	
	// player
	if (iTotalClient > 12)
	{
		char szReply[512];
		ServerCommandEx(szReply, sizeof(szReply), "ins_bot_kick 1");
		LogAction(0, -1, "Bot kick cmd reply: %s", szReply);
	}
}

public void OnClientDisconnect(int client)
{
	int iTotalClient = GetClientCount(false);
	LogAction(0, -1, "OnClientDisconnect: %d | Total: %d", client, iTotalClient);
	
	// bot
	if (IsFakeClient(client))
	{
		g_iBotCount--;
		
		if (!g_iBotCount && iTotalClient < 12) // when all bots kicked at 'GR_STATE_PREROUND' begin state
		{
			int iReqBotCount = 12 - iTotalClient;
			
			char szReply[512];
			ServerCommandEx(szReply, sizeof(szReply), "ins_bot_add %d", iReqBotCount);
			LogAction(0, -1, "OnClientDisconnect: Bot add cmd reply: %s", szReply);					
		}
		return;
	}
	
	// player
	if (iTotalClient < 12)
	{
		char szReply[512];
		ServerCommandEx(szReply, sizeof(szReply), "ins_bot_add 1");
		LogAction(0, -1, "Bot add cmd reply: %s", szReply);
	}
}
