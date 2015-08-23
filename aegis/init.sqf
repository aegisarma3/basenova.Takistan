// Inicia o IniDBI + PDW
if (isServer) then {
  //######### SERVER EH's ###########################################################################
  ["aegis_id", "onPlayerConnected", {[_name, _uid] spawn aegis_fnc_clientInit;}] call BIS_fnc_addStackedEventHandler;
  "currentBalance" addPublicVariableEventHandler {currentBalance call aegis_fnc_transactionManager;};
  addMissionEventHandler ["HandleDisconnect",{_this call aegis_fnc_disconnectmanager}];
  //##################################################################################################
  call aegis_fnc_serverInit;
  call aegis_fnc_checkCivEH;
};

if (!isServer) then
{
	[] spawn
	{
		if (hasInterface) then // Normal player
		{

      waitUntil {!IsNull player && alive player};
      //######### CLIENT EH's ###################################################################
      player addEventHandler ["Respawn",{call aegis_fnc_respawnManager;}];
      //#########################################################################################

      call aegis_fnc_localFunctions;

    };
  };
};
