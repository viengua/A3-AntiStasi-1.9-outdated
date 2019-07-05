private ["_marcador","_threat","_isMarker","_posicion","_esFIA","_analyzed","_size"];

_threat = 0;


{if (_x in unlockedWeapons) then {_threat = 5};} forEach genAALaunchers;


_marcador = _this select 0;
_isMarker = true;
if (_marcador isEqualType []) then {_isMarker = false; _posicion = _marcador} else {_posicion = getMarkerPos _marcador};

_esFIA = false;
if (_isMarker) then {
	if (_marcador in mrkAAF) then {
		{
			if (getMarkerPos _x distance _posicion < (distanceSPWN*1.5)) then {
				if ((_x in bases) or (_x in airportsX)) then {_threat = _threat + 3} else {_threat = _threat + 1};
			};
		} forEach (controlsX + puestos + colinas + bases + airportsX - mrkFIA);
	} else {_esFIA = true;};
} else { _esFIA = true;};

if (_esFIA) then {
	{
		if (getMarkerPos _x distance _posicion < distanceSPWN) then {
			_analyzed = _x;
			_garrison = garrison getVariable [_analyzed,[]];
			_threat = _threat + (floor((count _garrison)/4));
			_size = [_analyzed] call sizeMarker;
			_estaticas = staticsToSave select {_x distance (getMarkerPos _analyzed) < _size};
			if (count _estaticas > 0) then {
				_threat = _threat + ({typeOf _x in statics_allMGs} count _estaticas) + (5*({typeOf _x in statics_allAAs} count _estaticas));
			};
		};
	} forEach (mrkFIA - ciudades - controlsX - colinas - outpostsFIA);
};

_threat