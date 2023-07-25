# 根据人数设置医疗物品倍数



#### 1. 部分代码优化

优化了第124行 `IsPlayerMultiple()` 方法中的部分代码。

原先的逻辑如下：

```c
void IsPlayerMultiple(bool g_bPrompt, bool g_bContent, bool g_bMoreCheck, int client, int g_iClientNumber, int g_iSurvivorLimit)
{
	switch (g_iClientNumber)
	{
		case 1,2,3,4:
			IsUpdateEntCount(client, 1, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
		case 5,6,7,8:
			IsUpdateEntCount(client, 2, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
		case 9,10,11,12:
			IsUpdateEntCount(client, 3, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
		case 13,14,15,16:
			IsUpdateEntCount(client, 4, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
		case 17,18,19,20:
			IsUpdateEntCount(client, 5, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
		case 21,22,23,24:
			IsUpdateEntCount(client, 6, g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
	}
}
```





对于这种周期为4，每加4人时倍数加1的情况，只需对当前人数转为float并除以4，并取天花板数即可。

如此 `RoundToCeil(g_iClientNumber * 1.0 / 4)`

因此此方法可精简为如下

```c
void IsPlayerMultiple(bool g_bPrompt, bool g_bContent, bool g_bMoreCheck, int client, int g_iClientNumber, int g_iSurvivorLimit)
{
	IsUpdateEntCount(client, RoundToCeil(g_iClientNumber * 1.0 / 4), g_bPrompt, g_bContent, g_bMoreCheck, g_iClientNumber, g_iSurvivorLimit);
}
```

