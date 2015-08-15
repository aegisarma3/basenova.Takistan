diag_log format["loading pstats library ..."];

#include "macro.h"

//Some wrappers for logging
pstats_log_severe = {
  ["pstats", _this] call log_severe;
};

pstats_log_warning = {
  ["pstats", _this] call log_warning;
};

pstats_log_info = {
  ["pstats", _this] call log_info;
};

pstats_log_fine = {
  ["pstats", _this] call log_fine;
};

pstats_log_finer = {
  ["pstats", _this] call log_finer;
};

pstats_log_finest = {
  ["pstats", _this] call log_finest;
};


pstats_log_set_level = {
  ["pstats", _this] call log_set_level;
};


//Set default logging level for this component
LOG_INFO_LEVEL call pstats_log_set_level;



pstats_mag_grenade_type = 0;
pstats_mag_primary_type = 1;
pstats_mag_handgun_type = 2;
pstats_mag_secondary_type = 4;
pstats_mag_vehicle_type = 65536;

pstats_clear_container = {
  ARGVX2(0,_container);
  clearWeaponCargoGlobal _container;
  clearItemCargoGlobal _container;
  clearMagazineCargoGlobal _container;
};

pstats_get_weapon_magazine_by_type = {
  ARGVX3(0,_player,objNull);
  ARGVX3(1,_type,0);

  init(_magazines,magazinesAmmoFull _player);
  def(_magazine);

  {
    init(_ctype,xGet(_x,3));
    if (_ctype == _type) exitWith {
      _magazine = _x;
    };
  } forEach _magazines;

  OR(_magazine,nil)
};


KK_fnc_addMagazineAmmoCargoGlobal = {
    _gr = createGroup sideLogic;
    _lg = _gr createUnit [
        "Logic",
        [0,0,0],
        [],
        0,
        "NONE"
    ];
    _lg addUniform "U_Rangemaster";
    {
        _lg addMagazine _x;
        _lg action [
            "PutMagazine",
            _this select 0,
            _x select 0
        ];
        waitUntil {
            magazines _lg isEqualTo []
        };
    } forEach (_this select 1);
    deleteVehicle _lg;
    deleteGroup _gr;
};


pstats_add_magazines_to_container = {
  ARGVX2(0,_container);
  ARGVX3(1,_magazines,[]);

  {
    if(isARRAY(_x) && {count(_x) == 3}) then {
      init(_name,xGet(_x,0));
      init(_count,xGet(_x,1));
      init(_ammo,xGet(_x,2));
      //should use addMagazineAmmoCargo once it's released
      _container addMagazineCargoGlobal [_name, _count];
    };
  } forEach _magazines;
};


pstats_save_side_weapon = {
  ARGVX3(0,_player,objNull);
  ARGVX3(1,_key,"");
  ARGVX3(2,_type,0);
  ARGVX3(3,_function_getWeapon,{});
  ARGVX3(4,_function_getWeaponItems,{});
  format["%1 call pstats_save_side_weapon;", _this] call pstats_log_finest;

  init(_weapon, [_player] call _function_getWeapon);
  setIf(_weapon == "",_weapon,nil,_weapon);
  [_player, _key, OR(_weapon,nil)] call pstats_side_set;


  //save the weapon magazine
  init(_magazine_key,_key + "_magazine");
  def(_magazine);
  _magazine = [_player,_type] call pstats_get_weapon_magazine_by_type;
  [_player,_magazine_key, getIf((isARRAY(_magazine) && count(_magazine) > 0),_magazine,nil)] call pstats_side_set;


  //save the weapon items
  init(_items_key, _key + "_items");
  init(_items, [_player] call _function_getWeaponItems);
  [_player, _items_key, getIf((isARRAY(_items) && count(_items) > 0),_items,nil)] call pstats_side_set;
};

pstats_load_side_weapon = {
  ARGVX3(0,_player,objNull);
  ARGVX3(1,_key,"");
  ARGVX3(2,_function_getWeapon,{});
  ARGV4(3,_function_removeItems,{},{});
  ARGVX3(4,_function_addItem,{});

  format["%1 call pstats_load_side_weapon;", _this] call pstats_log_finest;

  init(_weapon,[_player] call _function_getWeapon);
  if (_weapon != "") then {
    _player removeWeaponGlobal _weapon;
  };

  _weapon = [_player, _key] call pstats_side_local_get;
  if (!isSTRING(_weapon) || {_weapon == ""}) exitWith {
    format["could not load player's side %1",_key] call pstats_log_info;
  };

  //load the magazine if any
  init(_magazine_key, _key + "_magazine");
  def(_magazine);
  _magazine = [_player, _magazine_key] call pstats_side_local_get;
  init(_magazine_valid,(isARRAY(_magazine) && {count(_magazine) > 1}));

  if (_magazine_valid) then {
    [(backpackContainer _player), [[xGet(_magazine,0),1,xGet(_magazine,1)]]] call pstats_add_magazines_to_container;
  };

  //add the weapon
  _player addWeaponGlobal _weapon;

  //set the ammo amount
  if (_magazine_valid) then {
    _player setAmmo [_weapon, xGet(_magazine,1)];
  };


  //remove weapon items
  [_player] call _function_removeItems;

  //add weapon items
  init(_items_key,_key + "_items");
  def(_items);
  _items = [_player, _items_key] call pstats_side_local_get;
  if (isARRAY(_items)) then {
    {
      if (defined(_x) && {_x != ""}) then {
        [_player, _x] call _function_addItem;
      };
    } forEach _items;
  };

};



pstats_save_side_string_property = {
  ARGVX3(0,_player,objNull);
  ARGVX3(1,_key,"");
  ARGVX3(2,_function_getProperty,{});


  init(_value, [_player] call _function_getProperty);
  setIf(_value == "",_value,nil,_value);
  [_player, _key, OR(_value,nil)] call pstats_side_set;
};

pstats_load_string_property = {
  ARGVX3(0,_player,objNull);
  ARGVX3(1,_key,"");
  ARGVX3(2,_function_removeProperty,{});
  ARGVX3(3,_function_addProperty,{});

  [_player] call _function_removeProperty;

  def(_value);
  _value = [_player,_key] call pstats_side_local_get;
  if (!isSTRING(_value) || {_value == ""}) exitWith {
    format["could not load player's side %1", _key] call pstats_log_info;
  };

  [_player,_value] call _function_addProperty;
};


pstats_is_valid_cargo = {
  ARGVX4(0,_value,[],false);
  (count(_value) == 2 && {
      isARRAY(xGet(_value,0)) && {
      isARRAY(xGet(_value,1)) && {
      count(xGet(_value,0))  > 0 && {
      count(xGet(_value,0)) == count(xGet(_value,1))
  }}}})
};

pstats_save_container_items = {
  ARGVX3(0,_player,objNull);
  ARGVX2(1,_container);
  ARGVX3(2,_key,"");

  init(_value,getItemCargo _container);
  if (not([_value] call pstats_is_valid_cargo)) then {
    _value = nil;
  };

  [_player,_key,OR(_value,nil)] call pstats_side_set;
};

pstats_load_container_items = {
  ARGVX3(0,_player,objNull);
  ARGVX2(1,_container);
  ARGVX3(2,_key,"");

  def(_value);
  _value = [_player,_key] call pstats_side_local_get;
  if (not([OR(_value,nil)] call pstats_is_valid_cargo)) exitWith {
    format["could not load player's side %1", _key] call pstats_log_info;
  };

  init(_items,xGet(_value,0));
  init(_counts,xGet(_value,1));

  {
    init(_item,_x);
    init(_count,xGet(_counts,_forEachIndex));

    _container addItemCargoGlobal [_item, _count];
  } forEach _items;
};

pstats_update_entity = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_update_entity;", _this] call pstats_log_finest;


  if (isClient) exitWith {
    _player setVariable ["entity", nil, true];
    [[_player], "pstats_update_entity", false, false] call BIS_fnc_MP;
    waitUntil {not(isNil{_player getVariable "entity"})};
  };

  def(_uid);
  _uid = getPlayerUID _player;
  [_uid, "entity", netId _player] call stats_set;
  _player setVariable ["entity", (netId _player), true];
};

pstats_side_to_string = {
	ARGVX2(0,_side);

	if (_side == east || {
	    _side == west || {
	    _side == civilian || {
	    _side == resistance

	}}}) exitWith {
	  toLower(str(_side))
	};

  format["Uknown side: %1", _side] call pstats_log_warning;
	nil
};


pstats_get_side_scope = {
  ARGVX3(0,_player,objNull);

  def(_side);
  _side = [(side _player)] call pstats_side_to_string;
  if (undefined(_side)) exitWith {nil};

  init(_actual_uid,getPlayerUID _player);
  init(_saved_uid,_player getVariable "uid");

  _actual_uid = OR(_actual_uid,"");
  _saved_uid = OR(_saved_uid,"");

  if (_actual_uid == "" && {(!isSTRING(_saved_uid) || {_saved_uid == ""})}) exitWith {
    format["could not determine the player's UID to build side scope name: %1", _player] call pstats_log_warning;
  };

  def(_uid);
  if (not(_saved_uid == "")) then {
    _uid = _saved_uid;
  };

  if (not(_actual_uid == "")) then {
    _uid = _actual_uid;
  };

  (_uid + "_" + _side)
};

pstats_side_set = {
  ARGVX3(0,_player,objNull);

  def(_scope);
  _scope = [_player] call pstats_get_side_scope;
  if (not(isSTRING(_scope))) exitWith {nil};

  xSet(_this,0,_scope);
  (_this call stats_set)
};

pstats_side_local_get = {
  ARGVX3(0,_player,objNull)
  ARGVX3(1,_key,"");

  init(_value,_player getVariable _key);
  OR(_value,nil)
};

pstats_side_local_load = {
  ARGVX4(0,_player,objNull,false)

  def(_scope);
  _scope = [_player] call pstats_get_side_scope;
  if (!isSTRING(_scope)) exitWith {nil};

  init(_result,[_scope] call stats_get);

  if (!isARRAY(_result)) exitWith {
    format["could not load stats for %1", _scope] call pstats_log_severe;
    false
  };

  {
    init(_key,xGet(_x,0));
    init(_value,xGet(_x,1));
    _player setVariable [_key, OR(_value,nil)];
  } forEach _result;

  true
};

pstats_side_get = {
  ARGVX3(0,_player,objNull)

  def(_scope);
  _scope = [_player] call pstats_get_side_scope;
  if (undefined(_scope)) exitWith {nil};
  xSet(_this,0,_scope);

  (_this call stats_get)
};

pstats_save_side_position = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_position;", _this] call pstats_log_finest;

  init(_pos,getPosATL _player);
  init(_dir,getDir _player);

  [_player, "pos_atl", _pos] call pstats_side_set;
  [_player, "dir", _dir] call pstats_side_set;
};

//Save and load player stance
pstats_save_side_animation = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_animation;", _this] call pstats_log_finest;
  [
    _player,
    "animation",
    {
      ARGVX3(0,_player,objNull);
      (animationState _player)
    }
  ] call pstats_save_side_string_property;
};

pstats_load_side_animation = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_animation;", _this] call pstats_log_finest;
  [
    _player,
    "animation",
    {},
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_value,"");
      _player switchMove _value;
    }
  ] call pstats_load_string_property;
};


//Save and load player stance
pstats_save_side_current_weapon = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    "current_weapon",
    {
      ARGVX3(0,_player,objNull);
      (currentWeapon _player)
    }
  ] call pstats_save_side_string_property;
};

pstats_load_side_current_weapon = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    "current_weapon",
    {},
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_value,"");
      _player selectWeapon _value;
    }
  ] call pstats_load_string_property;
};

//Save and load player damage
pstats_save_side_damage = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_damage;", _this] call pstats_log_finest;
  init(_key,"damage");
  init(_value,getDammage _player);
  [_player, _key, _value] call pstats_side_set;
};

pstats_load_side_damage = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_damage;", _this] call pstats_log_finest;

  init(_key,"damage");
  def(_value);
  _value = [_player, _key] call pstats_side_local_get;
  if (!isSCALAR(_value)) exitWith {
    format["could not load player's side %1", _key] call pstats_log_info;
  };
  _player setDamage _value;
};

//Save, and load player fatigue
pstats_save_side_fatigue = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_fatigue;", _this] call pstats_log_finest;
  init(_key,"fatigue");
  init(_value,getFatigue _player);
  [_player, _key, _value] call pstats_side_set;
};

pstats_load_side_fatigue = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_fatigue;", _this] call pstats_log_finest;

  init(_key,"fatigue");
  def(_value);
  _value = [_player, _key] call pstats_side_local_get;
  if (!isSCALAR(_value)) exitWith {
    format["could not load player's side %1", _key] call pstats_log_info;
  };
  _player setFatigue _value;
};

//Save and load player uniform
pstats_save_side_uniform = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_uniform;", _this] call pstats_log_finest;
  [
    _player,
    "uniform",
    {
      ARGVX3(0,_player,objNull);
      (uniform _player)
    }
  ] call pstats_save_side_string_property;
};

pstats_load_side_uniform = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_uniform;", _this] call pstats_log_finest;

  [
    _player,
    "uniform",
    {
      ARGVX3(0,_player,objNull);
      removeUniform _player;
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_value,"");
      _player forceAddUniform _value;
      [(uniformContainer _player)] call pstats_clear_container;
    }
  ] call pstats_load_string_property;
};

//Save, and load player goggles
pstats_save_side_goggles = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_goggles;", _this] call pstats_log_finest;
  [
    _player,
    "goggles",
    {
      ARGVX3(0,_player,objNull);
      (goggles _player)
    }
  ] call pstats_save_side_string_property;
};

pstats_load_side_goggles = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_goggles;", _this] call pstats_log_finest;
  [
    _player,
    "goggles",
    {
      ARGVX3(0,_player,objNull);
      removeGoggles _player;
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_value,"");
      _player addGoggles _value;
    }
  ] call pstats_load_string_property;
};

//Save and load player headgear
pstats_save_side_headgear = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_headgear;", _this] call pstats_log_finest;
  [
    _player,
    "headgear",
    {
      ARGVX3(0,_player,objNull);
      (headgear _player)
    }
  ] call pstats_save_side_string_property;
};

pstats_load_side_headgear = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_headgear;", _this] call pstats_log_finest;
  [
    _player,
    "headgear",
    {
      ARGVX3(0,_player,objNull);
      removeHeadgear _player;
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_value,"");
      _player addHeadgear _value;
    }
  ] call pstats_load_string_property;
};

//save and load player assigned items
pstats_save_side_assigned_items = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_assigned_items;", _this] call pstats_log_finest;

  init(_assigned_items,assignedItems _player);
  [_player, "assigned_items", _assigned_items] call pstats_side_set;
};


pstats_load_side_assigned_items = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_assigned_items;", _this] call pstats_log_finest;

  removeAllAssignedItems _player;

  def(_assigned_items);
  _assigned_items = [_player, "assigned_items"] call pstats_side_local_get;
  if (!isARRAY(_assigned_items)) exitWith {
    format["could not load player's side assigned-items"] call pstats_log_info;
  };

  {
    if (_x == "Binocular" || {
        _x == "Laserdesignator" ||{
        _x == "Rangefinder" || {
        _x == "ACE_Vector" ||{
        _x == "rhsusf_lerca1200_black" ||{
        _x == "rhsusf_lerca1200_tan" 
        }}}}}) then {
      _player addWeapon _x;
    }
    else {
      _player linkItem _x;
    };
  } forEach _assigned_items;
};


//Save and load player backpack
pstats_save_side_backpack = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_backpack;", _this] call pstats_log_finest;

  init(_backpack,backpack  _player);
  [_player, "backpack", _backpack] call pstats_side_set;
};


pstats_load_side_backpack = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_backpack;", _this] call pstats_log_finest;

  removeBackpack _player;

  def(_backpack);
  _backpack = [_player, "backpack"] call pstats_side_local_get;
  if (!isSTRING(_backpack)) exitWith {
    format["could not load player's side backpack"] call pstats_log_info;
  };

  _player addBackpack _backpack;

  [(backpackContainer _player)] call pstats_clear_container;
};


//Save and load player vest
pstats_save_side_vest = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_vest;", _this] call pstats_log_finest;

  init(_vest, vest _player);
  [_player, "vest", _vest] call pstats_side_set;
};


pstats_load_side_vest = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_vest;", _this] call pstats_log_finest;

  removeVest _player;

  def(_vest);
  _vest = [_player, "vest"] call pstats_side_local_get;
  if (!isSTRING(_vest)) exitWith {
    format["could not load player's side vest"] call pstats_log_info;
  };

  _player addVest _vest;

  [(vestContainer _player)] call pstats_clear_container;
};

//Save and load primary weapon
pstats_save_side_primary_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_primary_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "primary_weapon",
    pstats_mag_primary_type,
    {
      ARGVX3(0,_player,objNull);
      (primaryWeapon _player)
    },
    {
      ARGVX3(0,_player,objNull);
      (primaryWeaponItems _player)
    }
  ] call pstats_save_side_weapon;
};


pstats_load_side_primary_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_primary_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "primary_weapon",
    {
      ARGVX3(0,_player,objNull);
      (primaryWeapon _player)
    },
    {
      ARGVX3(0,_player,objNull);
      (removeAllPrimaryWeaponItems _player)
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_item,"");
      (_player addPrimaryWeaponItem _item)
    }
  ] call pstats_load_side_weapon;
};


//Save and load secondary weapon
pstats_save_side_secondary_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_secondary_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "secondary_weapon",
    pstats_mag_secondary_type,
    {
      ARGVX3(0,_player,objNull);
      (secondaryWeapon _player)
    },
    {
      ARGVX3(0,_player,objNull);
      (secondaryWeaponItems _player)
    }
  ] call pstats_save_side_weapon;
};

pstats_load_side_secondary_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_secondary_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "secondary_weapon",
    {
      ARGVX3(0,_player,objNull);
      (secondaryWeapon _player)
    },
    {
      //there is no function to remove secondary weapon items
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_item,"");
      (_player addSecondaryWeaponItem _item)
    }
  ] call pstats_load_side_weapon;
};


//Save and load handgun
pstats_save_side_handgun_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_handgun_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "handgun_weapon",
    pstats_mag_handgun_type,
    {
      ARGVX3(0,_player,objNull);
      (handgunWeapon _player)
    },
    {
      ARGVX3(0,_player,objNull);
      (handgunItems _player)
    }
  ] call pstats_save_side_weapon;
};

pstats_load_side_handgun_weapon = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_handgun_weapon;", _this] call pstats_log_finest;

  [
    _player,
    "handgun_weapon",
    {
      ARGVX3(0,_player,objNull);
      (handgunWeapon _player)
    },
    {
      ARGVX3(0,_player,objNull);
      (removeAllHandgunItems _player)
    },
    {
      ARGVX3(0,_player,objNull);
      ARGVX3(1,_item,"");
      (_player addHandgunItem _item)
    }
  ] call pstats_load_side_weapon;
};

pstats_save_side_backpack_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (backpackContainer _player),
    "backpack_items"
  ] call pstats_save_container_items;
};

pstats_load_side_backpack_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (backpackContainer _player),
    "backpack_items"
  ] call pstats_load_container_items;
};

pstats_save_side_vest_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (vestContainer _player),
    "vest_items"
  ] call pstats_save_container_items;
};

pstats_load_side_vest_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (vestContainer _player),
    "vest_items"
  ] call pstats_load_container_items;
};

pstats_save_side_uniform_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (uniformContainer _player),
    "uniform_items"
  ] call pstats_save_container_items;
};

pstats_load_side_uniform_items = {
  ARGVX3(0,_player,objNull);
  [
    _player,
    (uniformContainer _player),
    "uniform_items"
  ] call pstats_load_container_items;
};



//Save and load magazines in uniform, backpack, and vest
pstats_save_side_magazines = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_magainzes;", _this] call pstats_log_finest;

  init(_magazines,magazinesAmmoFull _player);
  [_player, "magazines", _magazines] call pstats_side_set;
};


pstats_load_side_magazines = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_magazines;", _this] call pstats_log_finest;

  def(_magazines);
  _magazines = [_player, "magazines"] call pstats_side_local_get;
  if (!isARRAY(_magazines)) exitWith {
    format["could not load player's side magazines"] call pstats_log_info;
  };

  init(_backpack_container,backpackContainer _player);
  init(_vest_container,vestContainer _player);
  init(_uniform_container,uniformContainer _player);

  init(_backpack_magazines,[]);
  init(_vest_magazines,[]);
  init(_uniform_magazines,[]);
  init(_uniform_magazine,[]);
  init(_other_magazines,[]);

  {
    init(_magazine,_x);
    init(_name,xGet(_x,0));
    init(_ammo,xGet(_x,1));
    init(_loaded,xGet(_x,2));
    init(_type,xGet(_x,3)); // 0 - grenade, 1 - primary, 2 - handgun, 4 - secondary
    init(_location,xGet(_x,4));

    def(_mag);
    _mag = [_name,1,_ammo];

    if (_location == "Backpack") then {
      xPush(_backpack_magazines,_mag)
    }
    else { if (_location == "Vest" ) then {
      xPush(_vest_magazines,_mag)
    }
    else { if (_location == "Uniform" ) then {
      xPush(_uniform_magazines,_mag)
    }
    else { if (not(_type  == pstats_mag_primary_type ||{
                   _type == pstats_mag_handgun_type ||{
                   _type == pstats_mag_secondary_type}})) then {
      xPush(_other_magazines,_mag);
    }}}};
  } forEach (_magazines);

  [_backpack_container, _backpack_magazines] call pstats_add_magazines_to_container;
  [_vest_container, _vest_magazines] call pstats_add_magazines_to_container;
  [_uniform_container, _uniform_magazines] call pstats_add_magazines_to_container;

  //other magazines that are loaded that appear in a muzzle usually hand grenades, and smokes
  {
    _player addMagazineGlobal (xGet(_x,0));
  } forEach _other_magazines;
};

pstats_add_temp_cargo_space = {
  ARGVX3(0,_player,objNull);
  removeBackpack _player;
  _player addBackpack "B_HuntingBackpack";
};

pstats_remove_temp_cargo_space = {
  ARGVX3(0,_player,objNull);
  removeBackpack _player;
};

pstats_load_side_position = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_position;", _this] call pstats_log_finest;

  def(_pos);
  def(_dir);
  _pos = [_player, "pos_atl"] call pstats_side_local_get;
  _dir = [_player, "dir"] call pstats_side_local_get;

  if (isARRAY(_pos)) then {
    _player setPosATL _pos;
  }
  else {
    format["could not load player's side position"] call pstats_log_info;
  };

  if (isSCALAR(_dir)) then {
    _player setDir _dir;
  }
  else {
    format["could not load player's side direction"] call pstats_log_info;
  };
};

pstats_save_side_data = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_save_side_data;", _this] call pstats_log_finest;

  [_player] call pstats_save_side_primary_weapon;
  [_player] call pstats_save_side_secondary_weapon;
  [_player] call pstats_save_side_handgun_weapon;
  [_player] call pstats_save_side_position;
  [_player] call pstats_save_side_animation;
  [_player] call pstats_save_side_damage;
  [_player] call pstats_save_side_fatigue;
  [_player] call pstats_save_side_uniform;
  [_player] call pstats_save_side_goggles;
  [_player] call pstats_save_side_headgear;
  [_player] call pstats_save_side_assigned_items;
  [_player] call pstats_save_side_backpack;
  [_player] call pstats_save_side_vest;
  [_player] call pstats_save_side_magazines;
  [_player] call pstats_save_side_backpack_items;
  [_player] call pstats_save_side_vest_items;
  [_player] call pstats_save_side_uniform_items;
  [_player] call pstats_save_side_current_weapon;

};

pstats_load_side_data = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_load_side_data;", _this] call pstats_log_finest;

  //load all the stats at once, and save them in the player object
  [_player] call pstats_side_local_load;

  _player allowDamage false;
  [_player] call pstats_add_temp_cargo_space; //HACK: this is used as temporary place to hold the magainzes for the weapons
  [_player] call pstats_load_side_primary_weapon;
  [_player] call pstats_load_side_secondary_weapon;
  [_player] call pstats_load_side_handgun_weapon;
  sleep 1; //allow the gun loading animation to play
  [_player] call pstats_remove_temp_cargo_space;
  [_player] call pstats_load_side_position;
  [_player] call pstats_load_side_animation;
  [_player] call pstats_load_side_damage;
  [_player] call pstats_load_side_fatigue;
  [_player] call pstats_load_side_uniform;
  [_player] call pstats_load_side_goggles;
  [_player] call pstats_load_side_headgear;
  [_player] call pstats_load_side_assigned_items;
  [_player] call pstats_load_side_backpack;
  [_player] call pstats_load_side_vest;
  [_player] call pstats_load_side_magazines;
  [_player] call pstats_load_side_backpack_items;
  [_player] call pstats_load_side_vest_items;
  [_player] call pstats_load_side_uniform_items;
  [_player] call pstats_load_side_current_weapon;


   _player allowDamage true;
};


pstats_reset_gear = {
  ARGVX3(0,_player,objNull);

  removeAllAssignedItems _player;
  removeBackpack _player;
  removeUniform _player;
  removeVest _player;
  removeAllWeapons _player;
  removeHeadgear _player;
  removeGoggles _player;
  removeAllItems _player;
};

pstats_flush_data = {
  ARGVX3(0,_player,objNull);
  format["%1 call pstats_flush_data;", _this] call pstats_log_finest;

   init(_side_scope, [_player] call pstats_get_side_scope);
   init(_main_scope, getPlayerUID _player);

   def(_result);
   format["pstats_flush_data: flushing scope %1", _side_scope] call pstats_log_info;
   _result = [_side_scope] call stats_flush;
   if (undefined(_result)) then {
      format["could not flush side scope data for: %1", _side_scope] call pstats_log_severe;
   };

   _result = [_main_scope] call stats_flush;
   format["pstats_flush_data: flushing scope %1", _main_scope] call pstats_log_info;
   if (undefined(_result)) then {
     format["could not flush main scope data for: %1", _main_scope] call pstats_log_severe;
   };
};

pstats_disconnect_handler = {
  if (undefined(_uid)) exitWith {nil};
  format["_uid = %1, disconnected", _uid] call pstats_log_info;

  def(_entity_netId);
  _entity_netId = [_uid, "entity", ""] call stats_get;
  init(_entity,objectFromNetId _entity_netId);

  _entity setVariable ["uid", _uid];
  [_entity] call pstats_save_side_data;
  [_entity] call pstats_flush_data;
  deleteVehicle _entity;
};

pstats_handle_mprespawn = {
  	ARGV3(0,_unit,objNull);
  	ARGV3(1,_corpse,objNull);
    format["%1 call pstats_handle_mprespawn;", _this] call pstats_log_info;

    if (not(local _unit)) exitWith {};
  	[_unit, false] call pstats_handle_spawn;
};

pstats_handle_spawn = { _this spawn {
  if (not(isClient)) exitWith {};
	ARGVX3(0,_player,objNull);
	ARGV4(1,_first_time,false,false);

	waitUntil { alive _player };

	[_player] call pstats_update_entity;

	if (_first_time) then {
    [_player] call pstats_load_side_data;
  }
  else {
    [_player] call pstats_reset_gear;
  };
};};


pstats_init = {
  ARGV3(0,_player,objNull);
  format["%1 call pstats_init;", _this] call pstats_log_finest;

  init(_flag_name, "pstats_server_complete");

  //Server-side init
  if (isServer) then {
    ["pstats_disconnect_handler", "onPlayerDisconnected", pstats_disconnect_handler] call BIS_fnc_addStackedEventHandler;

    //tell clients that server pstats has initialized
    missionNamespace setVariable[_flag_name, true];
    publicVariable _flag_name;
    "pstats library loaded on server ..." call pstats_log_info;
  };

  //Client-side init (must wait for server-side init to complete)
  if (isClient) then {
    "waiting for server to load pstats library ..." call pstats_log_info;
    waitUntil {not(isNil _flag_name)};
    _player addMPEventHandler ["MPRespawn",{ _this call pstats_handle_mprespawn }];

    "waiting for server to load pstats library ... done" call pstats_log_info;
  };
};


init(_player, player);
[_player] call pstats_init;
[_player, true] call pstats_handle_spawn;
diag_log format["loading pstats library complete"];