civKia = 0;
publicvariable "civKia";

unitName = "";

// Verifica de 5 em 5 segundos os civis que estao no mapa e adiciona um EH a eles caso precise.
private ["_allCivs"];
while { true } do {
  _allCivs = allUnits - ( playableUnits + switchableUnits );
  {
    if(isNil { _x getVariable "CivilHasEventHandler" } && {side _x == civilian} && {!captive _x}) then {
      _x addEventHandler ["Killed", aegis_fnc_showCivKiller];
      _x setVariable ["CivilHasEventHandler", true];


      // debug = hint format["Adicionado EH ao civil %1", _x];
      // debug = createMarker [format["marker_%1", _x], getPos _x];
      // debug setMarkerShape "ICON"; debug setMarkerType "kia"; debug setMarkerColor "ColorGreen"; debug setMarkerText format["Adicionado EH ao civil %1", _x];
      // publicVariable "debug";

    };
  } forEach _allCivs;
  // Aumentar caso de zica de performance
  sleep 5;
};
