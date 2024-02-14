# 战役模式控制特感



原作者来源：https://github.com/umlka/l4d2/tree/main/control_zombies



1. 将发送给内鬼玩家的提示信息移动至 `cmdTeam3()` 方法末尾。

```c
Action cmdTeam3(int client, int args) {
    ......

    CPrintToChat(client, "{default}聊天栏输入 {olive}!team2 {default}可返回{blue}生还者");
    CPrintToChat(client, "{red}灵魂状态下{default} 按下 {red}[鼠标中键] {default}可以快速切换特感");

    return Plugin_Handled;
}
```



2. 自动设置特感复活距离 `z_spawn_safety_range` 的值，如果有人在扮演内鬼，则将其设置为对抗模式相同复活距离值 `200`，否则设为战役默认值。

```c
Action tmrSetSpawnRange(Handle timer) {
    if (_GetTeamCount(3) > 0) {
        SetConVarInt(FindConVar("z_spawn_safety_range"), 200);
    }
    else {
        ResetConVar(FindConVar("z_spawn_safety_range"));
    }

    return Plugin_Continue;
}
```

