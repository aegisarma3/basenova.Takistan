f_arsenal = {
	["Preload"] call BIS_fnc_arsenal;
	["Open",true] call BIS_fnc_arsenal;
};

f_transaction = {
	private["_cost","_action","_balance"];

	_balance = aegisOperatorMoney;

	_cost = _this select 0;
	_action = _this select 1;


	if (_cost > _balance) then {

		hintC "Seu saldo é insuficiente para esta ação.";
		hintC_arr_EH = findDisplay 57 displayAddEventHandler ["unload", {
			0 = _this spawn {
				_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
				hintSilent "";
			};
		}];


	} else {
		_balance = _balance - _cost;
		currentBalance = [player,_balance];
		publicVariableServer "currentBalance";

		if (_balance <= 0) then {_balance = 1;};
		call _action;
	};

};

f_show_balance = {
	_balance = aegisOperatorMoney;
	
	hintC format ["Saldo na Conta Corrente: $%1", _balance];
	hintC_arr_EH = findDisplay 57 displayAddEventHandler ["unload", {
		0 = _this spawn {
			_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
			hintSilent "";
		};
	}];

};
