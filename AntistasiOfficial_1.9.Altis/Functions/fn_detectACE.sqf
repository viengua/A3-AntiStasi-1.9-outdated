activeACE = !isNil "ace_common_fnc_isModLoaded";
activeACEhearing = false;
activeACEMedical = false;
if (activeACE) then {
	{unlockedItems pushBack _x} foreach ["ACE_EarPlugs","ACE_RangeCard","ACE_Clacker","ACE_M26_Clacker","ACE_DeadManSwitch","ACE_DefusalKit","ACE_MapTools","ACE_Flashlight_MX991","ACE_Sandbag_empty","ACE_wirecutter","ACE_RangeTable_82mm","ACE_EntrenchingTool","ACE_Cellphone","ACE_CableTie","ACE_SpottingScope","ACE_Tripod","ACE_Chemlight_HiWhite","ACE_Chemlight_HiRed"];
	unlockedBackpacks pushBackUnique "ACE_TacticalLadder_Pack";
	//unlockedBackpacks pushBackUnique "ACE_gunbag_Tan"; gunbag will make your rifle disappear when interact with arsenal, too risky to add.
	//unlockedBackpacks pushBackUnique "ACE_gunbag";
	unlockedWeapons pushBackUnique "ACE_VMH3";
	{unlockedMagazines pushback _x} foreach ["ACE_HandFlare_White","ACE_HandFlare_Red"];
	genItems = genItems + ["ACE_Kestrel4500","ACE_ATragMX"];

	if ("ACE_Hearing" call ace_common_fnc_isModLoaded) then {
		activeACEhearing = true;
	};
	if ("ACE_Medical" call ace_common_fnc_isModLoaded) then {
		activeACEMedical = true;
		{unlockedItems pushback _x} foreach ["ACE_bloodIV_500","ACE_bloodIV","ACE_epinephrine","ACE_morphine","ACE_bodyBag","ACE_elasticBandage","ACE_bloodIV_250","ACE_packingBandage","ACE_personalAidKit","ACE_plasmaIV","ACE_plasmaIV_500","ACE_plasmaIV_250","ACE_salineIV","ACE_salineIV_500","ACE_salineIV_250","ACE_surgicalKit","ACE_tourniquet","ACE_adenosine","ACE_atropine","ACE_quikclot"];
		//if (isClass (configfile >> "CfgWeapons" >> "adv_aceCPR_AED")) then 
		//{
		//	if(isClass (configfile >> "CfgWeapons" >> "adv_aceSplint_splint")) then
		//	{
		{unlockedItems pushback _x} foreach ["adv_aceSplint_splint","adv_aceCPR_AED"];
		//	};			
		//} 
		//else 
		//{
		//	diag_log "NO ADV FOUND!";
		//};
	};
};

diag_log "Init: ACE detection done.";