# 黑枪反伤



可配置生还者黑枪反伤效果。

配置项：

```c
// 启用插件 [0=关闭,1=开启]
// -
// Default: "0"
l4d2_reflect_ff_enable "0"

// 开启反伤, 即使被黑的人是电脑人机.
// 0=关闭
// 1=开启
// -
// Default: "0"
l4d2_reflect_ff_enable_bot "0"

// 开启反伤, 即使被黑的人是倒地状态.
// 0=关闭
// 1=开启
// -
// Default: "0"
l4d2_reflect_ff_enable_incap "0"

// 开启火瓶, 汽油桶, 烟花盒反伤.
// 0=关闭
// 1=开启
// -
// Default: "0"
l4d2_reflect_ff_enable_fire "0"

// 开启土制炸弹, 丙烷罐, 氧气罐, 榴弹发射器反伤.
// 0=关闭
// 1=开启
// -
// Default: "0"
l4d2_reflect_ff_enable_explode "0"

// 仅当造成伤害值大于等于此数值时, 开启反伤. (0=总是反伤)
// -
// Default: "0"
l4d2_reflect_ff_damage_shield "0"

// 对黑枪者造成反伤伤害值的倍数. (1.0=原始伤害值)
// -
// Default: "1.0"
l4d2_reflect_ff_damage_multi "1.0"
```



可使用的指令：

管理员聊天框输入 `/rf` , `/reflect` 可开关反伤。

**注意：如您更喜欢使用 `/rf` , `/reflect` 聊天框指令来开关反伤，则请您将 cfg 配置文件中 `l4d2_reflect_ff_enable` 配置项前加上双斜杠 `//` 注释。因为此 cfg 配置文件每次切换章节时都会执行，因此会将插件开关设为配置文件中指定的值。**
