# 坦克或女巫出现时根据生还者人数增加血量



1. 第142行 `public void Event_TankSpawn()` 方法中，将 `EmitSoundToAll(TankSound);` 提到方法的最开头，以便安装了此插件后，即使配置文件中 “根据生还者人数自动设定tank血量” 为关闭状态，也能在tank生成时发出声音以警告生还者tank已生成。

```c
public void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	EmitSoundToAll(TankSound);//给所有玩家播放声音.
	
	if (g_iTankSwitch == 0)
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (IsValidTank(client))
	{
		for (int i = 0; i < iArray; i++)
			if (StrEqual(GetGameDifficulty(), g_sDifficultyCode[i], false))
				SetTankHealth(client, g_fMultiples[0][i] == 0 ? 1.0 : g_fMultiples[0][i], g_sDifficultyName[i]);
	}
}
```





---

2. 修复了此插件在对抗模式下，tank血量也被设置为了4000的bug（对抗模式tank血量默认为6000）。

修复前，在游玩对抗模式时，当tank生成后，双方玩家均发现tank血量竟然只有4000，并纷纷在聊天窗口打出了问号“？”

此次修复解决了此问题。

第169行 `void SetClientHealth()` 方法中，新增了对当前模式的判断，如果当前游戏模式为 “对抗模式” 或 “清道夫模式”，则此插件不修改tank和witch的血量。

```c
void SetClientHealth(int client, int iHealth)
{
	char sGameMode[32];
	g_cvGameMode.GetString(sGameMode, sizeof sGameMode);
	if (StrContains(sGameMode, "versus") > -1 || StrContains(sGameMode, "scavenge") > -1)
		return;
	
	SetEntProp(client, Prop_Data, "m_iHealth", iHealth);
	SetEntProp(client, Prop_Data, "m_iMaxHealth", iHealth);
}
```





---

3. 将 `void SetClientHealth()` 方法中设置Tank、女巫血量的逻辑颠倒，先设置最大血量，再设置当前血量，以免出现bug。

```c
void SetClientHealth(int client, int iHealth)
{
	......
	
	// 先设置最大血量，再设置当前血量
	SetEntProp(client, Prop_Data, "m_iMaxHealth", iHealth);
	SetEntProp(client, Prop_Data, "m_iHealth", iHealth);
}
```

