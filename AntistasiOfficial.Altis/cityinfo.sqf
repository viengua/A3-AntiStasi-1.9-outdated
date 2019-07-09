
private ["_texto","_datos","_numCiv","_prestigeOPFOR","_prestigeBLUFOR","_supplyLevels","_power","_busy","_sitio","_positionTel","_garrison"];
positionTel = [];

_popFIA = 0;
_popAAF = 0;
_pop = 0;
{
_datos = server getVariable _x;
_numCiv = _datos select 0;
_prestigeOPFOR = _datos select 2;
_prestigeBLUFOR = _datos select 3;
_supplyLevels = _datos select 4;
_popFIA = _popFIA + (_numCiv * (_prestigeBLUFOR / 100));
_popAAF = _popAAF + (_numCiv * (_prestigeOPFOR / 100));
_pop = _pop + _numCiv;
} forEach citiesX;
_popFIA = round _popFIA;
_popAAF = round _popAAF;
hint format [localize "STR_HINTS_MAP_TEXT_1",_pop, _popFIA, _popAAF, {_x in destroyedCities} count citiesX,count allunits,worldname];

openMap true;

onMapSingleClick "positionTel = _pos;";


//Plot the frontline. Sparker
[ws_frontlineSmooth, 1, false] call WS_fnc_plotGrid;
////////////////////////////////

//waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
while {visibleMap} do {
	sleep 1;
	if (count positionTel > 0) then {
		_positionTel = positionTel;
		//_sitio = [markersX, _positionTel] call BIS_Fnc_nearestPosition;
		_sitio = [markers, _positionTel] call BIS_Fnc_nearestPosition; //Sparker
		_texto = "Click on a zone";
		if (_sitio == "FIA_HQ") then {
			_texto = format ["FIA HQ%1",[_sitio] call AS_fnc_getGarrisonInfo];
		};
		if (_sitio in citiesX) then {
			_datos = server getVariable _sitio;

			_numCiv = _datos select 0;
			_prestigeOPFOR = _datos select 2;
			_prestigeBLUFOR = _datos select 3;
			_supplyLevels = _datos select 4;
			_power = [_sitio] call AS_fnc_powercheck;
			//_texto = format ["%1\n\nPop %2\nAAF Support: %3 %5\nFIA Support: %4 %5",[_sitio,false] call fn_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%"];
			_texto = format ["%1\n\nPop %2\nAAF Support: %3 %5\nFIA Support: %4 %5\nFood Supply: %6\nWater Supply: %7\nFuel Supply: %8",[_sitio,false] call AS_fnc_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%",_supplyLevels select 0, _supplyLevels select 1, _supplyLevels select 2];
			if (_power) then {_texto = format ["%1\nPowered",_texto]} else {_texto = format ["%1\nNot Powered",_texto]};
			//if (_sitio in mrkAAF) then {if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\nRadio Comms ON",_texto]} else {_texto = format ["%1\nRadio Comms OFF",_texto]}};
		if (_sitio in destroyedCities) then {_texto = format ["%1\nDESTROYED",_texto]};
		};
		/*
		if ((_sitio in colinas) and (_sitio in mrkAAF)) then
			{
			_texto = "AAF Small Outpost";
			};
		*/
		if (_sitio in airportsX) then	{
			if (_sitio in mrkAAF) then {
				_texto = "AAF Airport";
				_busy = if (dateToNumber date > server getVariable _sitio) then {false} else {true};
				//if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\n\nRadio Comms ON",_texto]} else {_texto = format ["%1\n\nRadio Comms OFF",_texto]};
				if (!_busy) then {_texto = format ["%1\nStatus: Idle",_texto]} else {_texto = format ["%1\nStatus: Busy",_texto]};
			} else {
				_texto = format ["FIA Airport%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
		};

		if (_sitio in power) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Powerplant";
				//if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\n\nRadio Comms ON",_texto]} else {_texto = format ["%1\n\nRadio Comms OFF",_texto]};
			} else {
				_texto = format ["FIA Powerplant%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
			if (_sitio in destroyedCities) then {_texto = format ["%1\nDESTROYED",_texto]};
		};

		if (_sitio in resourcesX) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Resources";
			} else {
				_texto = format ["FIA Resources%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
			_power = [_sitio] call AS_fnc_powercheck;
			if (!_power) then {_texto = format ["%1\n\nNo Powered",_texto]} else {_texto = format ["%1\n\nPowered",_texto]};
			//if (_sitio in mrkAAF) then {if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\nRadio Comms ON",_texto]} else {_texto = format ["%1\nRadio Comms OFF",_texto]}};
			if (_sitio in destroyedCities) then {_texto = format ["%1\nDESTROYED",_texto]};
			};
		if (_sitio in factories) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Factory";
			} else {
				_texto = format ["FIA Factory%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};

			_power = [_sitio] call AS_fnc_powercheck;
			if (!_power) then {_texto = format ["%1\n\nNo Powered",_texto]} else {_texto = format ["%1\n\nPowered",_texto]};
			//if (_sitio in mrkAAF) then {if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\nRadio Comms ON",_texto]} else {_texto = format ["%1\nRadio Comms OFF",_texto]}};
			if (_sitio in destroyedCities) then {_texto = format ["%1\nDESTROYED",_texto]};
		};
		if (_sitio in puestos) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Grand Outpost";
				//if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\n\nRadio Comms ON",_texto]} else {_texto = format ["%1\n\nRadio Comms OFF",_texto]};
			}
			else {
				_texto = format ["FIA Grand Outpost%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
		};
		/*
		if ((_sitio in controlsX) and (_sitio in mrkAAF)) then
			{
			_texto = "AAF Roadblock";
			};
		*/
		if (_sitio in puertos) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Seaport";
				//if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\n\nRadio Comms ON",_texto]} else {_texto = format ["%1\n\nRadio Comms OFF",_texto]};
			} else {
				_texto = format ["FIA Seaport%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
		};
		if (_sitio in bases) then {
			if (_sitio in mrkAAF) then {
				_texto = "AAF Base";
				_busy = if (dateToNumber date > server getVariable _sitio) then {false} else {true};
				if ([_sitio] call AS_fnc_radiocheck) then {_texto = format ["%1\n\nRadio Comms ON",_texto]} else {_texto = format ["%1\n\nRadio Comms OFF",_texto]};
				if (!_busy) then {_texto = format ["%1\nStatus: Idle",_texto]} else {_texto = format ["%1\nStatus: Busy",_texto]};
			} else {
				_texto = format ["FIA Base%1",[_sitio] call AS_fnc_getGarrisonInfo];
			};
		};
		hint format ["%1",_texto];
	};
	positionTel = [];
};
onMapSingleClick "";

//Remove the frontline. Sparker
call WS_fnc_unplotGrid;
///////////////////////////////
