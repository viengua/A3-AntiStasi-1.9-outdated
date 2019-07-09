if (!isServer) exitWith{};

private ["_markerX","_pos","_equis","_cuenta","_y"];

_markerX = _this select 0;
_pos = getMarkerPos _markerX;
_equis = _pos select 0;
_y = _pos select 1;
_cuenta = 0;


_shell1 = "Sh_82mm_AMOS" createVehicle [_equis,_y,200];
_shell1 setVelocity [0,0,-50];


