private ["_amount"];
_amount = _this;

_operators = count allPlayers;
_companyShare = 0.3 * _amount;
_individualOperatorShare = (_amount - _companyShare) / _operators;


{
  _balance = ["getPlayerBalance", [name _x, getPlayerUID _x]] call pdw;
  _balance = _balance + _individualOperatorShare;
  ["savePlayerMoney", [name _x, getPlayerUID _x, _balance]] call pdw;
  aegisOperatorMoney = _balance;
  owner _x publicVariableClient "aegisOperatorMoney";
  diag_log "########### PAYMENT ##############";
  diag_log _balance;
  diag_log "##################################";
} forEach allPlayers;
