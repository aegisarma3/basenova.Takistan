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

	// Chama o método que consulta o DB
	["savePlayerMoney", [aegisOperatorName, aegisOperatorUID, START_MONEY]] call pdw;
	aegisOperatorMoney = START_MONEY;
	aegisOperatorOwnerID publicVariableClient "aegisOperatorMoney";

	// Avisa o player que foi adicionado uma grana na conta dele
	rHINT = [aegisOperator, format ["Foram adicionados $%1 em sua conta. Bem vindo!", START_MONEY],false];
	publicVariable "rHINT";

	// Limpa o inventário do player
	[aegisOperator,"aegis_fnc_clearInventory",aegisOperatorOwnerID,true] call BIS_fnc_MP;

} else {
	// Se ele já tiver dinheiro na conta, informa a quantia ao player
	rHINT = [aegisOperator, format ["Seu saldo é de $%1", _balance],false];
	publicVariable "rHINT";

	// o usuario já tem loadout
	["loadPlayer", [aegisOperator, aegisOperatorName, aegisOperatorUID]] call pdw;
	["loadInventory", [aegisOperator, aegisOperatorName, aegisOperatorUID]] call pdw;
};
