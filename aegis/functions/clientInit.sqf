// Verifica a conta do jogador

_player = _this;
_playerUID = getPlayerUID _player;
_name  = name _player;

//hasDB = "aegis_finances" call iniDB_exists;
//hint format["Database is present: %1", hasDB];

_name = format["aegis_%1_%2", _name, _playerUID];
_money = ["aegis_finances", "pdw", _name, "ARRAY"] call iniDB_read;

//hint format["Grana: %1", _money select 0];
_player sideChat format["Grana: %1", _money select 0];
