# 传送或处死长时间不进终点安全屋的玩家



原作者来源：https://github.com/umlka/l4d2/tree/main/safearea_teleport



1. 新增 `st_sound` 配置，可配置是否向所有生还者发出倒计时声音

```c
// 是否向所有生还者发出倒计时声音 (0=否, 1=是)
// -
// Default: "1"
st_sound "0"
```



2. 在 `CloseAndLockLastSafeDoor()` 方法中新增条件判断，避免因部分三方图终点无安全门而报错

```c
void CloseAndLockLastSafeDoor() {
    ......

    // 新增判断 "m_flSpeed" 和 "m_hasUnlockSequence" Prop_Data 是否存在，存在则执行
    if (...... && HasEntProp(entRef, Prop_Data, "m_flSpeed") && HasEntProp(entRef, Prop_Data, "m_hasUnlockSequence")) {

        ......
    }
}
```

