rHINT = [];

private ["_player","_message","_type"];

_player = _this select 0;

_message = _this select 1;

_type = _this select 2;

if (!isNull _player && {local _player}) then {

	if (_type) then {

		hintC _message;
		hintC_arr_EH = findDisplay 57 displayAddEventHandler ["unload", {
			0 = _this spawn {
				_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
				hintSilent "";
			};
		}];

	} else {
		hint _message;
	};


};
