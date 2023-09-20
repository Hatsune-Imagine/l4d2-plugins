# 对抗模式倒地马格南替换为小手枪



原作者来源：

https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_magnum_incap.sp



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

```c
public void OnMapStart() {
    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);
    if (StrContains(sGameMode, "versus") > -1)
        PluginEnable();
    else
        PluginDisable();
    
}

void PluginEnable() {
    if (!bHooked) {
        HookEvent("player_incapacitated", PlayerIncap_Event);
        HookEvent("revive_success", ReviveSuccess_Event);

        bHooked = true;
    }
}

void PluginDisable() {
    if (bHooked) {
        UnhookEvent("player_incapacitated", PlayerIncap_Event);
        UnhookEvent("revive_success", ReviveSuccess_Event);

        bHooked = false;
    }
}
```

