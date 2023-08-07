# 对抗模式玩家离开安全区域后给予物品



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/83f547e2d941ee1fb63409dbfb594653e0fe1f43/addons/sourcemod/scripting/starting_items.sp



**注意：其配置文件 `starting_items.cfg` 需要在服务器配置文件中执行才可生效**

例：在 `server.cfg` 中添加

```bash
// 执行对抗模式玩家离开安全区域后给予物品配置文件
exec starting_items.cfg
```



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式判断的，使得其只在 “对抗模式” 中生效。

```c
public void OnMapStart()
{
    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);
    if (StrContains(sGameMode, "versus") > -1)
    {
        PluginEnable();
    }
    else
    {
        PluginDisable();
    }
}
```

