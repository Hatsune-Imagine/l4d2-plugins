# 动态大厅



原作者来源：https://github.com/umlka/l4d2



原作者插件会根据大厅人数情况动态设置 `sv_allow_lobby_connect_only` 的值，导致会有这种情况的发生：大厅被移除，但此时此cvar的值仍然是1（可能是原作者的逻辑漏洞，或服主在 `server.cfg` 中强制指定了此cvar的值为1），导致想加入的玩家加入时出现 “此会话已不可用” 的提示，从而无法加入游戏。



本次修改共计：

1. 部分代码写法优化。

2. 修复当 `server.cfg` 中强制指定了 `sv_allow_lobby_connect_only` 为1时，其他尝试连接的玩家可能收到 “会话不可用” 的情况。

3. 改用 left4dhooks.inc 中的方法来获取当前游戏模式。

4. 新增 `sm_reserve` 指令，可手动恢复当前服务器大厅。管理员可在服务器控制台执行此命令或在游戏聊天框中输入 `/reserve` 命令。

5. 移除了将 `sv_allow_lobby_connect_only` 设为1的逻辑，仅保留设为0的逻辑。

6. 将 `OnClientPutInServer()` 方法改为 `OnClientConnected()`。
