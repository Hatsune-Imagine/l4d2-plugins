# 对抗模式去除汽油桶,丙烷罐,氧气罐,烟花盒



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d_no_cans.sp



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

```c
public void Event_RoundStart(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);
    if (StrContains(sGameMode, "versus") == -1)
        return;

    ......
}
```

