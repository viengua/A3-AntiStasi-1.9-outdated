if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_logBank";
_tskDesc = "STR_TSK_TD_DESC_logBank";

_banco = _this select 0;

_positionX = getPos _banco;
_markerX = [citiesX,_positionX] call BIS_fnc_nearestPosition;
_posbase = getMarkerPos guer_respawn;

_timeLimit = 120;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_ciudad = [citiesX, _positionX] call BIS_fnc_nearestPosition;
_mrkfin = createMarker [format ["LOG%1", random 100], _positionX];
_nameDest = [_ciudad] call AS_fnc_localizar;
_mrkfin setMarkerShape "ICON";

_pos = (getMarkerPos guer_respawn) findEmptyPosition [1,50,AS_misVehicleBox];

_camion = AS_misVehicleBox createVehicle _pos;
_camion allowDamage false;
[_camion] spawn {sleep 1; (_this select 0) allowDamage true;};


{_x reveal _camion} forEach (allPlayers - (entities "HeadlessClient_F"));
[_camion] spawn vehInit;
_camion setVariable ["destino",_nameDest,true];
_camion addEventHandler ["GetIn",
	{
	if (_this select 1 == "driver") then
		{
		_texto = format ["Bring this truck to %1 Bank and park it in the main entrance",(_this select 0) getVariable "destino"];
		_texto remoteExecCall ["hint",_this select 2];
		};
	}];

[_camion,"Mission Vehicle"] spawn inmuneConvoy;

_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkfin],_positionX,"CREATED",5,true,true,"Interact"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [30,30];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerAlphaLocal 0;

_typeGroup = [infSquad, side_green] call AS_fnc_pickGroup;
_grupo = [_positionX, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
sleep 1;
[_grupo, _mrk, "SAFE","SPAWNED", "NOVEH2", "FORTIFY"] execVM "scripts\UPSMON.sqf";
{[_x] spawn genInitBASES} forEach units _grupo;

_positionX = _banco buildingPos 1;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (!alive _camion) or (_camion distance _positionX < 7)};

if ((dateToNumber date > _dateLimitNum) or (!alive _camion)) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkfin],_positionX,"FAILED",5,true,true,"Interact"] call BIS_fnc_setTask;
	_resourcesAAF = server getVariable "resourcesAAF";
	_resourcesAAF = _resourcesAAF + 5000;
	server setVariable ["resourcesAAF",_resourcesAAF,true];
	[-1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	}
else
	{
	_cuenta = 120;//120
	[_positionX] remoteExec ["patrolCA", call AS_fnc_getNextWorker];
	[10,-20,_markerX] remoteExec ["AS_fnc_changeCitySupport",2];
	{_amigo = _x;
	if (_amigo distance _camion < 300) then
		{
		if ((captive _amigo) and (isPlayer _amigo)) then {[player,false] remoteExec ["setCaptive",_amigo]};
		{if (side _x == side_green) then {_x reveal [_amigo,4]};
		} forEach allUnits;
		};
	} forEach ([distanceSPWN,0,_positionX,"BLUFORSpawn"] call distanceUnits);
	while {(_cuenta > 0) or (_camion distance _positionX < 7) and (alive _camion) and (dateToNumber date < _dateLimitNum)} do
		{
		while {(_cuenta > 0) and (_camion distance _positionX < 7) and (alive _camion)} do
			{
			_formato = format ["%1", _cuenta];
			{if (isPlayer _x) then {[petros,"countdown",_formato] remoteExec ["commsMP",_x]}} forEach ([80,0,_camion,"BLUFORSpawn"] call distanceUnits);
			sleep 1;
			_cuenta = _cuenta - 1;
			};
		if (_cuenta > 0) then
			{
			_cuenta = 120;//120
			if (_camion distance _positionX > 6) then {[[petros,"hint","Don't get the truck far from the bank or count will restart"],"commsMP"] call BIS_fnc_MP};
			waitUntil {sleep 1; (!alive _camion) or (_camion distance _positionX < 7) or (dateToNumber date < _dateLimitNum)};
			}
		else
			{
			if (alive _camion) then
				{
				{if (isPlayer _x) then {[petros,"hint","Drive the Truck back to base to finish this mission"] remoteExec ["commsMP",_x]}} forEach ([80,0,_camion,"BLUFORSpawn"] call distanceUnits);
				};
			};
		};
	};


waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (!alive _camion) or (_camion distance _posbase < 50)};
if ((_camion distance _posbase < 50) and (dateToNumber date < _dateLimitNum)) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkfin],_positionX,"SUCCEEDED",5,true,true,"Interact"] call BIS_fnc_setTask;
	[0,5000] remoteExec ["resourcesFIA",2];
	[-20,0] remoteExec ["prestige",2];
	[1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (_x distance _camion < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};
if (!alive _camion) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkfin],_positionX,"FAILED",5,true,true,"Interact"] call BIS_fnc_setTask;
	[1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	};

waitUntil {sleep 1; speed _camion == 0};

[_camion] call emptyX;
deleteVehicle _camion;

[1200,_tsk] spawn deleteTaskX;

waitUntil {sleep 1; !([distanceSPWN,1,_positionX,"BLUFORSpawn"] call distanceUnits)};

{deleteVehicle _x} forEach units _grupo;
deleteGroup _grupo;

deleteMarker _mrk;
deleteMarker _mrkfin;
