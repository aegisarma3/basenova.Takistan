f_arsenal = {
	["Preload"] call BIS_fnc_arsenal;
	["Open",true] call BIS_fnc_arsenal;
};

f_transaction = {
	private["_cost","_action"];

	_balance = aegisOperatorMoney;

	_cost = _this select 0;
	_action = _this select 1;


	if (_cost > _balance) then {
		rHINT = [operator, "Seu saldo é insuficiente para esta ação.",false];
		publicVariable "rHINT";

	} else {
		_balance = _balance - _cost;
		currentBalance = [operator,_balance];
		publicVariableServer "currentBalance";

		if (_balance <= 0) then {_balance = 1;};
		call _action;
	};

};

f_show_balance = {
	_balance = aegisOperatorMoney;

	rHINT = [operator, format ["Saldo na Conta Corrente: $%1", _balance],false];
	publicVariable "rHINT";

};
