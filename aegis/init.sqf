// Inicia o IniDBI + PDW
if (isServer) then {
  call aegis_fnc_serverInit;

  //######### EH's ##############################################################
  "operator" addPublicVariableEventHandler {operator call aegis_fnc_clientInit;};
  "currentBalance" addPublicVariableEventHandler {currentBalance call aegis_fnc_transactionManager;};
  //##############################################################################
};


waitUntil {!isNull player};

"rHINT" addPublicVariableEventHandler {(_this select 1) call aegis_fnc_remoteHint;};

sleep 1;
operator = player;
publicVariableServer "operator";
sleep 1;
call aegis_fnc_localFunctions;
