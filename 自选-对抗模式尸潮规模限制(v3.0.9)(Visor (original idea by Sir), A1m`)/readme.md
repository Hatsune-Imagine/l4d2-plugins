# 对抗模式尸潮规模修改



原作者来源：

- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_horde_equaliser.sp
- https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2lib.sp



嫖自ZoneMod，并作出了部分修改。

1. 原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

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



---

2. 修复了原作者写的bug，原作者的写法会导致机关尸潮事件发生时，有概率不触发尸潮限制的逻辑，从而造成尸潮仍为无限状态，本次修复了此bug。

修改前：

```c
public void OnEntityCreated(int entity, const char[] classname)
{
    ......

    // TO-DO: Find a value that tells wanderers from active event commons?
    if (strcmp(classname, "infected") == 0 && IsInfiniteHordeActive()) {
        ......
        
        // Our job here is done
        if (commonTotal >= commonLimit) {
            if (!announcedEventEnd){
                CPrintToChatAll("<{olive}Horde{default}> {red}No {default}common remaining!");
                announcedEventEnd = true;
            }
            return;
        }
        
        commonTotal++;
        if (......) {
            ......
            
            int remaining = commonLimit - commonTotal;
            if (remaining != 0) {
                CPrintToChatAll("<{olive}Horde{default}> {red}%i {default}common remaining..", remaining);
            }
            
            ......
        }
    }
}
```



修改后：

```c
public void OnEntityCreated(int entity, const char[] classname)
{
    ......

    // TO-DO: Find a value that tells wanderers from active event commons?
    if (strcmp(classname, "infected") == 0 && IsInfiniteHordeActive()) {
        ......
        
        if (announcedEventEnd) {
            return;
        }
        
        commonTotal++;
        if (......) {
            ......
            
            int remaining = commonLimit - commonTotal;
            if (remaining > 0) {
                CPrintToChatAll("<{olive}Horde{default}> {red}%i {default}common remaining..", remaining);
            }
            else {
                // Our job here is done
                if (!announcedEventEnd) {
                    CPrintToChatAll("<{olive}Horde{default}> {red}No {default}common remaining!");
                    announcedEventEnd = true;
                }
                return;
            }
            
            ......
        }
    }
}
```

