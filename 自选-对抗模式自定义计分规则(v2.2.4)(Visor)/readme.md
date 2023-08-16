# 对抗模式自定义计分规则



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_hybrid_scoremod_zone.sp



修复了Left4DHooks更新后，要求 `L4D_GetVersusMaxCompletionScore()` 方法必须在 `OnMapStart()` 方法被调用后才可调用，否则报错。

将调用了 `L4D_GetVersusMaxCompletionScore()` 方法的逻辑放至 `player_left_start_area` 事件所绑定的方法中。从而可保证 `L4D_GetVersusMaxCompletionScore()` 方法一定会在 `OnMapStart()` 方法之后才会被执行。

```c
public OnPluginStart()
{
    ......

    HookEvent("player_left_start_area", OnPlayerLeftStartArea, EventHookMode_PostNoCopy);
    
    ......
}

public void OnPlayerLeftStartArea(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
    CalculateBonus();

    iLostTempHealth[0] = 0;
    iLostTempHealth[1] = 0;
    iSiDamage[0] = 0;
    iSiDamage[1] = 0;
    bTiebreakerEligibility[0] = false;
    bTiebreakerEligibility[1] = false;
    
    for (new i = 0; i <= MAXPLAYERS; i++)
    {
        iTempHealth[i] = 0;
    }
    bRoundOver = false;
}

public void CalculateBonus()
{
    ......

    iMapDistance = L4D2_GetMapValueInt("max_distance", L4D_GetVersusMaxCompletionScore());
    
    ......
}
```

