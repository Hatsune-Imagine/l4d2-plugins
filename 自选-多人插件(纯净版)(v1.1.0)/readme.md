# 多人插件



修复了部分bug。



#### 1. 修复了 `public Action Timer_SpecCheck()` 方法中的一个逻辑错误

此方法主要用于给正在旁观的玩家，每15秒发送聊天框提示其可输入 `!join` 或 `!jg` 或 `按鼠标右键` 加入生还者。

但在 “对抗模式” 和 “清道夫模式” 中，不应该引导旁观者使用此方式加入游戏，应使其通过按M的方式选择阵营加入。但是原本的逻辑中包含一个逻辑错误，原本的逻辑为：

```c
if (l4d2_gamemode() != 2 || l4d2_gamemode() != 4) {
    if (!MenuFunc_SpecNext[i])
        PrintToChat(i, "\x05点击\x04鼠标右键\x05, 或输入\x04!jg\x05或\x04!join\x05加入幸存者.");
    
    ......
}
```



使用短路或 || 进行模式的非判断，则会有逻辑漏洞，

当前模式为对抗模式时，逻辑正常，不会发送聊天框信息提示其加入幸存者，

但当当前模式为清道夫模式时，逻辑错误，`if(l4d2_gamemode() != 2 || l4d2_gamemode() != 4)` 则相当于 `if(true || false)` ，而 `短路或` 判断则直接会认为此条件成立，因此在 “清道夫模式” 下，仍然会发送聊天框提示给旁观者。



因此，只需将其改为短路与 && 判断即可修复此bug。

```c
if (l4d2_gamemode() != 2 && l4d2_gamemode() != 4) {
    if (!MenuFunc_SpecNext[i])
        PrintToChat(i, "\x05点击\x04鼠标右键\x05, 或输入\x04!jg\x05或\x04!join\x05加入幸存者.");
    
    ......
}
```





---

#### 2. 新增 “对抗模式” 和 “清道夫模式” 对旁观者的提示信息

当 “对抗模式” 和 “清道夫模式” 比赛双方有空位时，发送提示给旁观者提示其可按M选择阵营并加入游戏。

```c
if(l4d2_gamemode() != 2 && l4d2_gamemode() != 4) {
    ......
}
else if (iGetTeamPlayers(TEAM_SURVIVOR, false) + iGetTeamPlayers(TEAM_INFECTED, false) < 8) {
    PrintToChat(i, "\x05“\x03%s\x05”, 当前比赛有空位, 请按\x04 M \x05选择阵营加入.", PlayerName);
}
```





---

#### 3. 修复了 “对抗模式” 和 “清道夫模式” 下，当服务器最大人数设置为 > 8 人时，加入的玩家在旁观者状态下仍然可通过按下鼠标右键或输入/join加入幸存者阵营，导致出现 5个人类甚至更多 vs 4个特感 的bug

在 `/join` 和 `/jg` 命令所触发的方法 `public Action JoinTeam_Type()` 中添加了对当前游戏模式的判断，如果当前游戏为 “对抗模式” 或 “清道夫模式”，则直接跳过此方法的后续逻辑并且不允许弹出 “是否加入幸存者？ 1确定 2取消” 的HUD，从而避免出现 > 4个幸存者的情况。

```c
public Action JoinTeam_Type(int client, int args)
{
    if(l4d2_gamemode() == 2 || l4d2_gamemode() == 4)
        return Plugin_Continue;
    
    ......
}
```



同时，在 `void vSpawnCheck()` 方法中，也会根据当前服务器人数，自动添加一个对应的bot玩家。因此也会导致在 “对抗模式” 和 “清道夫模式” 中，出现 4+ 幸存者的情况。此处也修复了此问题。

```c
public Action vSpawnCheck()
{
    if (l4d2_gamemode() == 2 || l4d2_gamemode() == 4)
        return Plugin_Continue;

    ......
}
```



当 “对抗模式” 或 “清道夫模式” 满8人后，再加入的其他玩家将只能维持在旁观模式。只有当双方对抗玩家有人退出时，此时旁观玩家只需按M并选择阵营加入游玩即可，就像那些药抗服务器一样。





---

#### 4. 修复了对抗模式和清道夫模式下，总人数超过8人时，当有人类方死亡并退出游戏时，某一旁观者会自动接管死亡的Bot并复活

在 `vRoundRespawn()` 方法中做出的限制，如果当前游戏模式为对抗或清道夫，则不允许此插件自动复活接管已死亡的Bot。

```c
void vRoundRespawn(int client)
{
    if(l4d2_gamemode() == 2 || l4d2_gamemode() == 4)
        return;
    
    ......
}
```





---

#### 5. 修复了对抗模式下部分生还者玩家副武器栏为空的bug

当游玩战役模式时，随机给予新加入的玩家一个副武器（小手枪/马格南/消防斧）不太容易出现问题。但经过调查测试后发现，当游玩对抗模式时，此功能会出现问题。当随机给予的副武器为马格南或消防斧时，此玩家会发现他的副武器栏变成了空的，一旦此玩家耗尽了主武器的所有弹药，则此玩家连推动作都将无法正常执行，且从他人视角来看，此玩家将以一个T字形的形式在飘动行走。被给予的是小手枪的玩家则没有这种问题。

因此，直接去除了随机给予副武器的代码逻辑，并修改为将给予的副武器设为小手枪。此问题在对抗模式得到解决。

```c
void GiveWeapon(int client) {
    switch(g_iGive2)
    {
        case 1:
        {
            // 当配置文件中l4d2_multislots_Survivor_spawn2设为“1”时，直接给予小手枪
            BypassAndExecuteCommand(client, "give", "pistol");//小手枪
        }
        case 2:
        {
            BypassAndExecuteCommand(client, "give", "fireaxe");//斧头.
        }
    }
    
    .......
}
```





---

#### 6. 注释了玩家退出后，移除其人物模型的同时删除其随身所有物品的代码

当游玩多人战役并超过4人时，此插件会为新加入的玩家自动新增一个人物模型，且会为退出的玩家自动删除其人物模型并同时删除其所有随身物品。这会导致一个很不好的问题，当地图物资非常稀缺时，某玩家身上有医疗包、药等贵重物品，但由于其网络原因或自身原因，选择了退出游戏，这时其身上的所有物品也被同时删除了，导致其他需要资源的玩家无法从这个已经退出的玩家身上获得其需要的物品。

此次将其删除所有随身物品的代码进行了注释，从而达成当玩家退出后，其人物模型被删除，但其身上的所有物品将会原地掉落在地上的效果。

```c
//玩家离开游戏时踢出多余电脑.
void l4d2_kick_SurvivorBot()
{
    //幸存者数量必须大于设置的开局时的幸存者数量.
    if (TotalSurvivors() > g_iLimit)
        for (int i =1; i <= MaxClients; i++)
            if (IsClientConnected(i) && IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR)
                if (!HasIdlePlayer(i))
                {
                    // 注释掉对StripWeapons()方法的调用
                    // StripWeapons(i);
                    KickClient(i, "[提示] 自动踢出多余电脑");
                    break;
                }
}
```

