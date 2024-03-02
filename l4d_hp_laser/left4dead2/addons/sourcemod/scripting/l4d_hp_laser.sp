/**
// ====================================================================================================
Change Log:

1.0.9 (14-November-2021)
   - Added center align laser option. (thanks to "xZk" for the code snippet)
   - Removed outline lasers.

1.0.8 (24-July-2021)
   - Fixed bar not showing up when the current HP is bigger than max HP. (thanks "TrueDarkness" for reporting)

1.0.7 (23-February-2021)
    - Fixed laser beam hiding behind witches and infecteds.
    - Code optimization.

1.0.7 (23-February-2021)
    - Fixed laser beam hiding behind witches and infecteds.
    - Code optimization.

1.0.6 (22-February-2021)
    - Added cvar to change the gradient color to default game colors on survivors. (Green 40HP+, Yellow 39HP~25HP, Red 24HP-)
    - Added menu and commands to hide/show the laser beam. (thanks "LexNBR" for requesting)
    - Changed laser beam angles.

1.0.5 (18-February-2021)
    - Fixed a bug not resizing the laser size on alpha multiply (thanks "3aljiyavslgazana" for reporting)
    - Added cvar to set the maximum alpha that a client must be to hide the laser beam.

1.0.4 (18-February-2021)
    - Added cvar to multiply the laser beam alpha based on client render alpha. (thanks "3aljiyavslgazana" for requesting)

1.0.3 (16-February-2021)
    - Added attack delay visibility cvar for survivors.

1.0.2 (12-February-2021)
    - Fixed L4D1 compatibility. (thanks "HarryPotter" for reporting)
    - Added cvar to run by frame instead by timer. (thanks "RA" for requesting)
    - Added cvar to set white laser beam color for black and white survivors.

1.0.1 (12-February-2021)
    - Fixed laser beam showing on infecteds while in ghost mode. (thanks "R.A" for reporting)
    - Fixed temporary health.
    - Added cvars to control the laser beam visibility by team.

1.0.0 (11-February-2021)
    - Initial release.

// ====================================================================================================
*/

// ====================================================================================================
// Plugin Info - define
// ====================================================================================================
#define PLUGIN_NAME                   "[L4D1 & L4D2] HP Laser"
#define PLUGIN_AUTHOR                 "Mart"
#define PLUGIN_DESCRIPTION            "Shows a laser beam at the client head based on its HP"
#define PLUGIN_VERSION                "1.0.9"
#define PLUGIN_URL                    "https://forums.alliedmods.net/showthread.php?t=330590"

// ====================================================================================================
// Plugin Info
// ====================================================================================================
public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = PLUGIN_URL
}

// ====================================================================================================
// Includes
// ====================================================================================================
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

// ====================================================================================================
// Pragmas
// ====================================================================================================
#pragma semicolon 1
#pragma newdecls required

// ====================================================================================================
// Cvar Flags
// ====================================================================================================
#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

// ====================================================================================================
// Filenames
// ====================================================================================================
#define CONFIG_FILENAME               "l4d_hp_laser"

// ====================================================================================================
// Defines
// ====================================================================================================
#define TEAM_SPECTATOR                1
#define TEAM_SURVIVOR                 2
#define TEAM_INFECTED                 3
#define TEAM_HOLDOUT                  4

#define FLAG_TEAM_NONE                (0 << 0) // 0 | 0000
#define FLAG_TEAM_SURVIVOR            (1 << 0) // 1 | 0001
#define FLAG_TEAM_INFECTED            (1 << 1) // 2 | 0010
#define FLAG_TEAM_SPECTATOR           (1 << 2) // 4 | 0100
#define FLAG_TEAM_HOLDOUT             (1 << 3) // 8 | 1000

#define L4D2_ZOMBIECLASS_SMOKER       1
#define L4D2_ZOMBIECLASS_BOOMER       2
#define L4D2_ZOMBIECLASS_HUNTER       3
#define L4D2_ZOMBIECLASS_SPITTER      4
#define L4D2_ZOMBIECLASS_JOCKEY       5
#define L4D2_ZOMBIECLASS_CHARGER      6
#define L4D2_ZOMBIECLASS_TANK         8

#define L4D1_ZOMBIECLASS_SMOKER       1
#define L4D1_ZOMBIECLASS_BOOMER       2
#define L4D1_ZOMBIECLASS_HUNTER       3
#define L4D1_ZOMBIECLASS_TANK         5

#define L4D2_FLAG_ZOMBIECLASS_NONE    0
#define L4D2_FLAG_ZOMBIECLASS_SMOKER  1
#define L4D2_FLAG_ZOMBIECLASS_BOOMER  2
#define L4D2_FLAG_ZOMBIECLASS_HUNTER  4
#define L4D2_FLAG_ZOMBIECLASS_SPITTER 8
#define L4D2_FLAG_ZOMBIECLASS_JOCKEY  16
#define L4D2_FLAG_ZOMBIECLASS_CHARGER 32
#define L4D2_FLAG_ZOMBIECLASS_TANK    64

#define L4D1_FLAG_ZOMBIECLASS_NONE    0
#define L4D1_FLAG_ZOMBIECLASS_SMOKER  1
#define L4D1_FLAG_ZOMBIECLASS_BOOMER  2
#define L4D1_FLAG_ZOMBIECLASS_HUNTER  4
#define L4D1_FLAG_ZOMBIECLASS_TANK    8

#define L4D1_BEAM_LIFE_MIN            0.11 // less than 0.11 reads as 0 in L4D1
#define L4D2_BEAM_LIFE_MIN            0.1

#define MAXENTITIES                   2048

#define LOW_HEALTH                    24

// ====================================================================================================
// Native Cvars
// ====================================================================================================
ConVar g_hCvar_survivor_incap_health;
ConVar g_hCvar_survivor_max_incapacitated_count;
ConVar g_hCvar_pain_pills_decay_rate;
ConVar g_hCvar_survivor_limp_health;

// ====================================================================================================
// Plugin Cvars
// ====================================================================================================
ConVar g_hCvar_Enabled;
ConVar g_hCvar_Cookies;
ConVar g_hCvar_AlignCenter;
ConVar g_hCvar_ZAxis;
ConVar g_hCvar_FadeDistance;
ConVar g_hCvar_Sight;
ConVar g_hCvar_AttackDelay;
ConVar g_hCvar_GradientColor;
ConVar g_hCvar_Model;
ConVar g_hCvar_Alpha;
ConVar g_hCvar_Height;
ConVar g_hCvar_Fill;
ConVar g_hCvar_FillAlpha;
ConVar g_hCvar_RenderFrame;
ConVar g_hCvar_SkipFrame;
ConVar g_hCvar_BlackAndWhite;
ConVar g_hCvar_Team;
ConVar g_hCvar_SurvivorTeam;
ConVar g_hCvar_InfectedTeam;
ConVar g_hCvar_SpectatorTeam;
ConVar g_hCvar_MultiplyAlphaTeam;
ConVar g_hCvar_ClientAlphaMax;
ConVar g_hCvar_SurvivorWidth;
ConVar g_hCvar_InfectedWidth;
ConVar g_hCvar_SI;

// ====================================================================================================
// bool - Plugin Variables
// ====================================================================================================
bool g_bL4D2;
bool g_bEventsHooked;
bool g_bCvar_survivor_max_incapacitated_count;
bool g_bCvar_Enabled;
bool g_bCvar_Cookies;
bool g_bCvar_AlignCenter;
bool g_bCvar_FadeDistance;
bool g_bCvar_Sight;
bool g_bCvar_AttackDelay;
bool g_bCvar_GradientColor;
bool g_bCvar_Fill;
bool g_bCvar_RenderFrame;
bool g_bCvar_SkipFrame;
bool g_bCvar_BlackAndWhite;
bool g_bCvar_ClientAlphaMax;
bool g_bTimer;

// ====================================================================================================
// int - Plugin Variables
// ====================================================================================================
int g_iModelBeam = -1;
int g_iFrameCount;
int g_iCvar_survivor_incap_health;
int g_iCvar_survivor_max_incapacitated_count;
int g_iCvar_survivor_limp_health;
int g_iCvar_Alpha;
int g_iCvar_FillAlpha;
int g_iCvar_SkipFrame;
int g_iCvar_Team;
int g_iCvar_SurvivorTeam;
int g_iCvar_InfectedTeam;
int g_iCvar_SpectatorTeam;
int g_iCvar_MultiplyAlphaTeam;
int g_iCvar_ClientAlphaMax;
int g_iCvar_SI;

// ====================================================================================================
// float - Plugin Variables
// ====================================================================================================
float g_fvPlayerMins[3] = {-16.0, -16.0,  0.0};
float g_fvPlayerMaxs[3] = { 16.0,  16.0, 71.0};
float g_fBeamLife;
float g_fCvar_pain_pills_decay_rate;
float g_fCvar_ZAxis;
float g_fCvar_FadeDistance;
float g_fCvar_AttackDelay;
float g_fCvar_Height;
float g_fCvar_SurvivorWidth;
float g_fCvar_InfectedWidth;

// ====================================================================================================
// string - Plugin Variables
// ====================================================================================================
char g_sCvar_Model[PLATFORM_MAX_PATH];

// ====================================================================================================
// client - Plugin Variables
// ====================================================================================================
bool gc_bDisable[MAXPLAYERS+1];
bool gc_bShouldRender[MAXPLAYERS+1];
bool gc_bVisible[MAXPLAYERS+1][MAXPLAYERS+1];
float gc_fLastAttack[MAXPLAYERS+1][MAXPLAYERS+1];

// ====================================================================================================
// entity - Plugin Variables
// ====================================================================================================
bool ge_bInvalidTrace[MAXENTITIES+1];

// ====================================================================================================
// Cookies - Plugin Variables
// ====================================================================================================
Cookie g_cbDisable;

// ====================================================================================================
// Timer - Plugin Variables
// ====================================================================================================
Handle g_tRenderInterval;

// ====================================================================================================
// Plugin Start
// ====================================================================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();

    if (engine != Engine_Left4Dead && engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "This plugin only runs in \"Left 4 Dead\" and \"Left 4 Dead 2\" game");
        return APLRes_SilentFailure;
    }

    g_bL4D2 = (engine == Engine_Left4Dead2);
    g_fBeamLife = (g_bL4D2 ? L4D2_BEAM_LIFE_MIN : L4D1_BEAM_LIFE_MIN);

    return APLRes_Success;
}

/****************************************************************************************************/

public void OnPluginStart()
{
    g_hCvar_survivor_incap_health = FindConVar("survivor_incap_health");
    g_hCvar_survivor_max_incapacitated_count = FindConVar("survivor_max_incapacitated_count");
    g_hCvar_pain_pills_decay_rate = FindConVar("pain_pills_decay_rate");
    g_hCvar_survivor_limp_health = FindConVar("survivor_limp_health");

    CreateConVar("l4d_hp_laser_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, CVAR_FLAGS_PLUGIN_VERSION);
    g_hCvar_Enabled           = CreateConVar("l4d_hp_laser_enable", "1", "Enable/Disable the plugin.\n0 = Disable, 1 = Enable.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_Cookies           = CreateConVar("l4d_hp_laser_cookies", "1", "Allow cookies for storing client preferences.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_AlignCenter       = CreateConVar("l4d_hp_laser_align_center", "1", "0 = Align the laser left-to-right per client eye angles. (lower performance)\n1 = Align the laser to center. (better performance)", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_ZAxis             = CreateConVar("l4d_hp_laser_z_axis", "85", "Additional Z axis distance of laser beam HP based on client position.", CVAR_FLAGS, true, 0.0);
    g_hCvar_FadeDistance      = CreateConVar("l4d_hp_laser_fade_distance", "0", "Minimum distance that a client must be from another client to see the laser beam HP.\n0 = Always visible.", CVAR_FLAGS, true, 0.0);
    g_hCvar_Sight             = CreateConVar("l4d_hp_laser_sight", "1", "Show a laser beam HP to the survivor only if the special infected is on sight.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_AttackDelay       = CreateConVar("l4d_hp_laser_attack_delay", "0.0", "Show the laser beam HP to the survivor attacker, by this amount of time in seconds, after hitting a special infected.\n0 = OFF.", CVAR_FLAGS, true, 0.0);
    g_hCvar_GradientColor     = CreateConVar("l4d_hp_laser_gradient_color", "0", "Should the laser beam HP on survivors render in gradient color. \n0 = OFF. (Game colors: Green 40HP+, Yellow 39HP~25HP, Red 24HP-), 1 = Gradient Mode.\nNote: The Yellow color is defined by the \"survivor_limp_health\" game cvar.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_Model             = CreateConVar("l4d_hp_laser_model", "vgui/white_additive.vmt", "Model of the laser beam HP.");
    g_hCvar_Alpha             = CreateConVar("l4d_hp_laser_alpha", "240", "Alpha of the laser beam HP.\n0 = Invisible, 255 = Fully Visible.", CVAR_FLAGS, true, 0.0, true, 255.0);
    g_hCvar_Height            = CreateConVar("l4d_hp_laser_height", "2.0", "Height of the laser beam HP.", CVAR_FLAGS, true, 0.0);
    g_hCvar_Fill              = CreateConVar("l4d_hp_laser_fill", "1", "Display a laser beam HP to fill the bar.\nNote: Disable this if you intend to show a lot of laser beams HP. The game limits the number of beams rendered at the same time when limit exceeds it may not draw then all.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_FillAlpha         = CreateConVar("l4d_hp_laser_fill_alpha", "40", "Alpha of the laser beam HP that fills the bar.\n0 = Invisible, 255 = Fully Visible", CVAR_FLAGS, true, 0.0, true, 255.0);
    g_hCvar_RenderFrame       = CreateConVar("l4d_hp_laser_render_frame", "0", "Render type used to draw the laser beams.\n0 = Timer (0.1 seconds - less expensive), 1 = OnGameFrame (by frame - more expensive).", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_SkipFrame         = CreateConVar("l4d_hp_laser_skip_frame", "1", "How many frames should skip while using l4d_hp_laser_render_type = \"1\" (OnGameFrame). Frames may vary depending on your tickrate. Using a higher value than 2 becomes slower than with the timer on default tick rate (30)", CVAR_FLAGS, true, 0.0);
    g_hCvar_BlackAndWhite     = CreateConVar("l4d_hp_laser_black_and_white", "1", "Show a laser beam HP in white on \"black and white\" survivors.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_Team              = CreateConVar("l4d_hp_laser_team", "3", "Which teams should have a laser beam HP.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_SurvivorTeam      = CreateConVar("l4d_hp_laser_survivor_team", "3", "Which teams survivors can see a laser beam HP.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_InfectedTeam      = CreateConVar("l4d_hp_laser_infected_team", "3", "Which teams infected can see a laser beam HP.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_SpectatorTeam     = CreateConVar("l4d_hp_laser_spectator_team", "3", "Which teams spectators can see a laser beam HP.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_MultiplyAlphaTeam = CreateConVar("l4d_hp_laser_multiply_alpha_team", "2", "Which teams should multiply the laser beam HP alpha based on the client render alpha.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_ClientAlphaMax    = CreateConVar("l4d_hp_laser_client_alpha_max", "0", "Maximum render alpha that a client must be to hide the laser beam HP.\nUseful to hide it on invisible/transparent clients.\n-1 = OFF.", CVAR_FLAGS, true, -1.0, true, 255.0);
    g_hCvar_SurvivorWidth     = CreateConVar("l4d_hp_laser_survivor_width", "15.0", "Width of the survivor laser beam HP.", CVAR_FLAGS, true, 0.0);
    g_hCvar_InfectedWidth     = CreateConVar("l4d_hp_laser_infected_width", "25.0", "Width of the infected laser beam HP.", CVAR_FLAGS, true, 0.0);

    if (g_bL4D2)
        g_hCvar_SI            = CreateConVar("l4d_hp_laser_si", "64", "Which special infected should have a laser beam HP.\n1 = SMOKER, 2 = BOOMER, 4 = HUNTER, 8 = SPITTER, 16 = JOCKEY, 32 = CHARGER, 64 = TANK.\nAdd numbers greater than 0 for multiple options.\nExample: \"127\", enables laser beam HP for all SI.", CVAR_FLAGS, true, 0.0, true, 127.0);
    else
        g_hCvar_SI            = CreateConVar("l4d_hp_laser_si", "8", "Which special infected should have a laser beam HP.\n1 = SMOKER, 2  = BOOMER, 4 = HUNTER, 8 = TANK.\nAdd numbers greater than 0 for multiple options.\nExample: \"15\", enables laser beam HP for all SI.", CVAR_FLAGS, true, 0.0, true, 15.0);

    // Hook plugin ConVars change
    g_hCvar_survivor_incap_health.AddChangeHook(Event_ConVarChanged);
    g_hCvar_survivor_max_incapacitated_count.AddChangeHook(Event_ConVarChanged);
    g_hCvar_pain_pills_decay_rate.AddChangeHook(Event_ConVarChanged);
    g_hCvar_survivor_limp_health.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Enabled.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Cookies.AddChangeHook(Event_ConVarChanged);
    g_hCvar_AlignCenter.AddChangeHook(Event_ConVarChanged);
    g_hCvar_ZAxis.AddChangeHook(Event_ConVarChanged);
    g_hCvar_FadeDistance.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Sight.AddChangeHook(Event_ConVarChanged);
    g_hCvar_AttackDelay.AddChangeHook(Event_ConVarChanged);
    g_hCvar_GradientColor.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Model.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Alpha.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Height.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Fill.AddChangeHook(Event_ConVarChanged);
    g_hCvar_FillAlpha.AddChangeHook(Event_ConVarChanged);
    g_hCvar_RenderFrame.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SkipFrame.AddChangeHook(Event_ConVarChanged);
    g_hCvar_BlackAndWhite.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Team.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SurvivorTeam.AddChangeHook(Event_ConVarChanged);
    g_hCvar_InfectedTeam.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SpectatorTeam.AddChangeHook(Event_ConVarChanged);
    g_hCvar_MultiplyAlphaTeam.AddChangeHook(Event_ConVarChanged);
    g_hCvar_ClientAlphaMax.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SurvivorWidth.AddChangeHook(Event_ConVarChanged);
    g_hCvar_InfectedWidth.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SI.AddChangeHook(Event_ConVarChanged);

    // Load plugin configs from .cfg
    AutoExecConfig(true, CONFIG_FILENAME);

    // Cookies
    g_cbDisable = new Cookie("l4d_hp_laser_disable", "HP Laser - Disable laser beam HP", CookieAccess_Protected);

    // Commands
    RegConsoleCmd("sm_hplaser", CmdHpMenu, "Open a menu to toogle the laser beam HP for the client.");
    RegConsoleCmd("sm_hidehplaser", CmdHideHp, "Disable laser beam HP for the client.");
    RegConsoleCmd("sm_showhplaser", CmdShowHp, "Enable laser beam HP for the client.");

    // Admin Commands
    RegAdminCmd("sm_print_cvars_l4d_hp_laser", CmdPrintCvars, ADMFLAG_ROOT, "Print the plugin related cvars and their respective values to the console.");
}

/****************************************************************************************************/

public void OnConfigsExecuted()
{
    GetCvars();

    LateLoad();

    HookEvents();
}

/****************************************************************************************************/

void Event_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();

    HookEvents();
}

/****************************************************************************************************/

void GetCvars()
{
    g_iCvar_survivor_incap_health = g_hCvar_survivor_incap_health.IntValue;
    g_iCvar_survivor_max_incapacitated_count = g_hCvar_survivor_max_incapacitated_count.IntValue;
    g_bCvar_survivor_max_incapacitated_count = (g_iCvar_survivor_max_incapacitated_count > 0);
    g_fCvar_pain_pills_decay_rate = g_hCvar_pain_pills_decay_rate.FloatValue;
    g_iCvar_survivor_limp_health = g_hCvar_survivor_limp_health.IntValue;
    g_bCvar_Enabled = g_hCvar_Enabled.BoolValue;
    g_bCvar_Cookies = g_hCvar_Cookies.BoolValue;
    g_bCvar_AlignCenter = g_hCvar_AlignCenter.BoolValue;
    g_fCvar_ZAxis = g_hCvar_ZAxis.FloatValue;
    g_fCvar_FadeDistance = g_hCvar_FadeDistance.FloatValue;
    g_bCvar_FadeDistance = (g_fCvar_FadeDistance > 0.0);
    g_bCvar_Sight = g_hCvar_Sight.BoolValue;
    g_fCvar_AttackDelay = g_hCvar_AttackDelay.FloatValue;
    g_bCvar_AttackDelay = (g_fCvar_AttackDelay > 0.0);
    g_bCvar_GradientColor = g_hCvar_GradientColor.BoolValue;
    g_hCvar_Model.GetString(g_sCvar_Model, sizeof(g_sCvar_Model));
    TrimString(g_sCvar_Model);
    g_iModelBeam = PrecacheModel(g_sCvar_Model, true);
    g_iCvar_Alpha = g_hCvar_Alpha.IntValue;
    g_fCvar_Height = g_hCvar_Height.FloatValue;
    g_bCvar_Fill = g_hCvar_Fill.BoolValue;
    g_iCvar_FillAlpha = g_hCvar_FillAlpha.IntValue;
    g_bCvar_RenderFrame = g_hCvar_RenderFrame.BoolValue;
    g_iFrameCount = 0;
    g_iCvar_SkipFrame = g_hCvar_SkipFrame.IntValue;
    g_bCvar_SkipFrame = (g_iCvar_SkipFrame > 0);
    g_bCvar_BlackAndWhite = g_hCvar_BlackAndWhite.BoolValue;
    g_iCvar_Team = g_hCvar_Team.IntValue;
    g_iCvar_SurvivorTeam = g_hCvar_SurvivorTeam.IntValue;
    g_iCvar_InfectedTeam = g_hCvar_InfectedTeam.IntValue;
    g_iCvar_SpectatorTeam = g_hCvar_SpectatorTeam.IntValue;
    g_iCvar_MultiplyAlphaTeam = g_hCvar_MultiplyAlphaTeam.IntValue;
    g_iCvar_ClientAlphaMax = g_hCvar_ClientAlphaMax.IntValue;
    g_bCvar_ClientAlphaMax = (g_iCvar_ClientAlphaMax > -1);
    g_fCvar_SurvivorWidth = g_hCvar_SurvivorWidth.FloatValue;
    g_fCvar_InfectedWidth = g_hCvar_InfectedWidth.FloatValue;
    g_iCvar_SI = g_hCvar_SI.IntValue;
    g_bTimer = (g_bCvar_Enabled && !g_bCvar_RenderFrame);

    delete g_tRenderInterval;
    if (g_bTimer)
        g_tRenderInterval = CreateTimer(0.1, TimerRender, _, TIMER_REPEAT);
}

/****************************************************************************************************/

void LateLoad()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        if (IsFakeClient(client))
            continue;

        if (AreClientCookiesCached(client))
            OnClientCookiesCached(client);
    }

    int entity;
    char classname[36];

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "*")) != INVALID_ENT_REFERENCE)
    {
        if (entity < 0)
            continue;

        GetEntityClassname(entity, classname, sizeof(classname));
        OnEntityCreated(entity, classname);
    }
}

/****************************************************************************************************/

public void OnClientCookiesCached(int client)
{
    if (IsFakeClient(client))
        return;

    if (!g_bCvar_Cookies)
        return;

    char cookieDisable[2];
    g_cbDisable.Get(client, cookieDisable, sizeof(cookieDisable));

    if (cookieDisable[0] != 0)
        gc_bDisable[client] = (StringToInt(cookieDisable) == 1 ? true : false);
}

/****************************************************************************************************/

public void OnClientDisconnect(int client)
{
    gc_bDisable[client] = false;
    gc_bShouldRender[client] = false;

    for (int target = 1; target <= MaxClients; target++)
    {
        gc_bVisible[target][client] = false;
        gc_fLastAttack[target][client] = 0.0;
    }
}

/****************************************************************************************************/

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity < 0)
        return;

    switch (classname[0])
    {
        case 't':
        {
            if (StrEqual(classname, "tank_rock"))
                ge_bInvalidTrace[entity] = true;
        }
        case 'i':
        {
            if (StrEqual(classname, "infected"))
                ge_bInvalidTrace[entity] = true;
        }
        case 'w':
        {
            if (StrEqual(classname, "witch"))
                ge_bInvalidTrace[entity] = true;
        }
    }
}

/****************************************************************************************************/

public void OnEntityDestroyed(int entity)
{
    if (entity < 0)
        return;

    ge_bInvalidTrace[entity] = false;
}

/****************************************************************************************************/

void HookEvents()
{
    if (g_bCvar_Enabled && !g_bEventsHooked)
    {
        g_bEventsHooked = true;

        HookEvent("player_hurt", Event_PlayerHurt);

        return;
    }

    if (!g_bCvar_Enabled && g_bEventsHooked)
    {
        g_bEventsHooked = false;

        UnhookEvent("player_hurt", Event_PlayerHurt);

        return;
    }
}

/****************************************************************************************************/

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bCvar_AttackDelay)
        return;

    int target = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (target == 0 || attacker == 0)
        return;

    gc_fLastAttack[target][attacker] = GetGameTime();
}

/****************************************************************************************************/

Action TimerRender(Handle timer)
{
    RenderHealthBar();

    return Plugin_Continue;
}

/****************************************************************************************************/

public void OnGameFrame()
{
    if (!g_bCvar_RenderFrame)
        return;

    if (!IsServerProcessing())
        return;

    if (!g_bCvar_Enabled)
        return;

    if (g_bCvar_SkipFrame)
    {
        if (++g_iFrameCount <= g_iCvar_SkipFrame)
            return;

        g_iFrameCount = 0;
    }

    RenderHealthBar();
}

/****************************************************************************************************/

void RenderHealthBar()
{
    for (int target = 1; target <= MaxClients; target++)
    {
        gc_bShouldRender[target] = ShouldRenderHP(target);

        if (!gc_bShouldRender[target])
            continue;

        CheckVisibility(target);

        bool isSurvivor;
        bool isIncapacitated = IsPlayerIncapacitated(target);

        int maxHealth = GetEntProp(target, Prop_Data, "m_iMaxHealth");
        int currentHealth = GetClientHealth(target);
        int targetTeam = GetClientTeam(target);
        int targetTeamFlag = GetTeamFlag(targetTeam);

        float width;

        switch (targetTeam)
        {
            case TEAM_SURVIVOR, TEAM_HOLDOUT:
            {
                isSurvivor = true;

                width = g_fCvar_SurvivorWidth;

                if (isIncapacitated)
                    maxHealth = g_iCvar_survivor_incap_health;
                else
                    currentHealth += GetClientTempHealth(target);
            }
            case TEAM_INFECTED:
            {
                width = g_fCvar_InfectedWidth;

                if (isIncapacitated)
                {
                    maxHealth = 0;
                }
                else
                {
                    if (currentHealth > maxHealth)
                    {
                        maxHealth = currentHealth;
                        SetEntProp(target, Prop_Data, "m_iMaxHealth", maxHealth); // Fix plugins that don't set the max HP for SI
                    }
                }
            }
        }

        float percentageHealth;

        if (maxHealth > 0)
            percentageHealth = (float(currentHealth) / float(maxHealth));

        int colorAlpha[4];
        GetEntityRenderColor(target, colorAlpha[0], colorAlpha[1], colorAlpha[2], colorAlpha[3]);

        int alpha;
        if (g_bCvar_ClientAlphaMax && colorAlpha[3] <= g_iCvar_ClientAlphaMax)
            alpha = 0;
        else if (targetTeamFlag & g_iCvar_MultiplyAlphaTeam)
            alpha = RoundFloat(g_iCvar_Alpha * colorAlpha[3] / 255.0);
        else
            alpha = g_iCvar_Alpha;

        int color[4];
        if (isIncapacitated)
        {
            color[0] = 255;
            color[1] = 0;
            color[2] = 0;
        }
        else if (isSurvivor && g_bCvar_BlackAndWhite && g_bCvar_survivor_max_incapacitated_count && IsPlayerBlackAndWhite(target))
        {
            color[0] = 255;
            color[1] = 255;
            color[2] = 255;
        }
        else if (isSurvivor && !g_bCvar_GradientColor)
        {
            if (currentHealth >= g_iCvar_survivor_limp_health)
            {
                color[0] = 0;
                color[1] = 255;
                color[2] = 0;
            }
            else if (currentHealth > LOW_HEALTH)
            {
                color[0] = 255;
                color[1] = 255;
                color[2] = 0;
            }
            else
            {
                color[0] = 255;
                color[1] = 0;
                color[2] = 0;
            }
        }
        else
        {
            bool halfHealth = (percentageHealth < 0.5);
            color[0] = halfHealth ? 255 : RoundFloat(255.0 * ((1.0 - percentageHealth) * 2));
            color[1] = halfHealth ? RoundFloat(255.0 * (percentageHealth) * 2) : 255;
            color[2] = 0;
        }
        color[3] = alpha;

        float targetPos[3];
        GetClientAbsOrigin(target, targetPos);
        targetPos[2] += g_fCvar_ZAxis;

        if (g_bCvar_AlignCenter)
        {
            float vPoint1[3];
            float vPoint2[3];

            vPoint1 = targetPos;
            vPoint2 = targetPos;
            vPoint2[2] += g_fCvar_Height;

            float currentWidth = width * percentageHealth;

            int colorFill[4];

            if (g_bCvar_Fill)
            {
                // fill bar
                int alphaFill;

                if (g_bCvar_ClientAlphaMax && colorAlpha[3] <= g_iCvar_ClientAlphaMax)
                    alphaFill = 0;
                else if (targetTeamFlag & g_iCvar_MultiplyAlphaTeam)
                    alphaFill = RoundFloat(g_iCvar_FillAlpha * alpha / 255.0);
                else
                    alphaFill = g_iCvar_FillAlpha;

                colorFill = color;
                colorFill[3] = alphaFill;
            }

            int[] clients = new int[MaxClients];
            int clientsCount;

            for (int client = 1; client <= MaxClients; client++)
            {
                if (!gc_bVisible[target][client])
                    continue;

                clients[clientsCount++] = client;
            }

            TE_SetupBeamPoints(vPoint1, vPoint2, g_iModelBeam, 0, 0, 0, g_fBeamLife, currentWidth, currentWidth, 0, 0.0, color, 0);
            TE_Send(clients, clientsCount);

            if (g_bCvar_Fill)
            {
                TE_SetupBeamPoints(vPoint1, vPoint2, g_iModelBeam, 0, 0, 0, g_fBeamLife, width, width, 0, 0.0, colorFill, 0);
                TE_Send(clients, clientsCount);
            }
        }
        else
        {
            float height = g_fCvar_Height / 2;

            for (int client = 1; client <= MaxClients; client++)
            {
                if (!gc_bVisible[target][client])
                    continue;

                float clientAng[3];
                GetClientEyeAngles(client, clientAng);

                // left
                float targetMin[3];
                targetMin = targetPos;
                targetMin[0] += width * Cosine(DegToRad(clientAng[1] + 90.0));
                targetMin[1] += width * Sine(DegToRad(clientAng[1] + 90.0));

                // right
                float targetMax[3];
                targetMax = targetPos;
                targetMax[0] += width * Cosine(DegToRad(clientAng[1] - 90.0));
                targetMax[1] += width * Sine(DegToRad(clientAng[1] - 90.0));

                // current
                float targetCurrent[3];
                targetCurrent = targetPos;
                targetCurrent[0] = (percentageHealth * (targetMax[0] - targetMin[0])) + targetMin[0];
                targetCurrent[1] = (percentageHealth * (targetMax[1] - targetMin[1])) + targetMin[1];

                float vPoint1[3];
                float vPoint2[3];

                // inside bar
                vPoint1 = targetMin;
                vPoint2 = targetCurrent;
                TE_SetupBeamPoints(vPoint1, vPoint2, g_iModelBeam, 0, 0, 0, g_fBeamLife, height, height, 0, 0.0, color, 0);
                TE_SendToClient(client);

                if (g_bCvar_Fill)
                {
                    // fill bar
                    int alphaFill;

                    if (g_bCvar_ClientAlphaMax && colorAlpha[3] <= g_iCvar_ClientAlphaMax)
                        alphaFill = 0;
                    else if (targetTeamFlag & g_iCvar_MultiplyAlphaTeam)
                        alphaFill = RoundFloat(g_iCvar_FillAlpha * alpha / 255.0);
                    else
                        alphaFill = g_iCvar_FillAlpha;

                    int colorFill[4];
                    colorFill = color;
                    colorFill[3] = alphaFill;
                    vPoint1 = targetCurrent;
                    vPoint2 = targetMax;
                    TE_SetupBeamPoints(vPoint1, vPoint2, g_iModelBeam, 0, 0, 0, g_fBeamLife, height, height, 0, 0.0, colorFill, 0);
                    TE_SendToClient(client);
                }
            }
        }
    }
}

/****************************************************************************************************/

bool ShouldRenderHP(int target)
{
    if (!IsClientInGame(target))
        return false;

    if (!IsPlayerAlive(target))
        return false;

    int targetTeam = GetClientTeam(target);
    int targetTeamFlag = GetTeamFlag(targetTeam);

    if (!(targetTeamFlag & g_iCvar_Team))
        return false;

    if (targetTeam == TEAM_INFECTED)
    {
        if (IsPlayerGhost(target))
            return false;

        if (!(GetZombieClassFlag(target) & g_iCvar_SI))
            return false;
    }

    return true;
}

/****************************************************************************************************/

void CheckVisibility(int target)
{
    int targetTeamFlag = GetTeamFlag(GetClientTeam(target));

    for (int client = 1; client <= MaxClients; client++)
    {
        gc_bVisible[target][client] = false;

        if (client == target)
            continue;

        if (gc_bDisable[client])
            continue;

        if (!IsClientInGame(client))
            continue;

        if (IsFakeClient(client))
            continue;

        int clientTeamFlag = GetTeamFlag(GetClientTeam(client));

        switch (clientTeamFlag)
        {
            case FLAG_TEAM_SURVIVOR, FLAG_TEAM_HOLDOUT:
            {
                if (!(targetTeamFlag & g_iCvar_SurvivorTeam))
                    continue;
            }
            case FLAG_TEAM_INFECTED:
            {
                if (!(targetTeamFlag & g_iCvar_InfectedTeam))
                    continue;
            }
            case FLAG_TEAM_SPECTATOR:
            {
                if (!(targetTeamFlag & g_iCvar_SpectatorTeam))
                    continue;
            }
        }

        if (g_bCvar_FadeDistance)
        {
            float targetPos[3];
            GetClientAbsOrigin(target, targetPos);

            float clientPos[3];
            GetClientAbsOrigin(client, clientPos);

            if (GetVectorDistance(targetPos, clientPos) > g_fCvar_FadeDistance)
                continue;
        }

        if (targetTeamFlag == FLAG_TEAM_INFECTED && clientTeamFlag == FLAG_TEAM_SURVIVOR)
        {
            if (g_bCvar_AttackDelay && (gc_fLastAttack[target][client] == 0.0 || GetGameTime() - gc_fLastAttack[target][client] > g_fCvar_AttackDelay))
                continue;

            if (g_bCvar_Sight && !IsVisibleTo(client, target))
                continue;
        }

        gc_bVisible[target][client] = true;
    }
}

/****************************************************************************************************/

bool IsVisibleTo(int client, int target)
{
    float vClientPos[3];
    float vEntityPos[3];
    float vLookAt[3];
    float vAng[3];

    GetClientEyePosition(client, vClientPos);
    GetClientEyePosition(target, vEntityPos);
    MakeVectorFromPoints(vClientPos, vEntityPos, vLookAt);
    GetVectorAngles(vLookAt, vAng);

    Handle trace = TR_TraceRayFilterEx(vClientPos, vAng, MASK_PLAYERSOLID, RayType_Infinite, TraceFilter, target);

    bool isVisible;

    if (TR_DidHit(trace))
    {
        isVisible = (TR_GetEntityIndex(trace) == target);

        if (!isVisible)
        {
            vEntityPos[2] -= 62.0; // Results the same as GetClientAbsOrigin

            delete trace;
            trace = TR_TraceHullFilterEx(vClientPos, vEntityPos, g_fvPlayerMins, g_fvPlayerMaxs, MASK_PLAYERSOLID, TraceFilter, target);

            if (TR_DidHit(trace))
                isVisible = (TR_GetEntityIndex(trace) == target);
        }
    }

    delete trace;

    return isVisible;
}

/****************************************************************************************************/

bool TraceFilter(int entity, int contentsMask, int client)
{
    if (entity == client)
        return true;

    if (IsValidClientIndex(entity))
        return false;

    return ge_bInvalidTrace[entity] ? false : true;
}

// ====================================================================================================
// Menus
// ====================================================================================================
void CreateToggleMenu(int client)
{
    Menu menu = new Menu(HandleToggleMenu);
    menu.SetTitle("HP Laser");

    if (gc_bDisable[client])
        menu.AddItem("0", "☐ OFF");
    else
        menu.AddItem("1", "☑ ON");

    menu.Display(client, MENU_TIME_FOREVER);
}

/****************************************************************************************************/

int HandleToggleMenu(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            int client = param1;

            char sArg[2];
            menu.GetItem(param2, sArg, sizeof(sArg));

            bool disable = (StringToInt(sArg) == 1 ? true : false);
            gc_bDisable[client] = disable;

            if (g_bCvar_Cookies)
                g_cbDisable.Set(client, disable ? "1" : "0");

            CreateToggleMenu(client);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}

// ====================================================================================================
// Commands
// ====================================================================================================
Action CmdHpMenu(int client, int args)
{
    if (!g_bCvar_Enabled)
        return Plugin_Handled;

    if (!IsValidClient(client))
        return Plugin_Handled;

    CreateToggleMenu(client);

    return Plugin_Handled;
}

/****************************************************************************************************/

Action CmdHideHp(int client, int args)
{
    if (!g_bCvar_Enabled)
        return Plugin_Handled;

    if (!IsValidClient(client))
        return Plugin_Handled;

    gc_bDisable[client] = true;
    g_cbDisable.Set(client, "1");

    return Plugin_Handled;
}

/****************************************************************************************************/

Action CmdShowHp(int client, int args)
{
    if (!g_bCvar_Enabled)
        return Plugin_Handled;

    if (!IsValidClient(client))
        return Plugin_Handled;

    gc_bDisable[client] = false;
    g_cbDisable.Set(client, "0");

    return Plugin_Handled;
}

// ====================================================================================================
// Admin Commands
// ====================================================================================================
Action CmdPrintCvars(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "======================================================================");
    PrintToConsole(client, "");
    PrintToConsole(client, "-------------------- Plugin Cvars (l4d_hp_laser) ---------------------");
    PrintToConsole(client, "");
    PrintToConsole(client, "l4d_hp_laser_version : %s", PLUGIN_VERSION);
    PrintToConsole(client, "l4d_hp_laser_enable : %b (%s)", g_bCvar_Enabled, g_bCvar_Enabled ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_cookies : %b (%s)", g_bCvar_Cookies, g_bCvar_Cookies ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_align_center : %b (%s)", g_bCvar_AlignCenter, g_bCvar_AlignCenter ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_z_axis : %.1f", g_fCvar_ZAxis);
    PrintToConsole(client, "l4d_hp_laser_fade_distance : %i (%s)", g_fCvar_FadeDistance, g_bCvar_FadeDistance ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_sight : %b (%s)", g_bCvar_Sight, g_bCvar_Sight ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_gradient_color : %b (%s)", g_bCvar_GradientColor, g_bCvar_GradientColor ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_model : \"%s\"", g_sCvar_Model);
    PrintToConsole(client, "l4d_hp_laser_alpha : %i", g_iCvar_Alpha);
    PrintToConsole(client, "l4d_hp_laser_height : %.1f", g_fCvar_Height);
    PrintToConsole(client, "l4d_hp_laser_fill : %b (%s)", g_bCvar_Fill, g_bCvar_Fill ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_fill_alpha : %i", g_iCvar_FillAlpha);
    PrintToConsole(client, "l4d_hp_laser_render_frame : %b (%s)", g_bCvar_RenderFrame, g_bCvar_RenderFrame ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_skip_frame : %i (%s)", g_iCvar_SkipFrame, g_bCvar_SkipFrame ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_black_and_white : %b (%s)", g_bCvar_BlackAndWhite, g_bCvar_BlackAndWhite ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_team : %i (SPECTATOR = %s | SURVIVOR = %s | INFECTED = %s | HOLDOUT = %s)", g_iCvar_Team,
    g_iCvar_Team & FLAG_TEAM_SPECTATOR ? "true" : "false", g_iCvar_Team & FLAG_TEAM_SURVIVOR ? "true" : "false", g_iCvar_Team & FLAG_TEAM_INFECTED ? "true" : "false", g_iCvar_Team & FLAG_TEAM_HOLDOUT ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_survivor_team : %i (SPECTATOR = %s | SURVIVOR = %s | INFECTED = %s | HOLDOUT = %s)", g_iCvar_SurvivorTeam,
    g_iCvar_SurvivorTeam & FLAG_TEAM_SPECTATOR ? "true" : "false", g_iCvar_SurvivorTeam & FLAG_TEAM_SURVIVOR ? "true" : "false", g_iCvar_SurvivorTeam & FLAG_TEAM_INFECTED ? "true" : "false", g_iCvar_SurvivorTeam & FLAG_TEAM_HOLDOUT ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_infected_team : %i (SPECTATOR = %s | SURVIVOR = %s | INFECTED = %s | HOLDOUT = %s)", g_iCvar_InfectedTeam,
    g_iCvar_InfectedTeam & FLAG_TEAM_SPECTATOR ? "true" : "false", g_iCvar_InfectedTeam & FLAG_TEAM_SURVIVOR ? "true" : "false", g_iCvar_InfectedTeam & FLAG_TEAM_INFECTED ? "true" : "false", g_iCvar_InfectedTeam & FLAG_TEAM_HOLDOUT ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_spectator_team : %i (SPECTATOR = %s | SURVIVOR = %s | INFECTED = %s | HOLDOUT = %s)", g_iCvar_SpectatorTeam,
    g_iCvar_SpectatorTeam & FLAG_TEAM_SPECTATOR ? "true" : "false", g_iCvar_SpectatorTeam & FLAG_TEAM_SURVIVOR ? "true" : "false", g_iCvar_SpectatorTeam & FLAG_TEAM_INFECTED ? "true" : "false", g_iCvar_SpectatorTeam & FLAG_TEAM_HOLDOUT ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_multiply_alpha_team : %i", g_iCvar_MultiplyAlphaTeam);
    PrintToConsole(client, "l4d_hp_laser_client_alpha_max : %i (%s)", g_iCvar_ClientAlphaMax, g_bCvar_ClientAlphaMax ? "true" : "false");
    PrintToConsole(client, "l4d_hp_laser_survivor_width : %.1f", g_fCvar_SurvivorWidth);
    PrintToConsole(client, "l4d_hp_laser_infected_width : %.1f", g_fCvar_InfectedWidth);
    if (g_bL4D2)
    {
        PrintToConsole(client, "l4d_hp_laser_si : %i (SMOKER = %s | BOOMER = %s | HUNTER = %s | SPITTER = %s | JOCKEY = %s | CHARGER = %s | TANK = %s)", g_iCvar_SI,
        g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_SMOKER ? "true" : "false", g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_BOOMER ? "true" : "false", g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_HUNTER ? "true" : "false", g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_SPITTER ? "true" : "false",
        g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_JOCKEY ? "true" : "false", g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_CHARGER ? "true" : "false", g_iCvar_SI & L4D2_FLAG_ZOMBIECLASS_TANK ? "true" : "false");
    }
    else
    {
        PrintToConsole(client, "l4d_hp_laser_si : %i (SMOKER = %s | BOOMER = %s | HUNTER = %s | TANK = %s)", g_iCvar_SI,
        g_iCvar_SI & L4D1_FLAG_ZOMBIECLASS_SMOKER ? "true" : "false", g_iCvar_SI & L4D1_FLAG_ZOMBIECLASS_BOOMER ? "true" : "false", g_iCvar_SI & L4D1_FLAG_ZOMBIECLASS_HUNTER ? "true" : "false", g_iCvar_SI & L4D1_FLAG_ZOMBIECLASS_TANK ? "true" : "false");
    }
    PrintToConsole(client, "");
    PrintToConsole(client, "---------------------------- Game Cvars  -----------------------------");
    PrintToConsole(client, "");
    PrintToConsole(client, "survivor_incap_health : %i", g_iCvar_survivor_incap_health);
    PrintToConsole(client, "survivor_max_incapacitated_count : %i", g_iCvar_survivor_max_incapacitated_count);
    PrintToConsole(client, "pain_pills_decay_rate : %.1f", g_fCvar_pain_pills_decay_rate);
    PrintToConsole(client, "survivor_limp_health : %i", g_iCvar_survivor_limp_health);
    PrintToConsole(client, "");
    PrintToConsole(client, "======================================================================");
    PrintToConsole(client, "");

    return Plugin_Handled;
}

// ====================================================================================================
// Helpers
// ====================================================================================================
/**
 * Validates if is a valid client index.
 *
 * @param client        Client index.
 * @return              True if client index is valid, false otherwise.
 */
bool IsValidClientIndex(int client)
{
    return (1 <= client <= MaxClients);
}

/****************************************************************************************************/

/**
 * Validates if is a valid client.
 *
 * @param client          Client index.
 * @return                True if client index is valid and client is in game, false otherwise.
 */
bool IsValidClient(int client)
{
    return (IsValidClientIndex(client) && IsClientInGame(client));
}

/****************************************************************************************************/

/**
 * Gets the client L4D1/L4D2 zombie class id.
 *
 * @param client        Client index.
 * @return L4D1         1=SMOKER, 2=BOOMER, 3=HUNTER, 4=WITCH, 5=TANK, 6=NOT INFECTED
 * @return L4D2         1=SMOKER, 2=BOOMER, 3=HUNTER, 4=SPITTER, 5=JOCKEY, 6=CHARGER, 7=WITCH, 8=TANK, 9=NOT INFECTED
 */
int GetZombieClass(int client)
{
    return (GetEntProp(client, Prop_Send, "m_zombieClass"));
}

/****************************************************************************************************/

/**
 * Returns the zombie class flag from a zombie class.
 *
 * @param client        Client index.
 * @return              Client zombie class flag.
 */
int GetZombieClassFlag(int client)
{
    int zombieClass = GetZombieClass(client);

    if (g_bL4D2)
    {
        switch (zombieClass)
        {
            case L4D2_ZOMBIECLASS_SMOKER:
                return L4D2_FLAG_ZOMBIECLASS_SMOKER;
            case L4D2_ZOMBIECLASS_BOOMER:
                return L4D2_FLAG_ZOMBIECLASS_BOOMER;
            case L4D2_ZOMBIECLASS_HUNTER:
                return L4D2_FLAG_ZOMBIECLASS_HUNTER;
            case L4D2_ZOMBIECLASS_SPITTER:
                return L4D2_FLAG_ZOMBIECLASS_SPITTER;
            case L4D2_ZOMBIECLASS_JOCKEY:
                return L4D2_FLAG_ZOMBIECLASS_JOCKEY;
            case L4D2_ZOMBIECLASS_CHARGER:
                return L4D2_FLAG_ZOMBIECLASS_CHARGER;
            case L4D2_ZOMBIECLASS_TANK:
                return L4D2_FLAG_ZOMBIECLASS_TANK;
            default:
                return L4D2_FLAG_ZOMBIECLASS_NONE;
        }
    }
    else
    {
        switch (zombieClass)
        {
            case L4D1_ZOMBIECLASS_SMOKER:
                return L4D1_FLAG_ZOMBIECLASS_SMOKER;
            case L4D1_ZOMBIECLASS_BOOMER:
                return L4D1_FLAG_ZOMBIECLASS_BOOMER;
            case L4D1_ZOMBIECLASS_HUNTER:
                return L4D1_FLAG_ZOMBIECLASS_HUNTER;
            case L4D1_ZOMBIECLASS_TANK:
                return L4D1_FLAG_ZOMBIECLASS_TANK;
            default:
                return L4D1_FLAG_ZOMBIECLASS_NONE;
        }
    }
}

/****************************************************************************************************/

/**
 * Returns is a player is in ghost state.
 *
 * @param client        Client index.
 * @return              True if client is in ghost state, false otherwise.
 */
bool IsPlayerGhost(int client)
{
    return (GetEntProp(client, Prop_Send, "m_isGhost") == 1);
}

/****************************************************************************************************/

/**
 * Validates if the client is incapacitated.
 *
 * @param client        Client index.
 * @return              True if the client is incapacitated, false otherwise.
 */
bool IsPlayerIncapacitated(int client)
{
    return (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1);
}

/****************************************************************************************************/

/**
 * Validates if the client is in black and white.
 *
 * @param client        Client index.
 * @return              True if the client is in black and white, false otherwise.
 */
bool IsPlayerBlackAndWhite(int client)
{
    return (GetEntProp(client, Prop_Send, "m_currentReviveCount") >= g_iCvar_survivor_max_incapacitated_count);
}

/****************************************************************************************************/

/**
 * Returns the team flag from a team.
 *
 * @param team          Team index.
 * @return              Team flag.
 */
int GetTeamFlag(int team)
{
    switch (team)
    {
        case TEAM_SURVIVOR:
            return FLAG_TEAM_SURVIVOR;
        case TEAM_INFECTED:
            return FLAG_TEAM_INFECTED;
        case TEAM_SPECTATOR:
            return FLAG_TEAM_SPECTATOR;
        case TEAM_HOLDOUT:
            return FLAG_TEAM_HOLDOUT;
        default:
            return FLAG_TEAM_NONE;
    }
}

/****************************************************************************************************/

// ====================================================================================================
// Thanks to Silvers
// ====================================================================================================
/**
 * Returns the client temporary health.
 *
 * @param client        Client index.
 * @return              Client temporary health.
 */
int GetClientTempHealth(int client)
{
    int tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * g_fCvar_pain_pills_decay_rate));
    return tempHealth < 0 ? 0 : tempHealth;
}