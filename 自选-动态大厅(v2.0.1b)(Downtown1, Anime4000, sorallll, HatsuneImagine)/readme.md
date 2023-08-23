# 动态大厅



原作者来源：https://github.com/umlka/l4d2



原作者插件会根据游戏模式进行判断，如果为对抗或清道夫，则满8人后移除大厅，其余模式满4人后移除大厅。

且会动态设置 `sv_allow_lobby_connect_only` 的值，导致会有这种情况的发生：大厅被移除，但此cvar的值是1，导致想加入的玩家加入时出现“此会话已不可用”的提示，从而无法加入游戏。



本次修改共计：

1. 将获取当前游戏模式cvar的逻辑从 `OnPluginStart()` 方法移动至 `OnMapStart()` 方法中，以确保可正确获取到当前的游戏模式。

2. 新增 `sm_reserve` 指令，可手动恢复当前服务器大厅。管理员可在服务器控制台执行此命令或在游戏聊天框中输入 `/reserve` 命令。

3. 移除了将 `sv_allow_lobby_connect_only` 设为1的逻辑，仅保留设为0的逻辑。

4. 将 `OnClientPutInServer()` 方法改为 `OnClientConnected()`。
