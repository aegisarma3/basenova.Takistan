_player = _this select 0;
_id = _this select 1;
_uid = _this select 2;
_name = _this select 3;

diag_log "################ DISCONNECTED ##############";
diag_log _player;
diag_log _id;
diag_log _uid;
diag_log _name;
diag_log "############################################";

["savePlayer", [_player, _name, _uid]] call pdw;
["saveInventory", [_player, _name, _uid]] call pdw;
deleteVehicle _player;
