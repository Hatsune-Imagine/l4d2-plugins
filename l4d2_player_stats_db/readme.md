# 玩家信息统计（MySQL版）



玩家信息统计插件，基于数据库存储玩家信息。

部分玩家技能统计数据需要前置插件：https://github.com/Hatsune-Imagine/l4d2-plugins/tree/main/l4d2_skill_detect

后端 RestAPI 项目（正在开发中，暂不可访问）：https://github.com/Hatsune-Imagine/l4d2-player-stats-restapi



## 目录

[TOC]



## 插件以3种维度记录玩家信息：

1. **玩家整体信息**
   - 玩家SteamID
   - 玩家昵称
   - 玩家在此服务器内游玩时长（秒）
   - 爆头击杀数
   - 近战击杀数
   - 普通感染者击杀数
   - Smoker击杀数
   - Boomer击杀数
   - Hunter击杀数
   - Spitter击杀数
   - Jockey击杀数
   - Charger击杀数
   - Witch击杀数
   - Tank击杀数
   - 造成队友伤害值
   - 受到队友伤害值
   - 保护队友次数
   - 扶起队友次数
   - 倒地次数
   - 挂边次数
   - 章节完成数
   - 章节团灭数
   - 近战砍断Smoker舌头数
   - 从Smoker舌头下自救数
   - 空爆Hunter数
   - 砍死冲锋Charger数
   - 秒杀Witch数
   - 打碎Tank石头数
   - 被Tank石头砸中数
   - 触发警报数



2. **玩家连接日志信息**
   - 玩家SteamID
   - 玩家连接IP
   - 玩家连接时间



3. **玩家每章节详细信息**
   - 玩家SteamID
   - 服务器IP
   - 服务器端口
   - 服务器地图章节
   - 服务器游戏模式
   - 章节回合数
   - 爆头击杀数
   - 近战击杀数
   - 普通感染者击杀数
   - Smoker击杀数
   - Boomer击杀数
   - Hunter击杀数
   - Spitter击杀数
   - Jockey击杀数
   - Charger击杀数
   - Witch击杀数
   - Tank击杀数
   - 对特感伤害值
   - 对特感伤害百分比
   - 造成队友伤害值
   - 受到队友伤害值
   - 造成队友伤害百分比
   - 肾上腺素使用量
   - 止痛药使用量
   - 医疗包使用量
   - 保护队友次数
   - 扶起队友次数
   - 倒地次数
   - 挂边次数
   - 近战砍断Smoker舌头数
   - 从Smoker舌头下自救数
   - 空爆Hunter数
   - 砍死冲锋Charger数
   - 秒杀Witch数
   - 打碎Tank石头数
   - 被Tank石头砸中数
   - 触发警报数
   - 平均解救被控队友时间（秒）





## 使用方法

### 1. 安装MySQL（建议版本 >= 5.7）

#### Windows

1）前往 MySQL 官网。链接：https://dev.mysql.com/downloads/installer/



2）选择 MySQL Installer for Windows 并下载。

![img-mysql-win-1](images/mysql_windows_1.png)



3）点击 No thanks, just start my download. 开始下载。

![img-mysql-win-2](images/mysql_windows_2.png)



4）将下载好的 .msi 文件在您的 Windows Server 中运行并执行安装。选择 Server only 并点击 Next。

![img-mysql-win-3](images/mysql_windows_3.png)



5）点击 Execute 执行安装。

![img-mysql-win-4](images/mysql_windows_4.png)



6）安装完成后点击 Next。

![img-mysql-win-5](images/mysql_windows_5.png)



7）点击 Next 开始进行 MySQL 配置。

![img-mysql-win-6](images/mysql_windows_6.png)



8）配置 MySQL 配置类型，默认为 Development Computer，可直接使用此默认配置和默认通信端口 3306。

![img-mysql-win-7](images/mysql_windows_7.png)



9）配置 MySQL 加密策略，使用默认强密码加密方式。

![img-mysql-win-8](images/mysql_windows_8.png)



10）配置您的 MySQL root 用户密码，**注意您的密码必须足够强壮防止被破解**。当 MySQL 暴露在公网环境中时，会有大量恶意请求尝试嗅探您的 MySQL 服务并尝试破解 root 用户密码。**请您务必设置强密码**。

![img-mysql-win-9](images/mysql_windows_9.png)



11）默认将 MySQL 添加为系统服务，使得系统开机时自动运行 MySQL 服务。

![img-mysql-win-10](images/mysql_windows_10.png)



12）配置服务器文件权限，选择默认配置即可。

![img-mysql-win-11](images/mysql_windows_11.png)



13）应用之前的配置项。

![img-mysql-win-12](images/mysql_windows_12.png)



14）应用配置项完成，点击 Finish 完成。

![img-mysql-win-13](images/mysql_windows_13.png)



15）点击 Next 下一步。

![img-mysql-win-14](images/mysql_windows_14.png)



16）点击 Finish 完成安装。

![img-mysql-win-15](images/mysql_windows_15.png)



**注意**：SourceMod 自带的 MySQL 连接扩展**仅支持** `mysql_native_password` **加密方式**，**不支持** `caching_sha2_password` **加密方式**。因此，如您要配置的 SourceMod 连接 MySQL 用户的加密方式为 `caching_sha2_password` ，您需将其改为 `mysql_native_password` 加密方式。

请继续参考以下步骤。



17）打开 MySQL 控制台

![img-mysql-win-16](images/mysql_windows_16.png)



18）查看所有 MySQL 用户加密方式。

```sql
select host, user, plugin from mysql.user;
```

![img-mysql-win-17](images/mysql_windows_17.png)



19）修改 root 用户的加密方式及密码。

将 root 用户设为可通过外网访问（可选，如果上图查询出来 root 用户的 host 已经是 '%' 则可跳过这句update）

```sql
update mysql.user set host = '%' where user = 'root';
```

![img-mysql-win-18](images/mysql_windows_18.png)

刷新用户权限

```sql
flush privileges;
```

修改 root 用户密码

```sql
alter user 'root'@'%' identified with mysql_native_password by '您的新密码(注意需足够强壮)';
```

刷新用户权限

```sql
flush privileges;
```

![img-mysql-win-19](images/mysql_windows_19.png)



20）退出 MySQL 控制台。

```bash
quit
```





---

#### Linux

Ubuntu/Debian 系 Linux

1）在控制台中执行更新 apt 源。

```bash
sudo apt update
```



2）安装 MySQL 服务。

```bash
sudo apt install mysql-server
```



3）安装完成后，查看存储在 `/etc/mysql/debian.cnf` 中的 MySQL 默认用户名及密码。

```bash
sudo cat /etc/mysql/debian.cnf
```

![img-mysql-linux-1](images/mysql_linux_1.png)



4）使用控制台登录 MySQL，并修改默认 root 用户密码。

```bash
mysql -u用户名 -p密码
```

以上图为例，则：

```bash
mysql -udebian-sys-maint -pXXXXXX
```

![img-mysql-linux-2](images/mysql_linux_2.png)



5）查看所有 MySQL 用户加密方式。

```sql
select host, user, plugin from mysql.user;
```

![img-mysql-linux-3](images/mysql_linux_3.png)



**注意**：SourceMod 自带的 MySQL 连接扩展**仅支持** `mysql_native_password` **加密方式**，**不支持** `caching_sha2_password` **加密方式**。因此，如您要配置的 SourceMod 连接 MySQL 用户的加密方式为 `caching_sha2_password` ，您需将其改为 `mysql_native_password` 加密方式。



6）修改 root 用户的加密方式及密码。

将 root 用户设为可通过外网访问（可选，如果上图查询出来 root 用户的 host 已经是 '%' 则可跳过这句update）

```sql
update mysql.user set host = '%' where user = 'root';
```

刷新用户权限

```sql
flush privileges;
```

修改 root 用户密码

```sql
alter user 'root'@'%' identified with mysql_native_password by '您的新密码(注意需足够强壮)';
```

刷新用户权限

```sql
flush privileges;
```



7）退出 MySQL 控制台。

```bash
quit
```

![img-mysql-linux-4](images/mysql_linux_4.png)



8）配置 MySQL 配置文件使其支持本机以外的设备连接（可选，当您的求生服与MySQL服在同一台机器上时，无需执行此操作，否则导致安全性降低）。

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

编辑 `/etc/mysql/mysql.conf.d/mysqld.cnf` 配置文件，修改其中的 `bind-address` 配置，将其地址改为 `0.0.0.0` ，表示允许任意IP地址访问。

![img-mysql-linux-5](images/mysql_linux_5.png)



9）重启 MySQL 服务。

```bash
sudo systemctl restart mysql
```



10）安装 zlib。

```bash
sudo apt install lib32z1
```





---

CentOS/RedHat 系 Linux

1）安装 MySQL 服务。

```bash
sudo yum install mysql-server
```



**注意**：CentOS 不同版本有不同的处理方式。CentOS 7 系统自带 MariaDB（MySQL 的分支，和 MySQL 类似），则无须再手动安装 MySQL 。CentOS 8 默认 yum 源安装的就是 MySQL 8，请根据实际情况自行搜索解决方案。







## 2. 使用数据库连接工具，创建数据库及表结构

可使用3种工具，任选一种即可。

---

1）DBeaver【免费】

https://dbeaver.io/download

![img-dbeaver](images/dbeaver.png)



下载并安装完成后，打开应用，创建数据库连接。

![img-dbeaver-1](images/dbeaver_1.png)



选择 MySQL 并点击下一步。

![img-dbeaver-2](images/dbeaver_2.png)



配置连接信息，如您将此工具也安装在服务器内，您可直接通过 `127.0.0.1` 地址连接，否则请填写服务器公网地址。

![img-dbeaver-3](images/dbeaver_3.png)



Linux 服务器用户还可通过 SSH 方式连接您服务器中的 MySQL 服务。填写 SSH 连接信息后，在 “主要” 菜单中可直接通过 `127.0.0.1` 地址连接。

![img-dbeaver-4](images/dbeaver_4.png)



成功连接后，打开 SQL 编辑器，并将 `init.sql` 文件中的内容复制粘贴到此。

![img-dbeaver-5](images/dbeaver_5.png)



执行 SQL 脚本。

![img-dbeaver-6](images/dbeaver_6.png)



随后您便可看到名为 `player_stats` 的数据库及表，双击可查看表结构及数据。

![img-dbeaver-7](images/dbeaver_7.png)





---

2）Navicat【收费】

https://navicat.com.cn/download/navicat-premium

![img-navicat](images/navicat.png)





---

3）DataGrip【收费】

https://www.jetbrains.com/datagrip/download

![img-datagrip](images/datagrip.png)





## 3. 编辑 SourceMod 连接 MySQL 配置

1）打开服务器端 SourceMod 数据库连接配置文件 `addons/sourcemod/configs/databases.cfg` 并在其中加入数据库连接配置。

```
"player_stats"
{
	"driver"			"default"			// 数据库连接驱动，默认为mysql
	"host"				"127.0.0.1"			// 数据库连接地址
	"database"			"player_stats"		// 数据库名
	"user"				"YourMySQLUserName"	// MySQL 连接用户名
	"pass"				"YourMySQLPassword"	// MySQL 连接密码
	"port"				"3306"				// MySQL 通信端口
}
```



2）随后将 `l4d2_player_stats_db` 插件放入您的求生服务器，即可正常存储记录玩家数据。
