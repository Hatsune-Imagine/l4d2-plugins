# 击杀或爆头和黑枪提示和关闭队伤



修复当配置文件中 `l4d2_broadcast_Kill` 设为0时，“爆头”信息仍然会提示的问题。



第 203 行 `void Printkillinfo()` 方法开头新增对 `l4d2_broadcast_Kill` 值为0的判断

```c
void Printkillinfo(int attacker, bool headshot)
{
	if (Hbroadcast == 0)
		return;
    
    ......
}
```

