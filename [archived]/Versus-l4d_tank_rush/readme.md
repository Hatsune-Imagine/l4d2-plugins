# 对抗模式Tank生成时冻结生还者路程分



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d_tank_rush.sp



嫖自ZoneMod，并作出了部分修改。



1. 新增了对当前游戏模式的判断，仅在对抗模式启用此插件

```c
public void OnMapStart()
{
    ......

    if (cvar_noTankRush.BoolValue && L4D_GetGameModeType() == 2)
    {
        PluginEnable();
    }
    else
    {
        PluginDisable();
    }
}
```



2. 新增了简体中文和繁体中文的翻译文件