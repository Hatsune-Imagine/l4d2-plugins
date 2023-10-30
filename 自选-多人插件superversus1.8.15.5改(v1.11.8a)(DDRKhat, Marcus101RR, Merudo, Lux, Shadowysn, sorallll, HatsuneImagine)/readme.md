# 多人插件



原作者来源：https://github.com/umlka/l4d2/tree/main/superversus1.8.15.5-modify



做出了部分修改，新增cvar：`bots_join_competitive`。可用于配置对抗模式或清道夫模式下是否允许玩家自动或手动输入指令加入生还者。0=否, 1=是.

从而使得对抗模式或清道夫模式下，当总人数超过8人时，剩余玩家将维持在旁观者阵营，从而避免出现 4+人类 vs 4特感的情况。



```c
public void OnPluginStart() {
    ......
    
    g_cJoinCompetitive = CreateConVar("bots_join_competitive", "1", "对抗模式或清道夫模式下是否允许玩家自动或手动输入指令加入生还者. \n0=否, 1=是.", CVAR_FLAGS);
    
    ......
}
```

