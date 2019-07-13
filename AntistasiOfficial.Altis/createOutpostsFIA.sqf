if (!isServer) exitWith {};

private ["_tipo","_costs","_grupo","_unit","_tam","_roads","_road","_pos","_truckX","_texto","_mrk","_hr","_unitsX","_formatX"];

_tipo = _this select 0;
_positionTel = _this select 1;

if (_tipo == "delete") exitWith {
	_mrk = [outpostsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	hint format ["Deleting %1",markerText _mrk];
	_costs = 0;
	_hr = 0;
	_typeGroup = guer_grp_sniper;
	if (markerText _mrk != "FIA Observation Post") then
		{
		_typeGroup = guer_grp_AT;
		_costs = _costs + ([guer_veh_technical] call vehiclePrice) + (server getVariable guer_sol_RFL);
		_hr = _hr + 1;
		};
	_formatX = ([_typeGroup, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _hr = _hr +1} forEach _typeGroup;
	[_hr,_costs] remoteExec ["resourcesFIA",2];
	deleteMarker _mrk;
	outpostsFIA = outpostsFIA - [_mrk]; publicVariable "outpostsFIA";
	mrkFIA = mrkFIA - [_mrk]; publicVariable "mrkFIA";
	markers = markers - [_mrk]; publicVariable "markers";
	if (_mrk in FIA_RB_list) then {
		FIA_RB_list = FIA_RB_list - [_mrk]; publicVariable "FIA_RB_list";
	} else {
		FIA_WP_list = FIA_WP_list - [_mrk]; publicVariable "FIA_WP_list";
	};
};

_isRoad = isOnRoad _positionTel;

_texto = "FIA Observation Post";
_typeGroup = guer_grp_sniper;
_typeVehX = guer_veh_quad;

if (_isRoad) then
	{
	_texto = "FIA Roadblock";
	_typeGroup = guer_grp_AT;
	_typeVehX = guer_veh_offroad;
	};

_mrk = createMarker [format ["FIAPost%1", random 1000], _positionTel];
_mrk setMarkerShape "ICON";

_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + 60];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "CREATED", 5, true, true, "Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";
_grupo = [getMarkerPos guer_respawn, side_blue, ([_typeGroup, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
_grupo setGroupId ["Watch"];

_tam = 10;
while {true} do
	{
	_roads = getMarkerPos guer_respawn nearRoads _tam;
	if (count _roads < 1) then {_tam = _tam + 10};
	if (count _roads > 0) exitWith {};
	};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];
_truckX = _typeVehX createVehicle _pos;
[_grupo] spawn dismountFIA;
_grupo addVehicle _truckX;
{[_x] call AS_fnc_initialiseFIAUnit} forEach units _grupo;
leader _grupo setBehaviour "SAFE";
Slowhand hcSetGroup [_grupo];
_grupo setVariable ["isHCgroup", true, true];

waitUntil {sleep 1; ({alive _x} count units _grupo == 0) or ({(alive _x) and (_x distance _positionTel < 10)} count units _grupo > 0) or (dateToNumber date > _dateLimitNum)};

if ({(alive _x) and (_x distance _positionTel < 10)} count units _grupo > 0) then
	{
	if (isPlayer leader _grupo) then
		{
		_owner = (leader _grupo) getVariable ["owner",leader _grupo];
		(leader _grupo) remoteExec ["removeAllActions",leader _grupo];
		_owner remoteExec ["selectPlayer",leader _grupo];
		(leader _grupo) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _grupo)};
		};
	outpostsFIA = outpostsFIA + [_mrk]; publicVariable "outpostsFIA";
	mrkFIA = mrkFIA + [_mrk]; publicVariable "mrkFIA";
	markers = markers + [_mrk]; publicVariable "markers";
	if (_isRoad) then {
		FIA_RB_list pushBackUnique _mrk;
		publicVariable "FIA_RB_list";
	} else {
		FIA_WP_list pushBackUnique _mrk;
		publicVariable "FIA_WP_list";
		// BE module
		_advanced = false;
		if (activeBE) then {
			if (BE_current_FIA_RB_Style == 1) then {_advanced = true};
		};
		if (_advanced) then {
			_posDes = [_positionTel, 5, round (random 359)] call BIS_Fnc_relPos;
			_remDes = ([_posDes, 0,guer_rem_des, side_blue] call bis_fnc_spawnvehicle) select 0;
			_normalPos = surfaceNormal (position _remDes);
			_remDes setVectorUp _normalPos;
		};
		// BE module
	};
	spawner setVariable [_mrk,false,true];
	_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "SUCCEEDED", 5, true, true, "Move"] call BIS_fnc_setTask;
	[-5,5,_positionTel] remoteExec ["AS_fnc_changeCitySupport",2];
	_mrk setMarkerType "loc_bunker";
	_mrk setMarkerColor "ColorYellow";
	_mrk setMarkerText _texto;
	}
else
	{
	_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "FAILED", 5, true, true, "Move"] call BIS_fnc_setTask;
	sleep 3;
	deleteMarker _mrk;
	};

Slowhand hcRemoveGroup _grupo;
{deleteVehicle _x} forEach units _grupo;
deleteVehicle _truckX;
deleteGroup _grupo;
sleep 15;

[0,_tsk] spawn deleteTaskX;