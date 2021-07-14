#include <sourcemod>
#include <discord>

char WebHook[512];
ConVar Webhook = null;

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Discord Not Alma", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_not", Command_Not, ADMFLAG_CHAT, "");
	Webhook = CreateConVar("dc_not_webhook", "XXXXXXXXX", "");
	Webhook.GetString(WebHook, 512);
	Webhook.AddChangeHook(WebHookChanged);
	AutoExecConfig(true, "Discord-Not", "ByDexter");
}

public void WebHookChanged(ConVar cvar, const char[] oldVal, const char[] newVal)
{
	Webhook.GetString(WebHook, 512);
}

public Action Command_Not(int client, int args)
{
	char not[256], safename[128], steamid[128], format[512], out[128];
	
	GetCmdArgString(not, 256);
	
	GetClientName(client, safename, 128);
	
	GetClientAuthId(client, AuthId_Steam2, steamid, 128);
	
	GetCommunityID(steamid, out, 128);
	Format(out, 128, "http://steamcommunity.com/profiles/%s", out);
	
	DiscordWebHook hook = new DiscordWebHook(WebHook);
	hook.SlackMode = true;
	
	Format(format, 512, "%s - %s", safename, steamid);
	hook.SetUsername(format);
	hook.SetAvatar("https://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/b8/b80dd994a92a7ce5fdd5ab564be0831da30fddb5_full.jpg");
	
	MessageEmbed Embed = new MessageEmbed();
	
	Embed.SetColor("#bf42f5");
	Embed.SetTitle(not);
	Embed.SetAuthorIcon("https://cdn.discordapp.com/attachments/619577045982380052/864969030229032960/google-messages.png");
	Embed.SetAuthor("Bir yetkili not aldı !");
	Embed.SetTitleLink(out);
	Embed.SetFooter("-ByDexter");
	
	hook.Embed(Embed);
	hook.Send();
	delete hook;
	return Plugin_Handled;
}

bool GetCommunityID(char[] AuthID, char[] FriendID, int size)
{
	if (strlen(AuthID) < 11 || AuthID[0] != 'S' || AuthID[6] == 'I')
	{
		FriendID[0] = 0;
		return false;
	}
	int iUpper = 765611979;
	int iFriendID = StringToInt(AuthID[10]) * 2 + 60265728 + AuthID[8] - 48;
	int iDiv = iFriendID / 100000000;
	int iIdx = 9 - (iDiv ? iDiv / 10 + 1:0);
	iUpper += iDiv;
	IntToString(iFriendID, FriendID[iIdx], size - iIdx);
	iIdx = FriendID[9];
	IntToString(iUpper, FriendID, size);
	FriendID[9] = iIdx;
	return true;
} 