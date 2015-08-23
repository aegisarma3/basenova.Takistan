private ["_amount"];
_amount = _this;

_operators = count allPlayers;

_companyMoney = ["aegis_finances", "pdw", "aegis_money", "SCALAR"] call iniDB_read;
if (_companyMoney <= 0) then {_companyMoney = 0;};
_companyShare = ceil(0.3 * _amount);

["aegis_finances", "pdw", "aegis_money", _companyMoney + _companyShare] call iniDB_write;

_individualOperatorShare = ceil((_amount - _companyShare) / _operators);

{
  _balance = ["getPlayerBalance", [name _x, getPlayerUID _x]] call pdw;
  _balance = _balance + _individualOperatorShare;
  ["savePlayerMoney", [name _x, getPlayerUID _x, _balance]] call pdw;
  aegisOperatorMoney = _balance;
  owner _x publicVariableClient "aegisOperatorMoney";
  [["Transaction", ["Você recebeu um pagamento.", format ["Foram depositados $%1 em sua conta.",_individualOperatorShare]]], "BIS_fnc_showNotification", owner _x] call BIS_fnc_MP;
  ["cash", "playSound", owner _x] call BIS_fnc_MP;

  diag_log "########### PAYMENT ##############";
  diag_log _balance;
  diag_log "##################################";
} forEach allPlayers;
