// Inicia o IniDBI + PDW
if (isServer) then {
  call aegis_fnc_serverInit;

  //######### SERVER EH's ###########################################################################
  "operator" addPublicVariableEventHandler {operator call aegis_fnc_clientInit;};
  "currentBalance" addPublicVariableEventHandler {currentBalance call aegis_fnc_transactionManager;};
  addMissionEventHandler ["HandleDisconnect",{_this call aegis_fnc_disconnectmanager}];
  //##################################################################################################
};



if (!isDedicated) then
{
	[] spawn
	{
		if (hasInterface) then // Normal player
		{
			waitUntil {!isNull player};

      //######### CLIENT EH's ###################################################################
      "rHINT" addPublicVariableEventHandler {(_this select 1) call aegis_fnc_remoteHint;};
      player addEventHandler ["Respawn",{call aegis_fnc_respawnManager;}];
      //#########################################################################################

      sleep 1;
      operator = player;
      publicVariableServer "operator";
      sleep 1;
      call aegis_fnc_localFunctions;


    };
  };
};
