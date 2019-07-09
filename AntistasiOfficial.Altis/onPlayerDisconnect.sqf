private ["_player","_resourcesX","_hr","_armas","_ammunition","_items","_pos"];

params ["_player","_id","_uid","_name"];

diag_log ["disconnected",_player,_id,_uid,_name];

if(typeof _player isEqualTo "HeadlessClient_F")exitWith{};

_resourcesX = 0;
_hr = 0;

if (_player isEqualTo Slowhand) then{
	{
		_group = _x;
		if (!(_group getVariable ["esNATO",false])) then{//skip nato groups
			if ((leader _group getVariable ["BLUFORspawn",false]) and (!isPlayer leader _group)) then{//skip Slowhand and non guarlila groups
				{//loop units in group
					_unit = _x;
					if (alive _unit) then{
						_resourcesX = _resourcesX + (server getVariable (typeOf _unit));
						_hr = _hr + 1;
					};

					/* "Jeroen Not 3-8-2017"
					Needs a fix, it removes vehicles from other players when he leaves.
					if (!isNull (assignedVehicle _unit)) then{
						_veh = assignedVehicle _unit;
						_tipoVeh = typeOf _veh;
						if ((_veh isKindOf "StaticWeapon") and (not(_veh in staticsToSave))) then{
							_resourcesX = _resourcesX + ([_tipoVeh] call vehiclePrice) + ([typeOf (vehicle leader _unit)] call vehiclePrice);
						}else{
							if (_tipoVeh in guer_vehicleArray) then {_resourcesX = _resourcesX + ([_tipoVeh] call vehiclePrice);};
							if (_tipoVeh in (vehTrucks + vehPatrol + vehSupply)) then {_resourcesX = _resourcesX + 300};
							if (_tipoVeh in enemyMotorpool) then {
								call {
									if (_tipoVeh in vehAPC) exitWith {_resourcesX = _resourcesX + 1000};
									if (_tipoVeh in vehIFV) exitWith {_resourcesX = _resourcesX + 2000};
									if (_tipoVeh in vehTank) exitWith {_resourcesX = _resourcesX + 5000};
								};
							};
							if (count attachedObjects _veh > 0) then
							{
								_subVeh = (attachedObjects _veh) select 0;
								_resourcesX = _resourcesX + ([(typeOf _subVeh)] call vehiclePrice);
								deleteVehicle _subVeh;
							};
						};
						if (!(_veh in staticsToSave)) then {deleteVehicle _veh};
					};*/


					deleteVehicle _unit;
				} forEach (units _group);
			};
		};
	} forEach allGroups;

	if ((!(playableUnits isEqualTo []) and (membersPool isEqualTo [])) or ({(getPlayerUID _x) in membersPool} count playableUnits > 0)) then{
		[] spawn assignStavros;
	};

	if (group petros == group _player) then {[] spawn buildHQ};

};//player == slowhand

if ((_hr > 0) or (_resourcesX > 0)) then {[_hr,_resourcesX] remoteExec ["resourcesFIA", 2]};

_pos = getPosATL _player;
_wholder = nearestObjects [_pos, ["weaponHolderSimulated", "weaponHolder"], 2];

//save player stats/loadout
[_player,_uid,true] call AS_fnc_savePlayer;

//remove player
{deleteVehicle _x;} forEach _wholder + [_player];

if (alive _player) then{
	_player setVariable ["owner",_player,true];
	_player setDamage 1;
};



