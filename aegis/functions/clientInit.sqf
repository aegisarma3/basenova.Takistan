#include "macro.h"

// ## Customizações ################################################################################################

#define START_MONEY 5000 			// Dinheiro inicial para quem ainda não ganhou nada.

// Arsenal ///////////////////////////////////////////////////////////////////////////////////////////////////////
#define NAME_OF_THE_ARMORY caixa01 	// Nome do objeto que servirá como arsenal. deve estar no mapa.
#define NAME_OF_THE_ATM atm
#define ARSENAL_COST 350			// Custo de acesso ao Arsenal
#define HAS_COOLDOWN false 			// Seta a possibilidade do acesso ao arsenal ter tempo de espera ou não.
#define COOLDOWN_AMOUNT 30			// Caso exista o tempo de espera, aqui determina quão longo ele é.

// #################################################################################################################


waitUntil {isServer || {not(isNull player)}};

aegisOperator = _this;
aegisOperatorUID = getPlayerUID aegisOperator;
aegisOperatorName  = name aegisOperator;



// Verifica o quanto de dinheiro o player tem
_balance = ["getPlayerBalance", [aegisOperatorName, aegisOperatorUID]] call pdw;

// Verifica se é a primeira vez que o player entra e dá dinheiro a ele
if (undefined(_balance)) then {
	["savePlayerMoney", [aegisOperatorName, aegisOperatorUID, START_MONEY]] call pdw;
	rHINT = [aegisOperator, format ["Foram adicionados $%1 em sua conta. Bem vindo!", START_MONEY],false];
	publicVariable "rHINT";

} else {
	rHINT = [aegisOperator, format ["Seu saldo é de $%1", _balance],false];
	publicVariable "rHINT";
};




f_arsenal = {
	["Preload"] call BIS_fnc_arsenal;
	["Open",true] call BIS_fnc_arsenal;
};

f_transaction = {
	private["_cost","_action"];

	_balance = ["getPlayerBalance", [aegisOperatorName, aegisOperatorUID]] call pdw;

	_cost = _this select 0;
	_action = _this select 1;


	if (_cost > _balance) then {
		rHINT = [aegisOperator, "Seu saldo é insuficiente para esta ação.",true];
		publicVariable "rHINT";

	} else {
		_balance = _balance - _cost;

		["savePlayerMoney", [aegisOperatorName, aegisOperatorUID, _balance]] call pdw;
		if (_balance <= 0) then {_balance = 1;};
		call _action;
	};

};

f_show_balance = {
	_balance = ["getPlayerBalance", [aegisOperatorName, aegisOperatorUID]] call pdw;

	rHINT = [aegisOperator, format ["Saldo na Conta Corrente: $%1", _balance],true];
	publicVariable "rHINT";

};




if (isServer) then {

	clearMagazineCargoGlobal NAME_OF_THE_ARMORY;
	clearWeaponCargoGlobal NAME_OF_THE_ARMORY;
	clearItemCargoGlobal NAME_OF_THE_ARMORY;
	clearBackpackCargoGlobal NAME_OF_THE_ARMORY;

	// Ativa o arsenal
	NAME_OF_THE_ARMORY allowDamage false;
	[
		[
			NAME_OF_THE_ARMORY,
			[
				"<t color='#FF0000'>Acessar o Arsenal ($"+format["%1", ARSENAL_COST]+")</t>",
				{
					//(_this select 0) removeAction (_this select 2);
					[ARSENAL_COST, f_arsenal] call f_transaction;



				},
				nil,
				6,
				true,
				true,
				"",
				"_this distance _target < 5"
			]
		],
		"addAction",
		true,
		true,
		false
	] call BIS_fnc_MP;


	[
		[
			NAME_OF_THE_ATM,
			[
				"<t color='#009900'>Verificar fundos</t>",
				{
					call f_show_balance;
				},
				nil,
				6,
				true,
				true,
				"",
				"_this distance _target < 5"
			]
		],
		"addAction",
		true,
		true,
		false
	] call BIS_fnc_MP;

};
