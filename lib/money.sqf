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


// seta as variaveis
init(_player, player);
init(_playerUID, getPlayerUID _player);

// Coloca o nome no database de acordo com o profile do player
[_playerUID, "name", (name _player)] call stats_set;

// Verifica o quanto de dinheiro o player tem
_balance = [(getPlayerUID player), "money"] call stats_get;

// Verifica se é a primeira vez que o player entra e dá dinheiro a ele
if (undefined(_balance)) then {
	[_playerUID, "money", START_MONEY] call stats_set;
	hint format ["Foram adicionados $%1 em sua conta. Bem vindo!", START_MONEY];	
} else {
	hint format ["Você possui $ %1", _balance];
};

f_arsenal = {
	["Preload"] call BIS_fnc_arsenal; 
	["Open",true] call BIS_fnc_arsenal;
};

f_transaction = {
	private["_cost","_action"];

	_balance = [(getPlayerUID player), "money"] call stats_get;

	_cost = _this select 0;
	_action = _this select 1;
	

	if (_cost > _balance) then {
		hintC "Seu saldo é insuficiente para esta ação.";
		hintC_arr_EH = findDisplay 57 displayAddEventHandler ["unload", {0 = _this spawn {_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];hintSilent "";};}];
	} else {
		_balance = _balance - _cost;

		[getPlayerUID player, "money", _balance] call stats_set;
		[(getPlayerUID player)] call stats_flush;
		if (_balance <= 0) then {_balance = 1;};
		call _action;	
	};

};

f_show_balance = {
	_balance = [(getPlayerUID player), "money"] call stats_get;
	hintC format ["Saldo na Conta Corrente: $%1", _balance];
	hintC_arr_EH = findDisplay 57 displayAddEventHandler ["unload", {
		0 = _this spawn {
			_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
			hintSilent "";
		};
	}];
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