# 投票换图



原作者来源：https://github.com/umlka/l4d2/tree/main/map_changer



需要前置插件：

`l4d2_source_key_values`：https://github.com/fdxx/l4d2_source_keyvalues

`l4d2_nativevote`：https://github.com/fdxx/l4d2_nativevote



---

部分修改如下：

1. 将前置依赖 `l4d2_source_keyvalues` 和 `l4d2_nativevote` 升级至最新版。



2. 修复 `l4d2_map_vote` 不适配最新版 `l4d2_nativevote` 的问题。当投票下一张地图时，只有索引最小的玩家能看到投票窗口，其他玩家看不到投票窗口且无法支持或反对的bug（且投票窗口中只有1个槽位，索引最小的玩家支持或反对后投票框则关闭）。



原本 **向所有玩家展示原生投票窗口** 的逻辑如下：

```c
void VoteChangeMap(int client, const char[] item) {
    ......

    int clients[1];
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i) || (team = GetClientTeam(i)) < 2 || team > 3)
            continue;

        fmt_Translate(info[0], info[0], sizeof info[], i, info[0]);
        fmt_Translate(info[1], info[1], sizeof info[], i, info[1]);
        vote.SetTitle("更换地图: %s (%s)", info[0], info[1]);

        clients[0] = i;
        vote.DisplayVote(clients, 1, 20);
    }
}
```



改进后的 **向所有玩家展示原生投票窗口** 的逻辑如下：

```c
void VoteChangeMap(int client, const char[] item) {
    ......

    int playerCount = 0;
    int[] clients = new int[MaxClients];
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i) || (team = GetClientTeam(i)) < 2 || team > 3)
            continue;

        fmt_Translate(info[0], info[0], sizeof info[], i, info[0]);
        fmt_Translate(info[1], info[1], sizeof info[], i, info[1]);
        vote.SetTitle("更换地图: %s (%s)", info[0], info[1]);

        clients[playerCount++] = i;
    }
    vote.DisplayVote(clients, playerCount, 20);
}
```



改动如下：

1. 将 `clients` 变量改为容量 `MaxClients` 大小的数组，存入所有 需要向其展示原生投票窗口 的玩家。
2. 定义 `playerCount` 变量，存入总玩家数，用于设置原生投票窗口中的槽位数。
3. 将 `l4d2_nativevote` 的 `DisplayVote()` 方法的调用从for循环中移出，放到循环执行完毕后。



此bug得以解决。当投票时，所有玩家均能看到原生投票窗口并能正常进行投票。
