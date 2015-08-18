aegisOperator = _this select 0;
aegisOperatorMoney = _this select 1;
aegisOperatorUID = getPlayerUID aegisOperator;
aegisOperatorName  = name aegisOperator;
aegisOperatorOwnerID = owner aegisOperator;

diag_log "##### TRANSACTION #####";
diag_log _this;
diag_log "------------------------";
diag_log aegisOperator;
diag_log aegisOperatorMoney;
diag_log aegisOperatorUID;
diag_log aegisOperatorName;
diag_log "########################";

["savePlayerMoney", [aegisOperatorName, aegisOperatorUID, aegisOperatorMoney]] call pdw;
aegisOperatorOwnerID publicVariableClient "aegisOperatorMoney";
