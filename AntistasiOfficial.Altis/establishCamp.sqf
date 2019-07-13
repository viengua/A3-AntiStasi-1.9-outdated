if (!isServer) exitWith {};

private ["_tipo","_costs","_grupo","_unit","_tam","_roads","_road","_pos","_truckX","_texto","_mrk","_hr","_unitsX","_formatX"];

_tipo = _this select 0;
_positionTel = _this select 1;

if (_tipo == "delete") exitWith {
	_mrk = [campsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	_txt = markerText _mrk;
	hint format ["Deleting %1", _txt];
	_costs = 0;
	_hr = 0;
	_formatX = ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _hr = _hr +1} forEach _typeGroup;
	[_hr,_costs] remoteExec ["resourcesFIA",2];
	deleteMarker _mrk;
	campsFIA = campsFIA - [_mrk]; publicVariable "campsFIA";
	campList = campList - [[_mrk, _txt]]; publicVariable "campList";
	usedCN = usedCN - [_txt]; publicVariable "usedCN";
	diag_log format ["deleting: %1", [_txt]];
	markers = markers - [_mrk]; publicVariable "markers";
};

_nameOptions = campNames - usedCN;
_texto = selectRandom _nameOptions;
_typeVehX = guer_veh_truck;

_mrk = createMarker [format ["FIACamp%1", random 1000], _positionTel];
_mrk setMarkerShape "ICON";

_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + 60];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"CREATED",5,true,true,"Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";

_tam = 10;
while {true} do {
	_roads = getMarkerPos guer_respawn nearRoads _tam;
	if (count _roads < 1) then {_tam = _tam + 10};
	if (count _roads > 0) exitWith {};
};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];

_vehicle=[_pos, 0,guer_veh_truck, side_blue] call bis_fnc_spawnvehicle;
_truckX = _vehicle select 0;
_truckX deleteVehicleCrew driver _truckX;

_grupo = [getMarkerPos guer_respawn, side_blue, ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
_grupo setGroupId ["Camp"];
{
	if (_forEachIndex == 0) then {
		_x moveInDriver _truckX;
	} else {
		_x moveInCargo _truckX;
	};
} forEach units _grupo;
{[_x] call AS_fnc_initialiseFIAUnit;} forEach units _grupo;

[_grupo, driver _truckX] remoteExec ["selectLeader", groupOwner _grupo];
leader _grupo setBehaviour "SAFE";
driver _truckX action ["engineOn", _truckX];
[_grupo] spawn dismountFIA;

Slowhand hcSetGroup [_grupo];
_grupo setVariable ["isHCgroup", true, true];

_crate = "Box_FIA_Support_F" createVehicle _pos;
_crate attachTo [_truckX,[0.0,-1.2,0.5]];

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
	campsFIA = campsFIA + [_mrk]; publicVariable "campsFIA";
	campList = campList + [[_mrk, _texto]]; publicVariable "campList";
	markers = markers + [_mrk];
	publicVariable "markers";
	spawner setVariable [_mrk,false,true];
	_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"SUCCEEDED",5,true,true,"Move"] call BIS_fnc_setTask;
	_mrk setMarkerType "loc_bunker";
	_mrk setMarkerColor "ColorOrange";
	_mrk setMarkerText _texto;
	usedCN pushBack _texto;
}
else {
	_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"FAILED",5,true,true,"Move"] call BIS_fnc_setTask;
	sleep 3;
	deleteMarker _mrk;
};

Slowhand hcRemoveGroup _grupo;
{deleteVehicle _x} forEach units _grupo;
deleteVehicle _truckX;
deleteGroup _grupo;
_crate enableSimulationGlobal false;
_crate hideObjectGlobal true;
sleep 15;

[0,_tsk] spawn deleteTaskX;