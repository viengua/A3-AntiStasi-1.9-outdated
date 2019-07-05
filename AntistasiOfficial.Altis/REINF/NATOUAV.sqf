if (!isServer and hasInterface) exitWith {};

_prestigio = server getVariable "prestigeNATO";
_airportsX = airportsX - mrkAAF + ["spawnNATO"];

_origen = [_airportsX,Slowhand] call BIS_fnc_nearestPosition;
_orig = getMarkerPos _origen;

[-10,0] remoteExec ["prestige",2];

_tiempolim = 30;
_fechalim = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _tiempolim];
_dateLimitNum = dateToNumber _fechalim;

_nameOrigin = format ["the %1 Carrier", A3_Str_BLUE];
if (_origen!= "spawnNATO") then {_nameOrigin = [_origen] call AS_fnc_localizar};

_tsk = ["NATOUAV",[side_blue,civilian],[["STR_TSK_UAV_DESC",_nameOrigin,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["STR_TSK_UAV_TITLE", A3_Str_BLUE],_origen],_orig,"CREATED",5,true,true,"Attack"] call BIS_fnc_setTask;
misiones pushBack _tsk; publicVariable "misiones";

_soldados = [];
_vehiculos = [];

_grupoHeli = createGroup side_blue;
_grupoHeli setVariable ["esNATO",true,true];
_grupoHeli setGroupId ["UAV"];
hint format [localize "STR_TSK_NUAV_UAVWBAOHC", A3_Str_BLUE];

for "_i" from 1 to 1 do
	{
	_helifn = [_orig, 0, selectRandom bluUAV, side_blue] call bis_fnc_spawnvehicle;
	_heli = _helifn select 0;
	_heli setVariable ["BLUFORSpawn",false];
	_vehiculos pushBack _heli;
	createVehicleCrew _heli;
	_heliCrew = crew _heli;
	{[_x] spawn NATOinitCA; _soldados pushBack _x; [_x] join _grupoHeli} forEach _heliCrew;
	_heli setPosATL [getPosATL _heli select 0, getPosATL _heli select 1, 1000];
	_heli flyInHeight 300;

	sleep 10;
	};
Slowhand hcSetGroup [_grupoHeli];
_grupoHeli setVariable ["isHCgroup", true, true];

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or ({alive _x} count _vehiculos == 0) or ({canMove _x} count _vehiculos == 0)};

if (dateToNumber date > _dateLimitNum) then
	{
	{["TaskSucceeded", ["", format [localize "STR_NTS_UAV_FIN", A3_Str_BLUE]]] call BIS_fnc_showNotification} remoteExec ["call", 0];
	}
else
	{
	_tsk = ["NATOUAV",[side_blue,civilian],[["STR_TSK_UAV_DESC",_nameOrigin,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["STR_TSK_UAV_TITLE", A3_Str_BLUE],_origen],_orig,"FAILED",5,true,true,"Attack"] call BIS_fnc_setTask;
	[-5,0] remoteExec ["prestige",2];
	};

[0,_tsk] spawn deleteTaskX;

{deleteVehicle _x} forEach _soldados;
{deleteVehicle _x} forEach _vehiculos;
deleteGroup _grupoheli;