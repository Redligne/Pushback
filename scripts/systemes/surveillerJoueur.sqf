#define JOUEUR_EST_DANS_PC ((player distance (nearestObject [player, "Land_Cargo_Tower_V1_F"])) < 10) && ((getPosATL player select 2) > 12) && (playerInHQ isEqualTo false) && ((((getMarkerPos "PC") distance (position player)) < 20) || (((getMarkerPos "PC_1") distance (position player)) < 20))

#define CONDITION_DRONISTE (("B_UavTerminal" in (items player + assignedItems player)) || ("O_UavTerminal" in (items player + assignedItems player))) && !joueurDroniste

#define CONDITION_INTERDICTION_UAV (backpack player == "B_UAV_01_backpack_F") || (backpack player == "O_UAV_01_backpack_F") || (backpack player == "I_UAV_01_backpack_F") || (backpack player == "B_rhsusf_B_BACKPACK")

#define CONDITION_TWS ("Weapon_optic_tws" in (primaryWeaponItems player)) || ("Weapon_optic_tws_mg" in (primaryWeaponItems player)) 

#define CONDITION_JUMELLES ("ACE_MX2A" in [(binocular player)])

#define CONDITION_PILOTE ((vehicle player) isKindOf "Air" && !(joueurPilote) && (driver vehicle player == player) && !(typeOf vehicle player isEqualTo "Steerable_Parachute_F"))

private ["_actionDetecteur", "_actionTranchee"];

startLoadingScreen ["Chargement en cours"];

/*------------ Cleanup post mortem ------------*/
removeAllActions player;
terminate BwS_handle_detecteurMines;

waitUntil {!isNull player};

/*---------- Initialisation des variables ------------*/
playerInHQ = false;

joueurPilote = false;
joueurEOD = false;
joueurDroniste = false;

_UIDs = ["_SP_PLAYER_", "76561198118269478", "76561198067811595"];

if (getplayeruid player in _UIDs) then {player addAction ["<t color='#69c0ef' size='1.5'>Teleportafion</t>",{ onMapSingleClick {vehicle player setpos _pos; onMapSingleClick ""}}, [], 1, false, true, ""]};
onMapSingleClick "_shift";

// if ((getPlayerUID player) in BwS_joueurs_BwS) then {
	// player setVariable ["R3F_LOG_CF_disabled", false];
// }
// else {
	// player setVariable ["R3F_LOG_CF_disabled", true];
// };

_actionDetecteur = 1338;
_actionTranchee = 1339;

if ((player getVariable "pilote") isEqualTo true) then {joueurPilote = true;};
if ((player getVariable "AGM_isEOD") isEqualTo true) then {joueurEOD = true;};
if ((player getVariable "droniste") isEqualTo true) then {joueurDroniste = true;};

detecter = false;
if (joueurEOD) then {BwS_handle_detecteurMines = [] execVM "scripts\detecteurMines.sqf";};

player addAction ["Activer le détecteur de mines", {detecter = true; [0, 0, (_this select 2)] execVM "scripts\detecteurMines.sqf";}, [], 1.5, false, true, "", str ("MineDetector" in (items player) && joueurEOD)];

[] spawn {
	while {alive player} do {
		if ((vehicle player == FOBa) ||
			(vehicle player == FOBb) ||
			(vehicle player == FOBA_R) ||
			(vehicle player == FOBB_R)) then 
		{	
			if !(player getVariable ["tf_unable_to_use_radio", false]) then 
			{
				BwS_script_vehiculeRadar = [] execVM "scripts\vehiculeRadar.sqf";
				waitUntil {scriptDone BwS_script_vehiculeRadar};		
			};
		};
		sleep 0.01;
	};
};

[] spawn {
	BwS_MUTEX_peut_rejoindre_champ_de_bataille = false;
	_futur = time + 300;
	waitUntil {hintSilent format ["%1:%2 avant TP possible", floor ((_futur-time)/60), floor ((_futur-time)%60)]; sleep 1; time >= _futur}; 
	BwS_MUTEX_peut_rejoindre_champ_de_bataille = true;
	hint "TP possible";
};

waituntil {preloadCamera position player};
endLoadingScreen;

player disableTIEquipment true;

while {alive player} do
{
	[player, "OperationPushBack"] call BIS_fnc_setUnitInsignia;
	
	if (JOUEUR_EST_DANS_PC) then
	{
		[player] execVM "scripts\HQ\HQ.sqf";
		playerInHQ = true;
		
		waitUntil {((player distance (nearestObject [player, "Land_Cargo_Tower_V1_F"])) > 10) || ((getPosATL player select 2) < 12)};
		
		playerInHQ = false;
		removeBackpack player;
	};
	
	if (CONDITION_DRONISTE) then // Pour le slot droniste
	{
		hintC "Vous devez être droniste pour contrôler un drone !";
		player unassignItem "B_UavTerminal";
		player unassignItem "O_UavTerminal";
		player removeItem "B_UavTerminal";
		player removeItem "O_UavTerminal";
	};
	
	if (CONDITION_INTERDICTION_UAV) then
	{
		removeBackpack player;
		hintC "Les UAV sont interdits.";
	};
	
	if (CONDITION_TWS) then
	{
		player removePrimaryWeaponItem "Weapon_optic_tws";
		player removePrimaryWeaponItem "Weapon_optic_tws_mg";
	};
	
	if (CONDITION_JUMELLES) then
	{
		player removeWeapon (binocular player);
	};
	
	if (CONDITION_PILOTE) then {moveOut player; hintC "Vous devez être pilote !"; }; // on jarte du véhicule s'il n'est pas pilote
	
	if (("ACE_wirecutter" in (items player + assignedItems player)) && (_actionTranchee == 1339)) then  
	{
		_actionTranchee = player addAction ["Creuser une tranchée", 
							{
								player removeAction (_this select 2);
								player switchMove "AinvPknlMstpSnonWnonDnon_medic0"; 
								_temps = time + 7; waitUntil {time >= _temps}; 
								_dirPlayer = direction player;
								_tranchee = "CraterLong" createVehicle [(position player select 0), (position player select 1), (position player select 2)]; 
								_tranchee setDir _dirPlayer+90;
								_tranchee addAction ["Refermer la tranchée", {deleteVehicle (_this select 0); (_this select 0) removeAction (_this select 2);}];
							}
							];
	};
	
	if (("MineDetector" in items player) && joueurEOD && (_actionDetecteur == 1338)) then 
	{
		_actionDetecteur = player addAction ["Activer le détecteur de mines", 
		{
			_target = _this select 0;
			_action = _this select 2;
			
			if (detecter) then 
			{
				_target setUserActionText [_action, "Activer le détecteur de mines"]; 
				detecter = false;
			}
			
			else
			{
				_target setUserActionText [_action, "Désactiver le détecteur de mines"]; 
				detecter = true;
			};
		}];
	};
	
	if (!("MineDetector" in (items player + assignedItems player)) && !(_actionDetecteur == 1338)) then {player removeAction _actionDetecteur; _actionDetecteur = 1338;};
	if (!("ACE_wirecutter" in (items player + assignedItems player)) && !(_actionTranchee == 1339)) then {player removeAction _actionTranchee; _actionTranchee = 1339;};
	
	showChat true;
		
	// ouverture automatique de barrière
	
	if ((player distance (nearestObject [player, "Land_BarGate_F"])) < 8) then
	{
		[] spawn { (nearestObject [player, "Land_BarGate_F"]) animate ["Door_1_rot", 1]; sleep 5; (nearestObject [player, "Land_BarGate_F"]) animate ["Door_1_rot", 0]; };
	};
	
	call BwS_fn_brouillage_local;
	
	sleep 0.1;
};