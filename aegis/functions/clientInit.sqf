#include "macro.h"

aegisOperator = _this;
aegisOperatorUID = getPlayerUID aegisOperator;
aegisOperatorName  = name aegisOperator;
aegisOperatorOwnerID = owner aegisOperator;



// Verifica o quanto de dinheiro o player tem
_balance = ["getPlayerBalance", [aegisOperatorName, aegisOperatorUID]] call pdw;
aegisOperatorMoney = _balance;
aegisOperatorOwnerID publicVariableClient "aegisOperatorMoney";

// Verifica se é a primeira vez que o player entra e dá dinheiro a ele
if (undefined(_balance)) then {
	["savePlayerMoney", [aegisOperatorName, aegisOperatorUID, START_MONEY]] call pdw;
	aegisOperatorMoney = START_MONEY;
	aegisOperatorOwnerID publicVariableClient "aegisOperatorMoney";


	rHINT = [aegisOperator, format ["Foram adicionados $%1 em sua conta. Bem vindo!", START_MONEY],false];
	publicVariable "rHINT";

} else {
	rHINT = [aegisOperator, format ["Seu saldo é de $%1", _balance],false];
	publicVariable "rHINT";
};
