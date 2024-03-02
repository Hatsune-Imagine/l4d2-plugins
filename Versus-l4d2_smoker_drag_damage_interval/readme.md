# 对抗模式Smoker拖拽伤害间隔修改



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_smoker_drag_damage_interval_zone.sp



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式判断的，使得其只在 “对抗模式” 和 “清道夫模式” 中生效。

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

void PluginEnable()
{
    if (!bHooked)
    {
        HookEvent("tongue_grab", OnTongueGrab);
        bHooked = true;

        tongue_choke_damage_amount.AddChangeHook(tongue_choke_damage_amount_ValueChanged);
    }
}

void PluginDisable()
{
    if (bHooked)
    {
        UnhookEvent("tongue_grab", OnTongueGrab);
        bHooked = false;

        tongue_choke_damage_amount.RemoveChangeHook(tongue_choke_damage_amount_ValueChanged);
        ResetConVar(tongue_choke_damage_interval);
        ResetConVar(tongue_choke_damage_amount);
    }
}
```

