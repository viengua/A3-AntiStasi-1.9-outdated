private ["_staticX","_nearX","_playerX"];

_staticX = _this select 0;
_playerX = _this select 1;

if (!alive _staticX) exitWith {hint "You cannot steal a destroyed static weapon"};

if (alive gunner _staticX) exitWith {hint "You cannot steal a static weapon when someone is using it"};

if ((alive assignedGunner _staticX) and (!isPlayer (assignedGunner _staticX))) exitWith {hint "The gunner of this static weapon is still alive"};

_nearX = [markers,_staticX] call BIS_fnc_nearestPosition;

if (_nearX in mrkAAF) exitWith {hint "You have to conquer this zone in order to be able to steal this Static Weapon"};

_staticX setOwner (owner _playerX);

_tipoEst = typeOf _staticX;
_tipoB1 = "";
_tipoB2 = "";

switch _tipoEst do {
	case statMG: {
		_tipoB1 = statMGBackpacks select 0;
		_tipoB2 = statMGBackpacks select 1;
	};
	case statAA: {
		_tipoB1 = statAABackpacks select 0;
		_tipoB2 = statAABackpacks select 1;
	};
	case statAT: {
		_tipoB1 = statATBackpacks select 0;
		_tipoB2 = statATBackpacks select 1;
	};
	case statMortar: {
		_tipoB1 = statMortarBackpacks select 0;
		_tipoB2 = statMortarBackpacks select 1;
	};
	case statMGlow: {
		_tipoB1 = statMGlowBackpacks select 0;
		_tipoB2 = statMGlowBackpacks select 1;
	};
	case statMGtower: {
		_tipoB1 = statMGtowerBackpacks select 0;
		_tipoB2 = statMGtowerBackpacks select 1;
	};
	default {hint "You cannot steal this weapon."};
	};

_positionX1 = [_playerX, 1, (getDir _playerX) - 90] call BIS_fnc_relPos;
_positionX2 = [_playerX, 1, (getDir _playerX) + 90] call BIS_fnc_relPos;

deleteVehicle _staticX;

if (_tipoB1 == "") exitWith {};

_bag1 = _tipoB1 createVehicle _positionX1;
_bag2 = _tipoB2 createVehicle _positionX2;

[_bag1] spawn VEHinit;
[_bag2] spawn VEHinit;