// Shift+ctrl+Y when mortar and NATO arty are selected.
if (count hcSelected player != 1) exitWith {hint "You must select an artillery group"};

private ["_grupo","_artyArray","_artyRoundsArr","_hasBox","_areReady","_hasArty","_areAlive","_soldado","_veh","_typeAmmunition","_typeArty","_positionTel","_artyArrayDef1","_artyRoundsArr1","_pieza","_isInRange","_positionTel2","_rounds","_roundsMax","_markerX","_size","_forcedX","_texto","_mrkfin","_mrkfin2","_tiempo","_eta","_cuenta","_pos","_ang"];

_grupo = hcSelected player select 0;

_artyArray = [];
_artyRoundsArr = [];

_hasBox = 0;
_areReady = false;
_hasArty = false;
_areAlive = false;
{
_soldado = _x;
_veh = vehicle _soldado;
if ((_veh != _soldado) and (not(_veh in _artyArray))) then
	{
	if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
		{
		_hasArty = true;
		if ((canFire _veh) and (alive _veh)) then
			{
			_areAlive = true;
			if (typeOf _veh in bluMLRS) then
				{
					if (replaceFIA) then {
						"RHS_mag_40Rnd_122mm_rockets";
					} else {
						_typeAmmunition = "12Rnd_230mm_rockets";
					};
				}
			else
				{
				if (typeOf _veh in bluArty) then
					{
					createDialog "mbt_type";
					waitUntil {!dialog or !(isNil "typeAmmunition")};
					if !(isNil "typeAmmunition") then
						{
						_typeAmmunition = typeAmmunition;
						typeAmmunition = nil;
						};
					}
				else
					{
					if ((typeOf _veh in bluStatMortar) || (typeOf _veh in statics_allMortars)) then
						{
						createDialog "mortar_type";
						waitUntil {!dialog or !(isNil "typeAmmunition")};
						if !(isNil "typeAmmunition") then
							{
							_typeAmmunition = typeAmmunition;
							typeAmmunition = nil;
							};
						};
					};
				};
			if (! isNil "_typeAmmunition") then
				{
				{
				if (_x select 0 == _typeAmmunition) then
					{
					_hasBox = _hasBox + 1;
					};
				} forEach magazinesAmmo _veh;
				};
			if (_hasBox > 0) then
				{
				if (unitReady _veh) then
					{
					_areReady = true;
					_artyArray pushBack _veh;
					_artyRoundsArr pushBack (((magazinesAmmo _veh) select 0)select 1);
					};
				};
			};
		};
	};
} forEach units _grupo;

if (isNil "_typeAmmunition") exitWith {};
if (!_hasArty) exitWith {hint "You must select an artillery group or it is a Mobile Mortar and it's moving"};
if (!_areAlive) exitWith {hint "All elements in this Batery cannot fire or are disabled"};
if ((_hasBox < 2) and (!_areReady)) exitWith {hint "The Battery has no ammo to fire. Reload it on HQ"};
if (!_areReady) exitWith {hint "Selected Battery is busy right now"};

hcShowBar false;
hcShowBar true;

if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
	{
	closedialog 0;
	createDialog "strike_type";
	}
else
	{
	typeArty = "NORMAL";
	};

waitUntil {!dialog or (!isNil "typeArty")};

if (isNil "typeArty") exitWith {};

_typeArty = typeArty;
typeArty = nil;


positionTel = [];

hint "Select the position on map where to perform the Artillery strike";

openMap true;
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_artyArrayDef1 = [];
_artyRoundsArr1 = [];

for "_i" from 0 to (count _artyArray) - 1 do
	{
	_pieza = _artyArray select _i;
	_isInRange = _positionTel inRangeOfArtillery [[_pieza], ((getArtilleryAmmo [_pieza]) select 0)];
	if (_isInRange) then
		{
		_artyArrayDef1 pushBack _pieza;
		_artyRoundsArr1 pushBack (_artyRoundsArr select _i);
		};
	};

if (_artyArrayDef1 isEqualTo []) exitWith {hint "The position you marked is out of bounds for that Battery"};

_mrkfin = createMarker [format ["Arty%1", random 100], _positionTel];
_mrkfin setMarkerShape "ICON";
_mrkfin setMarkerType "hd_destroy";
_mrkfin setMarkerColor "ColorRed";

if (_typeArty == "BARRAGE") then
	{
	_mrkfin setMarkerText "Arty Barrage Begin";
	positionTel = [];

	hint "Select the position to finish the barrage";

	openMap true;
	onMapSingleClick "positionTel = _pos;";

	waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
	onMapSingleClick "";

	_positionTel2 = positionTel;
	};

if ((_typeArty == "BARRAGE") and (isNil "_positionTel2")) exitWith {deleteMarker _mrkfin};

if (_typeArty != "BARRAGE") then
	{
	if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
		{
		closedialog 0;
		createDialog "rounds_number";
		}
	else
		{
		rondas = 1;
		};
	waitUntil {!dialog or (!isNil "rondas")};
	};

if ((isNil "rondas") and (_typeArty != "BARRAGE")) exitWith {deleteMarker _mrkfin};

if (_typeArty != "BARRAGE") then
	{
	_mrkfin setMarkerText "Arty Strike";
	_rounds = rondas;
	_roundsMax = _rounds;
	rondas = nil;
	}
else
	{
	_rounds = round (_positionTel distance _positionTel2) / 10;
	_roundsMax = _rounds;
	};

_markerX = [markers,_positionTel] call BIS_fnc_nearestPosition;
_size = [_markerX] call sizeMarker;
_forcedX = false;

if ((not(_markerX in forcedSpawn)) and (_positionTel distance (getMarkerPos _markerX) < _size) and (not(spawner getVariable _markerX))) then
	{
	_forcedX = true;
	forcedSpawn pushBack _markerX;
	publicVariable "forcedSpawn";
	};

_texto = format ["Requesting fire support on Grid %1. %2 Rounds", mapGridPosition _positionTel, round _rounds];
[[Slowhand,"sideChat",_texto],"commsMP"] call BIS_fnc_MP;

if (_typeArty == "BARRAGE") then
	{
	_mrkfin2 = createMarker [format ["Arty%1", random 100], _positionTel2];
	_mrkfin2 setMarkerShape "ICON";
	_mrkfin2 setMarkerType "hd_destroy";
	_mrkfin2 setMarkerColor "ColorRed";
	_mrkfin2 setMarkerText "Arty Barrage End";
	_ang = [_positionTel,_positionTel2] call BIS_fnc_dirTo;
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_tiempo = time + _eta;
	_texto = format ["Acknowledged. Fire mission is inbound. ETA %1 secs for the first impact",round _eta];
	[[petros,"sideChat",_texto],"commsMP"] call BIS_fnc_MP;
	[_tiempo] spawn
		{
		private ["_tiempo"];
		_tiempo = _this select 0;
		waitUntil {sleep 1; time > _tiempo};
		[[petros,"sideChat","Splash. Out"],"commsMP"] call BIS_fnc_MP;
		};
	};

_pos = [_positionTel,random 10,random 360] call BIS_fnc_relPos;

for "_i" from 0 to (count _artyArrayDef1) - 1 do {
	if (_rounds > 0) then {
		_pieza = _artyArrayDef1 select _i;
		_cuenta = _artyRoundsArr1 select _i;
		//hint format ["Rondas que faltan: %1, rondas que tiene %2",_rounds,_cuenta];
		if (_cuenta >= _rounds) then {
			if (_typeArty != "BARRAGE") then {
				if ((typeOf _veh in bluStatMortar) || (typeOf _veh in statics_allMortars) || (typeOf _veh in bluArty)) then {
					if (replaceFIA && (typeOf _veh in bluArty)) then {
						sleep 23;
						for "_r" from 1 to _rounds do {
							_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
							sleep 7;
						};
					} else {
						for "_r" from 1 to _rounds do {
							_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
							sleep 2;
						};
					};
				} else {
					_pieza commandArtilleryFire [_pos,_typeAmmunition,_rounds];
				};
			} else {
				for "_r" from 1 to _rounds do {
					_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
		} else {
			if (_typeArty != "BARRAGE") then {
				if ((typeOf _veh in bluStatMortar) || (typeOf _veh in statics_allMortars) || (typeOf _veh in bluArty)) then {
					for "_r" from 1 to _cuenta do {
						_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
						sleep 2;
					};
				} else {
					_pieza commandArtilleryFire [_pos,_typeAmmunition,_cuenta];
				};
			} else {
				for "_r" from 1 to _cuenta do {
					_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
				};
			};
		_rounds = _rounds - _cuenta;
		};
	};
};

if (_typeArty != "BARRAGE") then
	{
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_tiempo = time + _eta - 5;
	_texto = format ["Acknowledged. Fire mission is inbound. %2 Rounds fired. ETA %1 secs",round _eta,_roundsMax - _rounds];
	[[petros,"sideChat",_texto],"commsMP"] call BIS_fnc_MP;
	};

if (_typeArty != "BARRAGE") then
	{
	waitUntil {sleep 1; time > _tiempo};
	[[petros,"sideChat","Splash. Out"],"commsMP"] call BIS_fnc_MP;
	};
sleep 10;
deleteMarker _mrkfin;
if (_typeArty == "BARRAGE") then {deleteMarker _mrkfin2};

if (_forcedX) then
	{
	sleep 20;
	if (_markerX in forcedSpawn) then
		{
		forcedSpawn = forcedSpawn - [_markerX];
		publicVariable "forcedSpawn";
		};
	};
