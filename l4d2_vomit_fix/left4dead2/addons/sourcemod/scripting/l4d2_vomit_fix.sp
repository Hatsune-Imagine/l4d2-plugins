#include <sourcemod>

public Plugin myinfo = {
    name = "[L4D2] vomit fix",
    author = "lakwsh",
    version = "1.0.1"
};

public void Patch(Address ptr, bool isWin) {
    StoreToAddress(ptr, 0xB8, NumberType_Int8, true);
    StoreToAddress(view_as<Address>(view_as<int>(ptr) + 1), 0x3d088889, NumberType_Int32);
    int off = isWin ? 6 : 0;
    StoreToAddress(view_as<Address>(view_as<int>(ptr) + 5 + off), 0xc06e0f66, NumberType_Int32);
    StoreToAddress(view_as<Address>(view_as<int>(ptr) + 9 + off), 0x90, NumberType_Int8);
}

public void OnPluginStart() {
    GameData hGameData = new GameData("l4d2_vomit_fix");
    if(!hGameData) SetFailState("Failed to load 'l4d2_vomit_fix.txt' gamedata.");
    Address ptr = hGameData.GetMemSig("vomit_fix");
    bool isWin = !ptr;
    if(isWin) ptr = hGameData.GetAddress("vomit_fix_1");
    if(!ptr) SetFailState("'vomit_fix' Signature broken.");
    Patch(ptr, isWin);
    if(isWin) {
        ptr = hGameData.GetAddress("vomit_fix_2");
        if(!ptr) SetFailState("'vomit_fix'(win) Signature broken.");
        Patch(ptr, isWin);
    }
    CloseHandle(hGameData);
}