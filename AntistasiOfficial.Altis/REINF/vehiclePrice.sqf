private ["_tipo","_costs"];

_tipo = _this select 0;

if (isNil {_tipo}) exitWith {};

_costs = server getVariable [_tipo,0];

if (_costs == 0) then {
	call {
		if ((_tipo in vehTrucks) or (_tipo in vehPatrol) or (_tipo in vehSupply)) exitWith {_costs = 300};
		if (_tipo in vehAPC) exitWith {_costs = 1000};
		if (_tipo in vehIFV) exitWith {_costs = 2000};
		if (_tipo in vehTank) exitWith {_costs = 5000};
		if (_tipo == "C_Van_01_fuel_F") exitWith {_costs = 50};
		if (_tipo in CIV_vehicles) exitWith {_costs = 25};
		if (_tipo in guer_vehicleArray) exitWith {_costs = 200};

		_costs = 0;
		diag_log format ["Antistasi: Error en vehicle prize con este: %1",_tipo];
		};
	}
else
	{
	//_costs = _costs + (_costs * ({_x in mrkAAF} count seaports));
	_costs = round (_costs - (_costs * (0.1 * ({_x in mrkFIA} count seaports))));
	};

_costs