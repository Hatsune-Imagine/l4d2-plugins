# 显示和屏蔽提示信息



原作者来源：https://github.com/umlka/l4d2/blob/main/sms/sms.sp



1. 修改了部分提示信息，去除了玩家连接退出提示中的 `★` 和 `☆` 符号和部分文案。

2. 新增 GeoIP 支持，可配置显示连接玩家所属国家地区。



```bash
// 连接退出提示(0-关闭,1-文字提示,2-提示声音,4-人数显示,8-地区显示)[可相加组合].
// -
// Default: "5"
sms_connected_notify "5"
```



例：

当配置为 `1` 时，显示的连接退出提示样式为：

```
XXX 正在连接.
XXX 离开游戏. (Disconnect by user.)
```



当配置为 `5` 时，显示的连接退出提示样式为：

```
XXX 正在连接. (2/8)
XXX 离开游戏. (Disconnect by user.) (1/8)
```



当配置为 `9` 时，显示的连接退出提示样式为：

```
XXX 正在连接. (China, Shanghai, Shanghai)
XXX 离开游戏. (Disconnect by user.)
```



当配置为 `13` 时，显示的连接退出提示样式为：

```
XXX 正在连接. (2/8) (China, Shanghai, Shanghai)
XXX 离开游戏. (Disconnect by user.) (1/8)
```

