# 对抗模式防止速砍



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/fix_fastmelee.sp



嫖自ZoneMod，并作出了部分修改。

1. 将旧语法改为新语法

```c
#pragma semicolon 1
#pragma newdecls required
```



2. 原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 和 “清道夫模式”中生效

```c
public void OnMapStart()
{
    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);
    if (StrContains(sGameMode, "versus") > -1 || StrContains(sGameMode, "scavenge") > -1)
    {
        PluginEnable();
    }
    else
    {
        PluginDisable();
    }
}
```

