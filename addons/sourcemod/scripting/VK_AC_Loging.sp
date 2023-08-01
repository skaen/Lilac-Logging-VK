#include <vkcore> 
#pragma semicolon 1
#pragma newdecls required

// Максимальная длина сообщения VK
#define MAX_LENGTH_MESSAGE 2048

#define CHEAT_AIMBOT   5
#define CHEAT_AIMLOCK  6

char g_sServerName[128];
int g_iPID;

public Plugin myinfo =
{
	name 		= "VK AC Loging",
	author 		= "skaen",
	version 	= "1.0.5",
	description = "Send Lilac Detections notifications to vk",
	url 		= "https://hszn.ru"
};
public void OnPluginStart()
{
	LoadTranslations("VK_Loging_AC.phrases");
}

public void OnConfigsExecuted()
{
	ReadConfig();
}

void ReadConfig()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/vkontakte/VK_Loging_AC.ini");
	KeyValues kv = new KeyValues("LogingAC");
	
	if (kv.ImportFromFile(sPath))
	{
		kv.GetString("ServerName", g_sServerName, sizeof(g_sServerName));
		g_iPID = kv.GetNum("PID", -1);
		if (g_iPID == -1) { SetFailState("[VK LogingAdmin] KeyValues Error: invalid or not set PID!"); }
		kv.Rewind();
	}
	else SetFailState("[VK LogingAdmin] KeyValues Error!");
	
	delete kv;
}
public Action lilac_cheater_detected(int client, int cheat)
{
	// Name + Formated Text
	static char szMessage[MAX_LENGTH_MESSAGE], sName[64];
	GetClientName(client, sName, sizeof(sName));

	// Client details
	char type[16], clientAuth[64], cIP[24], cDetails[240];
	GetClientIP(client, cIP, sizeof(cIP));
	if(!GetClientAuthId(client, AuthId_Steam2, clientAuth, sizeof(clientAuth)))
		strcopy(clientAuth, sizeof(clientAuth), "No SteamID");
	
	FormatEx(cDetails, sizeof(cDetails), "%s | %s", clientAuth, cIP);
	switch (cheat) {
		case CHEAT_AIMBOT: { strcopy(type, sizeof(type), "Aimbot"); }
		case CHEAT_AIMLOCK: { strcopy(type, sizeof(type), "Aimlock"); }
		/* Macros have their own warning system. */
		default: { return Plugin_Continue; }
	}
	
	FormatEx(szMessage, sizeof(szMessage), "`%s` [ %s ] подозревается в использовании чита %s ", sName, cDetails, type);
	
	
	PreSendReport(client, szMessage);
	
	return Plugin_Continue;
}

void PreSendReport(int iClient, char[] sText)
{
	char sSteam[64], sClient_URL[128], sMessage[MAX_LENGTH_MESSAGE];
	char sClient_Name[MAX_NAME_LENGTH];
	
	sMessage = "";	
	GetClientName(iClient, sClient_Name, sizeof(sClient_Name));
	GetClientAuthId(iClient, AuthId_SteamID64, sSteam, sizeof(sSteam), true);
	Format(sClient_URL, sizeof(sClient_URL), "https://steamcommunity.com/profiles/%s", sSteam);
	
	Format(sMessage, sizeof(sMessage), "%T", "AntiCheat", iClient, g_sServerName, sClient_Name, sClient_URL, sText);
	//LogMessage(sMessage);
	VK_MessagesSend(g_iPID, sMessage);
}