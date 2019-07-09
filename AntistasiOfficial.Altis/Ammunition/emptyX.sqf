private ["_trucksX","_camion","_armas","_ammunition","_items","_mochis","_containers","_todo"];

_camion = objNull;

if (count _this > 0) then
	{
	_camion = _this select 0;
	if (_camion isKindOf "StaticWeapon") then {_camion = objNull};
	}
else
	{
	//_trucksX = nearestObjects [caja, ["LandVehicle"], 20];
	_trucksX = nearestObjects [caja, ["LandVehicle", "ReammoBox_F", "Box_IED_Exp_F", "Land_PlasticCase_01_medium_F", "Box_Syndicate_Wps_F"], 20]; //To enable jeroen's loading script. Sparker.
	_trucksX = _trucksX select {not (_x isKindOf "StaticWeapon")};
	_trucksX = _trucksX - [caja];
	_trucksX = _trucksX - [cajaVeh]; //To enable jeroen's unloading script. Sparker.
	if (count _trucksX < 1) then {_camion = cajaVeh} else {_camion = _trucksX select 0};
	};

if (isNull _camion) exitWith {};


if (server getVariable ["lockTransfer",false]) exitWith {
	if (isMultiplayer) then {
		{if (_x distance caja < 20) then {
			[petros,"hint","Currently unloading another ammobox. Please wait a few seconds."] remoteExec ["commsMP",_x];
		};
		} forEach playableUnits;
	}
	else {
		hint "Unloading ammobox..."
	};
};


_armas = weaponCargo _camion;
_ammunition = magazineCargo _camion;
_items = itemCargo _camion;
_mochis = backpackCargo _camion;

_todo = _armas + _ammunition + _items + _mochis;

if (count _todo < 1) exitWith
	{
	if (count _this == 0) then {hint "Closest vehicle cargo is empty"};
	if (count _this == 2) then {
		if (count (nearestObjects [getPos fuego, ["AllVehicles"], 50]) > 0) then {
			{[[_x,player], SA_Put_Away_Tow_Ropes] remoteExec ["call", 0];} forEach nearestObjects [getPos fuego, ["AllVehicles"], 50];
		};
		deleteVehicle _camion};
	};

server setVariable ["lockTransfer", true, true];
if (isMultiplayer) then {{if (_x distance caja < 20) then {[petros,"hint","Unloading ammobox..."] remoteExec ["commsMP",_x]}} forEach playableUnits} else {hint "Unloading ammobox..."};
if (count _this == 2) then {[_camion,caja,true] remoteExec ["AS_fnc_transferGear",2]} else {[_camion,caja] remoteExec ["AS_fnc_transferGear",2]};
[] spawn {
	sleep 5;
	server setVariable ["lockTransfer", false, true];
};
