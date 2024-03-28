# 自动连跳



原作者来源：https://github.com/wyxls/SourceModPlugins-L4D2/tree/master/sm_bhop



输入 `/bh` 或 `/bhop` 或 `/onrb` 可切换按住空格自动连跳开关

1. 新增  `l4d2_auto_bhop_allow_competitive` 配置，可配置是否允许玩家在 “对抗模式” 和 “清道夫模式” 使用此指令。以避免对抗模式中或清道夫模式中玩家利用此插件进行跑图或快速拿油灌油。

```c
public Action Cmd_Autobhop(int client, int args)
{
    ......

    if (!cv_autoBhopCompetitive.BoolValue && IsVersus()) {
        ReplyToCommand(client, "对抗模式不可用.");
        return Plugin_Handled;
    }

    if (!cv_autoBhopCompetitive.BoolValue && IsScavenge()) {
        ReplyToCommand(client, "清道夫模式不可用.");
        return Plugin_Handled;
    }
    
    ......
}
```



2. 新增  `l4d2_auto_bhop_default` 配置，可配置加入的玩家是否默认开启自动连跳。

```c
public void OnClientConnected(int client)
{
    if (cv_autoBhopDefault.BoolValue)
        g_AutoBhop[client] = true;
}
```





3. 修复了每次过关后所有玩家连跳开关被关闭的bug，由于 `OnClientDisconnect()` 方法在每次切换章节时也会被触发，因此改为使用 `player_disconnect` 事件触发方式。

```c
public void OnPluginStart()
{
    ......

    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

//OnClientDisconnect will fired when changing map, use "player_disconnect" event instead.
void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client)
        g_AutoBhop[client] = false;
}
```
