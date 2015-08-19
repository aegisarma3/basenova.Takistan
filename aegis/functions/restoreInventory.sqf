_object = _this select 0;
_array = _this select 1;


removeallweapons _object;
removeGoggles _object;
removeHeadgear _object;
removeVest _object;
removeUniform _object;
removeAllAssignedItems _object;
removeBackpack _object;


_headgear = _array select 0;
_goggles = _array select 1;
_uniform = _array select 2;
_uniformitems = _array select 3;
_vest = _array select 4;
_vestitems = _array select 5;
_backpack = _array select 6;
_backpackitems = _array select 7;
_primaryweapon = _array select 8;
_primaryweaponitems = _array select 9;
_primaryweaponmagazine = _array select 10;
_secondaryweapon = _array select 11;
_secondaryweaponitems = _array select 12;
_secondaryweaponmagazine = _array select 13;
_handgunweapon = _array select 14;
_handgunweaponitems = _array select 15;
_handgunweaponmagazine = _array select 16;
_assigneditems = _array select 17;

_object addHeadgear _headgear;
_object forceAddUniform _uniform;
_object addGoggles _goggles;
_object addVest _vest;

{
  if(_x != "") then {
    _object addItemToUniform _x;
  };
}foreach _uniformitems;

{
  if(_x != "") then {
    _object addItemToVest _x;
  };
}foreach _vestitems;

if(format["%1", _backpack] != "") then {
  _object addbackpack _backpack;
  {
    if(_x != "") then {
      _object addItemToBackpack _x;
    };
  } foreach _backpackitems;
};

{
  if(_x != "") then {
    _object addMagazine _x;
  };
} foreach _primaryweaponmagazine;

//must be after assign items to secure loading mags
_object addweapon _primaryweapon;

{
  if(_x != "") then {
    _object addPrimaryWeaponItem _x;
  };
} foreach _primaryweaponitems;

{
  if(_x != "") then {
    _object addMagazine _x;
  };
} foreach _secondaryweaponmagazine;

_object addweapon _secondaryweapon;

{
  if(_x != "") then {
    _object addSecondaryWeaponItem _x;
  };
} foreach _secondaryweaponitems;


{
  if(_x != "") then {
    _object addMagazine _x;
  };
} foreach _handgunweaponmagazine;

_object addweapon _handgunweapon;

{
  if(_x != "") then {
    _object addHandgunItem _x;
  };
} foreach _handgunweaponitems;

{
  if(_x != "") then {
    _object additem _x;
    _object assignItem _x;
  };
} foreach _assigneditems;

_object addWeapon "ItemGPS";

if (needReload player == 1) then {reload player};
