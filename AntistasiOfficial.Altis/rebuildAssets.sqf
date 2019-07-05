
_resourcesFIA = server getVariable "resourcesFIA";

if (_resourcesFIA < 5000) exitWith {hint localize "STR_HINTS_RA_YDNHEMTRAA"};

_destroyedCities = destroyedCities - ciudades;

openMap true;
positionTel = [];
hint localize "STR_HINTS_RA_COTZYWTR";

onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_sitio = [markers,_positionTel] call BIS_fnc_nearestPosition;

if (getMarkerPos _sitio distance _positionTel > 50) exitWith {hint localize "STR_HINTS_RA_YMCNAMM"};

if (not(_sitio in _destroyedCities)) exitWith {hint localize "STR_HINTS_RA_YCRT"};

_nombre = [_sitio] call AS_fnc_localizar;

hint format [localize "STR_HINTS_RA_1REBUILT"];

[0,10,_positionTel] remoteExec ["AS_fnc_changeCitySupport",2];
[5,0] remoteExec ["prestige",2];
destroyedCities = destroyedCities - [_sitio];
publicVariable "destroyedCities";
if (_sitio in power) then {[_sitio] call AS_fnc_powerReorg};
[0,-5000] remoteExec ["resourcesFIA",2];