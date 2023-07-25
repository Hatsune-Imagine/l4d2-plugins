# 自动连跳



输入 `/bhop` 或 `/onrb` 可切换按住空格自动连跳开关

新增了对当前游戏模式的判断，禁止玩家在 “对抗模式” 和 “清道夫模式” 使用此指令。以避免对抗模式中或清道夫模式中玩家利用此插件进行跑图或快速拿油灌油。

```c
public Action Cmd_Autobhop(int client, int args)
{
	......

	if(l4d2_gamemode() == 2) {
		ReplyToCommand(client, "对抗模式不可用");
		return Plugin_Handled;
	}

	if(l4d2_gamemode() == 4) {
		ReplyToCommand(client, "清道夫模式不可用");
		return Plugin_Handled;
	}
    
    ......
}
```

