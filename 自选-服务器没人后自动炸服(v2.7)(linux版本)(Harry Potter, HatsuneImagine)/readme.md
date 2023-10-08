# 服务器没人后自动炸服(Linux版本)



原作者来源：https://github.com/fbef0102/L4D1_2-Plugins/tree/master/linux_auto_restart



做出了一点小修改，新增了 `sm_crash` 指令，管理员可在服务器控制台中输入  `sm_crash` 或在游戏聊天框中输入 `/crash` 或 `!crash` 来使得服务器强制崩溃。

```c
Action Cmd_RestartServer(int client, int args)
{
	ReplyToCommand(client, "正在重启服务器...");
	SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
	ServerCommand("crash");

	return Plugin_Continue;
}
```

