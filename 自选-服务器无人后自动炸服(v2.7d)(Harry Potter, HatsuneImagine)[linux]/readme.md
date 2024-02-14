# 服务器没人后自动炸服(Linux版本)



原作者来源：https://github.com/fbef0102/L4D1_2-Plugins/tree/master/linux_auto_restart



1. 新增 `sm_crash` 指令，管理员可在服务器控制台中输入  `sm_crash` 或在游戏聊天框中输入 `/crash` 或 `!crash` 来使得服务器强制崩溃。

```c
public void OnPluginStart()
{
    RegAdminCmd("sm_crash", Cmd_RestartServer, ADMFLAG_ROOT, "sm_crash - manually force the server to crash");

    ......
}

Action Cmd_RestartServer(int client, int args)
{
    SetConVarInt(FindConVar("sb_all_bot_game"), 1);
    PrintToChatAll("正在重启服务器...");
    UnloadAccelerator();
    CreateTimer(5.0, Timer_RestartServer);

    return Plugin_Continue;
}
```

---



2. 修复了原作者插件在部分情况下，服务器无人后，仍然不会触发自动奔溃重启的bug。可能是由于在切换章节时所有玩家退出，未成功触发 `player_disconnect` 事件导致。且在 `OnMapStart()` 方法中未实时获取当前是否有玩家在服务器内，且方法中的判断逻辑有部分漏洞。

原作者逻辑如下：

```c
public void OnMapStart()
{    
    if(g_bNoOneInServer || (!g_bFirstMap && g_bCmdMap))
    {
        g_hConVarHibernate.SetBool(false);
        delete COLD_DOWN_Timer;
        COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN);
    }

    g_bFirstMap = false;
    g_bCmdMap = false;
}
```

在判断 `if(g_bNoOneInServer || (!g_bFirstMap && g_bCmdMap))` 中，可能因为玩家在服务器切换章节时退出导致未成功触发 `player_disconnect` 事件，从而导致 `g_bNoOneInServer` 变量值仍然为false。且此时 `g_bFirstMap` 变量值一定为false， `g_bCmdMap` 变量值一定也为false，从而导致不触发自动奔溃重启的逻辑。



改进后的逻辑如下：

```c
public void OnMapStart()
{
    if(g_bCmdMap || (!CheckPlayerInGame(0) && !g_bFirstMap))
    {
        SetConVarInt(FindConVar("sb_all_bot_game"), 1);
        delete COLD_DOWN_Timer;
        COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN);
    }

    g_bFirstMap = false;
    g_bCmdMap = false;
}
```

去除了 `g_bNoOneInServer` 变量，使用 `CheckPlayerInGame(0)` 方法实时判断当前是否有玩家。且判断逻辑改为 `当服务器触发过map指令 或 (此时无人在服务器中 且 服务器不是刚刚启动的)` ，此时的逻辑则无漏洞。

---



3. 优化了部分代码，去除了部分无用方法。

将原作者设置 `sv_hibernate_when_empty` 为0的逻辑去除，改为 设置 `sb_all_bot_game` 为1的逻辑。经过测试，当服务器 `sb_all_bot_game` 为0时，即使设置 `sv_hibernate_when_empty` 为0，服务器无人时也会处于休眠状态（status中可看到hibernating）。此时，如果在服务器控制台中输入 `sm_crash` 命令，则不会进行处理，输入后没有任何事情发生，当有玩家加入服务器后，服务器这时才突然执行了奔溃重启。

本次修复了此情况，当达成自动奔溃重启条件或手动输入 `sm_crash` 时，将服务器的 `sb_all_bot_game` 设置为1。
