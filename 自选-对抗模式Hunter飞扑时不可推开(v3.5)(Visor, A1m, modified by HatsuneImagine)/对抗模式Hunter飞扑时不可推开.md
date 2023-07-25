# 对抗模式Hunter飞扑时不可推开



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_no_hunter_deadstops.sp



嫖自ZoneMod，并作出了部分修改。



原作者的插件安装后，在所有游戏模式均生效，新增了left4dhooks中对游戏模式判断的方法，使得其只在 “对抗模式” 中生效。

```c
Action Shove_Handler(int shover, int shovee)
{
	if (L4D_GetGameModeType() != 2) {
		return Plugin_Continue;
	}
    
    ......
}
```