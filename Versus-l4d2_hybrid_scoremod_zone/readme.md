# 对抗模式自定义计分规则



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_hybrid_scoremod_zone.sp



修复了Left4DHooks更新后，要求 `L4D_GetVersusMaxCompletionScore()` 方法必须在 `OnMapStart()` 方法被调用后才可调用，否则报错。

将调用 `L4D_GetVersusMaxCompletionScore()` 方法的逻辑指定在 `OnMapStart()` 方法执行5秒后再执行。从而可保证 `L4D_GetVersusMaxCompletionScore()` 方法一定会在 `OnMapStart()` 方法之后才会被执行。

```c
void InitBonus()
{
    ......

    iMapDistance = L4D2_GetMapValueInt("max_distance", L4D_GetVersusMaxCompletionScore());
    
    ......
}

Action Timer_InitBonus(Handle timer, bool reset)
{
    InitBonus();

    if (reset) {
        iLostTempHealth[0] = 0;
        iLostTempHealth[1] = 0;
        iSiDamage[0] = 0;
        iSiDamage[1] = 0;
        bTiebreakerEligibility[0] = false;
        bTiebreakerEligibility[1] = false;
    }

    return Plugin_Continue;
}

public OnMapStart()
{
    CreateTimer(5.0, Timer_InitBonus, true);
}

public CvarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
    CreateTimer(5.0, Timer_InitBonus, false);
}
```

