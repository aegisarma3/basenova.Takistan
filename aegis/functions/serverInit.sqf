// Server Init

call compilefinal preprocessFileLineNumbers "aegis\pdw\oo_pdw.sqf";
sleep 2;

pdw = ["new", "inidbi"] call OO_PDW;
["setFileName", "aegis_finances"] call pdw;
