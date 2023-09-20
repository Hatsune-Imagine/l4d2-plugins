# 对抗模式Spitter部分地图位置痰液免伤



原作者来源：

https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_spitblock.sp



**注意：其配置文件 `spitblock.cfg` 需要在服务器配置文件中执行才可生效**

例：在 `server.cfg` 中添加

```bash
// 执行对抗模式部分地图位置痰液免伤配置文件
exec spitblock.cfg
```



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

```c
public void OnMapStart()
{
    char sGameMode[32];
    FindConVar("mp_gamemode").GetString(sGameMode, sizeof sGameMode);

    ......
    
    if (StrContains(sGameMode, "versus") > -1 && g_hSpitBlockSquares.GetArray(sMapName, g_fBlockSquare, sizeof(g_fBlockSquare))) {
        g_bIsBlockEnable = true;
        return;
    }
    
    ......
}
```

