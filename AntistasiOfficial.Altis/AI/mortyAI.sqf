private ["_morty","_camion","_mortarX","_pos"];

_morty = _this select 0;
_camion = _this select 1;
_mortarX = _this select 2;

_camionero = driver _camion;
_grupo = group _morty;

while {(alive _morty) and (alive _mortarX) and (canMove _camion)} do
	{
	waitUntil {sleep 1; (!unitReady _camionero) or (not((alive _morty) and (alive _mortarX)))};

	moveOut _morty;
	_morty assignAsCargo _camion;
	_mortarX attachTo [_camion,[0,-1.5,0.2]];
	_mortarX setDir (getDir _camion + 180);

	_camionero disableAI "MOVE";
	waitUntil {sleep 1; ((_camion getCargoIndex _morty) != -1) or (not((alive _morty) and (alive _mortarX)))};
	_camionero enableAI "MOVE";


	//waitUntil {sleep 1; ((unitReady _camionero) or (!canMove _camion) or (!alive _camionero) and (speed _camion == 0)) or (not((alive _morty) and (alive _mortarX)))};

	waitUntil {sleep 1; (speed _camion == 0) or (!canMove _camion) or (!alive _camionero) or (not((alive _morty) and (alive _mortarX)))};

	moveOut _morty;
	detach _mortarX;
	_pos = position _camion findEmptyPosition [1,30,"B_MBT_01_TUSK_F"];
	_mortarX setPos _pos;
	_morty assignAsGunner _mortarX;
};