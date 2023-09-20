#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>

public Plugin myinfo = 
{
	name = "L4D2 Common Infected Item Block",
	author = "HatsuneImagine",
	description = "Block CEDA infected vomitjar and fallen survivors.",
	version = "1.0",
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
};

public void OnMapStart() {
	if (L4D_IsVersusMode()) {
		SetConVarFloat(FindConVar("sv_infected_ceda_vomitjar_probability"), 0.0);
		SetConVarInt(FindConVar("z_fallen_max_count"), 0);
	}
	else {
		ResetConVar(FindConVar("sv_infected_ceda_vomitjar_probability"));
		ResetConVar(FindConVar("z_fallen_max_count"));
	}
}
