// Inicia o IniDBI + PDW
if (isServer) then {
  call aegis_fnc_serverInit;

  //######### EH's ##############################################################

  "operator" addPublicVariableEventHandler {operator call aegis_fnc_clientInit;};

  //##############################################################################
};


waitUntil {!isNull player};
"rHINT" addPublicVariableEventHandler {(_this select 1) call aegis_fnc_remoteHint;};


sleep 1;
operator = player;
publicVariableServer "operator";
sleep 1;
