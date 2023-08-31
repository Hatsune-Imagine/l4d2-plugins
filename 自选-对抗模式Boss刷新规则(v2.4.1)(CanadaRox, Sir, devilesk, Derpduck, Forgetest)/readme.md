# 对抗模式Boss刷新规则



原作者来源：

- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/witch_and_tankifier.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/eq_finale_tanks.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d_boss_percent.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/current.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2lib.sp



**注意：其配置文件 `witch_and_tankifier.cfg` 需要在服务器配置文件中执行才可生效**

例：在 `server.cfg` 中添加

```bash
// 执行对抗模式模式Boss刷新规则配置文件
exec witch_and_tankifier.cfg
```



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

- `witch_and_tankifier.sp`

```c
public Action AdjustBossFlow(Handle timer) {
    if (L4D_GetGameModeType() != 2) {
        return Plugin_Stop;
    }
    
    ......
}
```

