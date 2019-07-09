if (!isServer and hasInterface) exitWith {};

private ["_markerX","_positionX","_isRoad","_tam","_road","_veh","_grupo","_unit","_roadcon"];

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;

_NATOSupp = server getVariable "prestigeNATO";

_grupo = createGroup side_blue;

_spawnData = [_positionX, [citiesX, _positionX] call BIS_fnc_nearestPosition] call AS_fnc_findRoadspot;
_spawnPos = _spawnData select 0;
_spawnDir = _spawnData select 1;

_objs = [];

if (activeUSAF) then {
	_objs = [_spawnPos, _spawnDir + 180, call (compile (preprocessFileLineNumbers "Compositions\cmpUSAF_RB.sqf"))] call BIS_fnc_ObjectsMapper;
}
else {
	_objs = [_spawnPos, _spawnDir + 180, call (compile (preprocessFileLineNumbers "Compositions\cmpNATO_RB.sqf"))] call BIS_fnc_ObjectsMapper;
};


_vehArray = [];
_turretArray = [];
_tempPos = [];
{
	call {
		_normalPos = surfaceNormal (position _x);
		_x setVectorUp _normalPos;
		if (typeOf _x in bluAPC) exitWith {_vehArray pushBack _x;};
		if (typeOf _x in bluStatHMG) exitWith {_turretArray pushBack _x;};
		if (typeOf _x in bluStatAA) exitWith {_turretArray pushBack _x;};
		if (typeOf _x == "Land_Camping_Light_F") exitWith {_tempPos = _x;};
	};
} forEach _objs;

_veh = _vehArray select 0;
_HMG = _turretArray select 0;
_AA1 = _turretArray select 1;
_AA2 = _turretArray select 2;

if (_NATOSupp < 50) then {
	_AA1 enableSimulation false;
    _AA1 hideObjectGlobal true;

	if !(activeUSAF) then {
   		_AA2 enableSimulation false;
    	_AA2 hideObjectGlobal true;
	};
}
else {
	_unit = ([_positionX, 0, bluCrew, _grupo] call bis_fnc_spawnvehicle) select 0;
	_unit moveInGunner _AA1;

	if !(activeUSAF) then {
		_unit = ([_positionX, 0, bluCrew, _grupo] call bis_fnc_spawnvehicle) select 0;
		_unit moveInGunner _AA2;
	};
};

sleep 1;

_veh lock 3;
_veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];
[_veh] spawn NATOVEHinit;
_veh allowCrewInImmobile true;
sleep 1;

_typeGroup = [bluATTeam, side_blue] call AS_fnc_pickGroup;
_grupoInf = [getpos _tempPos, side_blue, _typeGroup] call BIS_Fnc_spawnGroup;

_grupoInf setFormDir _spawnDir;

_unit = ([_positionX, 0, bluCrew, _grupo] call bis_fnc_spawnvehicle) select 0;
_unit moveInGunner _HMG;
_unit = ([_positionX, 0, bluCrew, _grupo] call bis_fnc_spawnvehicle) select 0;
_unit moveInGunner _veh;
_unit = ([_positionX, 0, bluCrew, _grupo] call bis_fnc_spawnvehicle) select 0;
_unit moveInCommander _veh;

{[_x] spawn NATOinitCA} forEach units _grupo;
{[_x] spawn NATOinitCA} forEach units _grupoInf;


waitUntil {sleep 1; (not(spawner getVariable _markerX)) or (({alive _x} count units _grupo == 0) && ({alive _x} count units _grupoInf == 0)) or (not(_markerX in puestosNATO))};

if ({alive _x} count units _grupo == 0) then {
	puestosNATO = puestosNATO - [_markerX]; publicVariable "puestosNATO";
	markers = markers - [_markerX]; publicVariable "markers";
	[5,-5,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	deleteMarker _markerX;
	{["TaskFailed", ["", localize "STR_NTS_RBLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
};

waitUntil {sleep 1; (not(spawner getVariable _markerX)) or (not(_markerX in puestosNATO))};

{deleteVehicle _x} forEach _vehArray + _turretArray;
{deleteVehicle _x} forEach units _grupo;
deleteGroup _grupo;

{deleteVehicle _x} forEach units _grupoInf;
deleteGroup _grupoInf;

{deleteVehicle _x} forEach _objs;