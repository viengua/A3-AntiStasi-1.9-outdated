if (!isServer) exitWith {};

if (leader group Petros != Petros) exitWith {};

_typesX = ["CON","LOG","RES","CONVOY","PR","ASS"];
_tipo = "";

if (!isPlayer Slowhand) then {_typesX = _typesX - ["ASS"]};

{
if (_x in missionsX) then {_typesX = _typesX - [_x]};
} forEach _typesX;
if (count _typesX == 0) exitWith {};

while {true} do {
	_tipo = _typesX call BIS_fnc_selectRandom;
	_typesX = _typesX - [_tipo];
	if (!(_tipo in missionsX) || (count _typesX == 0)) exitWith {};
};
if (count _typesX == 0) exitWith {};

[_tipo,true,false] call missionRequest;