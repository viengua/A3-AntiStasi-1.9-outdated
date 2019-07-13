if (!isServer and hasInterface) exitWith {};

private ["_roads"];

_positionTel = _this select 0;

_prestigio = server getVariable "prestigeNATO";
_base = bases - mrkAAF + ["spawnNATO"];

_originX = [_base,Slowhand] call BIS_fnc_nearestPosition;
_orig = getMarkerPos _originX;

[-10,0] remoteExec ["prestige",2];


_timeLimit = 30 max _prestigio;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameOrigin = [_originX] call AS_fnc_localizar;


_texto = "STR_GL_NATORB";
_typeGroup = [bluATTeam, side_blue] call AS_fnc_pickGroup;
_typeVehX = bluAPC select 0;


_mrk = createMarker [format ["NATOPost%1", random 1000], _positionTel];
_mrk setMarkerShape "ICON";


_tsk = ["NATORoadblock",[side_blue,civilian],[["%1 is dispatching a team to establish a Roadblock. Send and cover the team until reaches its destination.", A3_Str_BLUE],["%1 Roadblock Deployment", A3_Str_BLUE],_mrk],_positionTel,"CREATED",5,true,true,"Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";
_grupo = [_orig, side_blue, _typeGroup] call BIS_Fnc_spawnGroup;
_grupo setGroupId ["Watch"];

_tam = 10;
while {true} do
	{
	_roads = _orig nearRoads _tam;
	if (count _roads < 1) then {_tam = _tam + 10};
	if (count _roads > 0) exitWith {};
	};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,"B_APC_Wheeled_01_cannon_F"];
_truckX = _typeVehX createVehicle _pos;
_grupo addVehicle _truckX;

{
	_x assignAsCargo _truckX;
	_x moveInCargo _truckX;
} forEach units _grupo;

{[_x] call NATOinitCA} forEach units _grupo;
leader _grupo setBehaviour "SAFE";

Slowhand hcSetGroup [_grupo];
_grupo setVariable ["isHCgroup", true, true];

waitUntil {sleep 1; ({alive _x} count units _grupo == 0) or ({(alive _x) and (_x distance _positionTel < 10)} count units _grupo > 0) or (dateToNumber date > _dateLimitNum)};

if ({(alive _x) and (_x distance _positionTel < 10)} count units _grupo > 0) then {
	if (isPlayer leader _grupo) then {
		_owner = (leader _grupo) getVariable ["owner",leader _grupo];
		(leader _grupo) remoteExec ["removeAllActions",leader _grupo];
		_owner remoteExec ["selectPlayer",leader _grupo];
		(leader _grupo) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _grupo)};
	};

	Slowhand hcRemoveGroup _grupo;
	{deleteVehicle _x} forEach units _grupo;
	deleteVehicle _truckX;
	deleteGroup _grupo;
	sleep 1;

	outpostsNATO = outpostsNATO + [_mrk]; publicVariable "outpostsNATO";
	markers = markers + [_mrk]; publicVariable "markers";
	spawner setVariable [_mrk,false,true];
	_tsk = ["NATORoadblock",[side_blue,civilian],[["%3 successfully deployed a roadblock, They will hold their position until %1:%2.",numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["%1 Roadblock Deployment", A3_Str_BLUE],_mrk],_positionTel,"SUCCEEDED",5,true,true,"Move"] call BIS_fnc_setTask;

	_mrk setMarkerType "flag_Spain";
	//_mrk setMarkerColor "ColorBlue";
	_mrk setMarkerText localize _texto;


	waitUntil {sleep 60; (dateToNumber date > _dateLimitNum)};

	outpostsNATO = outpostsNATO - [_mrk]; publicVariable "outpostsNATO";
	markers = markers - [_mrk]; publicVariable "markers";
	deleteMarker _mrk;
	sleep 15;
	[0,_tsk] spawn deleteTaskX;
}
else {
	_tsk = ["NATORoadblock",[side_blue,civilian],[["%1 is dispatching a team to establish an Observation Post or Roadblock. Send and cover the team until reaches it's destination.", A3_Str_BLUE],["%1 Roadblock Deployment", A3_Str_BLUE],_mrk],_positionTel,"FAILED",5,true,true,"Move"] call BIS_fnc_setTask;
	sleep 3;
	deleteMarker _mrk;

	Slowhand hcRemoveGroup _grupo;
	{deleteVehicle _x} forEach units _grupo;
	deleteVehicle _truckX;
	deleteGroup _grupo;

	sleep 15;

	[0,_tsk] spawn deleteTaskX;
};
