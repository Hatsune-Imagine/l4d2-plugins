# 玩家输入/g丢弃武器



原作者来源：https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_drop



1. 新增 “双击喷漆键” 触发丢弃武器逻辑。

```c
#define IMPULSE_SPRAY 201
float g_fPressTime[MAXPLAYERS + 1];

......

public void OnPlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    if (impulse == IMPULSE_SPRAY && GetClientTeam(client) == 2)
    {
        float time = GetEngineTime();
        if(time - g_fPressTime[client] < 0.3)
            DropActiveWeapon(client);

        g_fPressTime[client] = time; 
    }
}
```

