#include "macro.h"
private ["_name","_uid","_player","_balance"];

	_name	= param [0];
	_uid	= param [1];
	_player	= [_name, _uid] call aegis_fnc_getPlayerById;
	_owner = owner _player;

	_isPositionLoadAllowed = ["AEGIS_PLAYER_POSITION", 1] call BIS_fnc_getParamValue;
	_isInventoryLoadAllowed = ["AEGIS_LOAD_INVENTORY", 1] call BIS_fnc_getParamValue;
	_isNewPlayerInventoryEraseAllowed = ["AEGIS_CLEAR_INVENTORY", 1] call BIS_fnc_getParamValue;

if (_name != "__SERVER__") then {

	diag_log "################ CONNECTED ##############";
	diag_log _player;
	diag_log _name;
	diag_log _uid;
	diag_log _owner;
	diag_log "############################################";

	sleep 1;

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
		sleep 1;
		// Avisa o player que foi adicionado uma grana na conta dele
		[["CheckBalance", ["AEGIS FINACIAL SERVICES 2.0", format ["Foram adicionados $%1 em sua conta.<br/> Bem vindo!",START_MONEY]]], "BIS_fnc_showNotification", owner _player] call BIS_fnc_MP;
		["alert", "playSound", owner _player] call BIS_fnc_MP;

		// Limpa o inventário do player
		if (_isNewPlayerInventoryEraseAllowed == 1) then {
			[_player,"aegis_fnc_clearInventory",_owner,true] call BIS_fnc_MP;
		};

	} else {
		sleep 1;
		// Se ele já tiver dinheiro na conta, informa a quantia ao player
		[["CheckBalance", ["AEGIS FINACIAL SERVICES 2.0", format ["Saldo na conta corrente: $%1",_balance]]], "BIS_fnc_showNotification", owner _player] call BIS_fnc_MP;
		["alert", "playSound", owner _player] call BIS_fnc_MP;

		// o usuario já tem loadout
		if (_isPositionLoadAllowed == 1) then {
			["loadPlayer", [_player, _name, _uid]] call pdw;
		};
		if (_isInventoryLoadAllowed == 1) then {
			["loadInventory", [_player, _name, _uid]] call pdw;
		};
	};

};
