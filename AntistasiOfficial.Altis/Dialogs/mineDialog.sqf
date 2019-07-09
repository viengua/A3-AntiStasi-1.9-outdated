private ["_tipo","_coste","_positionTel","_quantity","_quantityMax"];

if ("Mines" in missionsX) exitWith {hint "We can only deploy one minefield at a time."};

if (!([player] call hasRadio)) exitWith {hint "You need a radio in your inventory to be able to give orders to other squads"};

_tipo = _this select 0;

_coste = (2*(server getVariable guer_sol_EXP)) + ([guer_veh_truck] call vehiclePrice);
_hr = 2;
if (_tipo == "delete") then
	{
	_coste = _coste - (server getVariable guer_sol_EXP);
	_hr = 1;
	};
if ((server getVariable "resourcesFIA" < _coste) or (server getVariable "hr" < _hr)) exitWith {hint format ["Not enought resources to recruit a mine deploying team (%1 € and %2 HR needed)",_coste,_hr]};

if (_tipo == "delete") exitWith
	{
	hint "Sapper/engineer is available on your High Command bar.\n\nSend him anywhere on the map and he will deactivate and load in his truck any mine he may find.\n\nReturning back to HQ will unload the mines he stored in his vehicle";
	[[], "AI\mineSweep.sqf"] remoteExec ["execVM",  call AS_fnc_getNextWorker];
	};

openMap true;
positionTel = [];
hint "Click on the position you wish to build the minefield.";

onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_quantityMax = 40;
_quantity = 0;

if (_tipo == "ATMine") then {
	_quantityMax = 20;
	if (atMine in unlockedMagazines) then {
		_quantity = 20;
	} else {
		_quantity = {_x == atMine} count (magazineCargo caja);
	};
	diag_log format ["AT mines: %1", _quantity];
};


if (_tipo == "APERSMine") then {
	if (apMine in unlockedMagazines) then {
		_quantity = 40;
	} else {
		_quantity = {_x == apMine} count (magazineCargo caja);
	};
	diag_log format ["AP mines: %1", _quantity];
};

if (_quantity < 5) exitWith {hint "You need at least 5 mines of this type to build a Minefield"};

if (_quantity > _quantityMax) then
	{
	_quantity = _quantityMax;
	};

[[_tipo,_positionTel,_quantity], "REINF\buildMinefield.sqf"] remoteExec ["execVM", call AS_fnc_getNextWorker];