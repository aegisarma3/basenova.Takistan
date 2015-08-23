#include "macro.h"
private ["_name","_uid","_player","_balance"];

_name	= param [0];
_uid	= param [1];
_player	= [_name, _uid] call aegis_fnc_getPlayerById;
_owner = owner _player;

diag_log "################ CONNECTED ##############";
diag_log _player;
diag_log _name;
diag_log _uid;
diag_log _owner;
diag_log "############################################";

// Verifica o quanto de dinheiro o player tem
_balance = ["getPlayerBalance", [_name, _uid]] call pdw;
aegisOperatorMoney = _balance;
_owner publicVariableClient "aegisOperatorMoney";

// Verifica se é a primeira vez que o player entra e dá dinheiro a ele
if (undefined(_balance)) then {

	// Chama o método que consulta o DB
	["savePlayerMoney", [_name, _uid, START_MONEY]] call pdw;
	aegisOperatorMoney = START_MONEY;
	_owner publicVariableClient "aegisOperatorMoney";

	// Avisa o player que foi adicionado uma grana na conta dele
	rHINT = [_player, format ["Foram adicionados $%1 em sua conta. Bem vindo!", START_MONEY],false];
	publicVariable "rHINT";

	// Limpa o inventário do player
	[_player,"aegis_fnc_clearInventory",_owner,true] call BIS_fnc_MP;

} else {
	// Se ele já tiver dinheiro na conta, informa a quantia ao player
	rHINT = [_player, format ["Seu saldo é de $%1", _balance],false];
	publicVariable "rHINT";

	// o usuario já tem loadout
	["loadPlayer", [_player, _name, _uid]] call pdw;
	["loadInventory", [_player, _name, _uid]] call pdw;
};
