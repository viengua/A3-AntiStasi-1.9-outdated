params ["_position"];

{
	if ((side _x == side_blue) and (_x distance _position < 20)) then {
		if (activeACEMedical) then {
			_x setVariable ["ACE_isUnconscious",false,true];
      		[_x, _x] call ace_medical_treatment_fnc_fullHeal;
    	} else {
      		_x setDamage 0;
		};
	};
} forEach allUnits;

hint "All units patched up and good to go.";