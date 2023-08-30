# 对抗模式武器属性修改



原作者来源：https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_weapon_attributes.sp



**注意：其配置文件 `weapon_attributes.cfg` 需要在服务器配置文件中执行才可生效**

例：在 `server.cfg` 中添加

```bash
// 执行对抗模式武器属性修改配置文件
exec weapon_attributes.cfg
```



嫖自ZoneMod，并作出了部分修改。

原作者的插件安装后，在所有游戏模式均生效，新增了对游戏模式的判断，使得其只在 “对抗模式” 中生效。

```c
public void OnConfigsExecuted()
{
    // Weapon info may get reloaded, and supported melees
    // are different between campaigns.
    // Here we are reloading all the attributes set by our own.
    
    if (L4D_IsVersusMode()) {
        ResetWeaponAttributes(false);
        ResetMeleeAttributes(false);
    }
    else {
        ResetWeaponAttributes(true);
        ResetMeleeAttributes(true);
    }
}
```
