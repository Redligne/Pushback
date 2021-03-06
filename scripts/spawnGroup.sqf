// [_position, _nombre(, _type, _faction)] call BwS_fn_spawnGroup;

private ["_position", "_eastHQ", "_group", "_soldats", "_nombre"];

_position = (_this select 0);
_nombre = (_this select 1);

_type = (_this select 2);

if (count _this == 4) then {_eastHQ = createCenter (_this select 3);}
else {_eastHQ = createCenter East;};

_group = createGroup _eastHQ;

_soldats = ["B_G_Soldier_LAT_F", "B_G_Soldier_AR_F", "B_G_Soldier_GL_F", "B_G_soldier_exp_F", "B_G_medic_F", "B_G_Soldier_F", "B_G_Sharpshooter_F", "O_Soldier_AA_F"];

if (count _this >= 3) then {
	if (_type == East) then 
	{
		_soldats = [];
		_soldats = ["O_Soldier_LAT_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_soldier_exp_F", "O_medic_F", "O_Soldier_F", "O_Sharpshooter_F", "O_Soldier_AA_F"];
	};

	if (_type == West) then 
	{
		_soldats = [];
		_soldats = ["B_Soldier_LAT_F", "B_Soldier_AR_F", "B_Soldier_GL_F", "B_soldier_exp_F", "B_medic_F", "B_Soldier_F", "B_Sharpshooter_F", "B_Soldier_AA_F"];
	};
	
	if (_type == resistance) then
	{
		_soldats = [];
		_soldats = ["rhs_g_Soldier_GL_F", "rhs_g_Soldier_AR_F", "rhs_g_Soldier_LAT_F", "rhs_g_Soldier_exp_F", "rhs_g_medic_F", "rhs_g_Soldier_F2", "rhs_g_Soldier_M_F", "rhs_g_Soldier_AA_F"];
	};
};

for "_i" from 0 to (_nombre - 1) do 
{
	(_soldats select (floor (random count _soldats))) createUnit [_position, _group, "this addItem ""NVGoggles""; this assignItem ""NVGoggles"" ", 1];
};

{	[_x] spawn BwS_fn_gestion_radio;	} forEach units _group;

_group
