# 对抗模式尸潮规模修改



原作者来源：

- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_horde_equaliser.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2lib.sp



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

```c
public void OnEntityCreated(int entity, const char[] classname)
{
    if (!L4D_IsVersusMode()) {
        return;
    }
    
    ......
}
```

```c
public Action L4D_OnSpawnMob(int &amount)
{
    if (!L4D_IsVersusMode()) {
        return Plugin_Continue;
    }
    
    ......
}
```

