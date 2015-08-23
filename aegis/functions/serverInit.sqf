// Server Init
if (isServer) then {
	call compilefinal preprocessFileLineNumbers "aegis\pdw\oo_pdw.sqf";
	pdw = ["new", "inidbi"] call OO_PDW;
	["setFileName", "aegis_finances"] call pdw;

	// ## Valores ################################################################################################

	START_MONEY = ["AEGIS_INITIAL_MONEY", 5000] call BIS_fnc_getParamValue; 			// Dinheiro inicial para quem ainda não ganhou nada.

	// Arsenal ///////////////////////////////////////////////////////////////////////////////////////////////////////
	NAME_OF_THE_ARMORY = caixa01; 	// Nome do objeto que servirá como arsenal. deve estar no mapa.
	NAME_OF_THE_ATM = atm;

	ARSENAL_COST = ["AEGIS_ARSENAL_COST", 350] call BIS_fnc_getParamValue;			// Custo de acesso ao Arsenal
	publicVariable "ARSENAL_COST";

	HAS_COOLDOWN = false; 			// Seta a possibilidade do acesso ao arsenal ter tempo de espera ou não.
	COOLDOWN_AMOUNT = 30;			// Caso exista o tempo de espera, aqui determina quão longo ele é.

	// #################################################################################################################
	_isArsenalAvaliable = ["AEGIS_ARSENAL_ENABLE", 1] call BIS_fnc_getParamValue;

	if (_isArsenalAvaliable == 1) then {
		// Setup dos pontos de compra
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

};
