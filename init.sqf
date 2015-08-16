enableSaving [false, false];
waitUntil {!isNull player};


// Inicia o IniDBI
if (isServer) then {
  call compile preProcessFile "\inidbi\init.sqf";
  sleep 1;
};

operator = player;
if (isServer) then {	operator call aegis_fnc_clientInit; };
publicVariableServer "operator";
