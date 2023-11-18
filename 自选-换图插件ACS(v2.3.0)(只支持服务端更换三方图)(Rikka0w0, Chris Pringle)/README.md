# 换图插件ACS


做出了部分修改，将原本 `l4d2_mission_manager.sp` 中获取三方图名称的取值由 `Name` 改为 `DisplayTitle` , 从而可使得换图菜单内，地图的显示名称与实际地图名称一致。



**注意：安装此版本后，需将旧版插件的数据清除**

所需清除的文件：

```bash
left4dead2/addons/sourcemod/configs/missioncycle.coop.txt
left4dead2/addons/sourcemod/configs/missioncycle.versus.txt
left4dead2/addons/sourcemod/configs/missioncycle.survival.txt
left4dead2/addons/sourcemod/configs/missioncycle.scavenge.txt
left4dead2/addons/sourcemod/configs/finale.coop.txt
left4dead2/addonlist.txt
```

所需清除的文件夹：

```bash
left4dead2/downloads/
left4dead2/missions.cache/
```

