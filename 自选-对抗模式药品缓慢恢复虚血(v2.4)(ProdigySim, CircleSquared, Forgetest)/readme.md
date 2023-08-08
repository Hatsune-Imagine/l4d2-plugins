# 对抗模式药品缓慢恢复虚血



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4dhots.sp



**注意：其配置文件 `l4dhots.cfg` 需要在服务器配置文件中执行才可生效**

例：在 `server.cfg` 中添加

```bash
//对抗模式药品缓慢恢复虚血
exec l4dhots.cfg
```



嫖自ZoneMod，并作出了部分修改。

1. 原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式判断的，使得其只在 “对抗模式” 和 “清道夫模式” 中生效。

```c
public void OnMapStart()
{
    g_aHOTPair.Clear();

    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);
    if (StrContains(sGameMode, "versus") > -1 || StrContains(sGameMode, "scavenge") > -1)
    {
        if (hCvarPillHot.BoolValue) EnablePillHot();
        if (g_bLeft4Dead2 && hCvarAdrenHot.BoolValue) EnableAdrenHot();
    }
    else
    {
        if (hCvarPillHot.BoolValue) DisablePillHot();
        if (g_bLeft4Dead2 && hCvarAdrenHot.BoolValue) DisableAdrenHot();
    }
}
```



2. 修复了此插件的一个bug，在 `DisablePillHot()` 和 `DisableAdrenHot()` 方法中，分别调用了 `SwitchGeneralEventHooks()`、

   `SwitchPillHotEventHook()`、

   `SwitchAdrenHotEventHook()` 

   这3个方法。但是却均设为了 `true` ，因此导致一个bug。当调用 `DisablePillHot()` 和 `DisableAdrenHot()` 方法后，仍然会有缓慢恢复虚血量的效果。

   本次修复了此bug。

```c
void DisablePillHot()
{
    pain_pills_health_value.Flags &= FCVAR_REPLICATED;
    pain_pills_health_value.RestoreDefault();
    
    SwitchGeneralEventHooks(false);
    SwitchPillHotEventHook(false);
}

void DisableAdrenHot()
{
    adrenaline_health_buffer.Flags &= FCVAR_REPLICATED;
    adrenaline_health_buffer.RestoreDefault();
    
    SwitchGeneralEventHooks(false);
    SwitchAdrenHotEventHook(false);
}
```

