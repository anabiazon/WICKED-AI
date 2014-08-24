private ["_objectivetarget","_position","_type","_complete","_timeout","_mission","_killpercent","_delete_mines","_cleanunits","_clearmission","_baseclean"];
_mission	= (_this select 0) select 0;
_crate		= (_this select 0) select 1;
_objectives	= _this select 1;
_type	= _objectives select 0;
if (count _objectives > 1) then {
	_objectivetarget = _objectives select 1;
};
_baseclean	= _this select 2;
_msgstart	= _this select 3;
_msgwin		= _this select 4;
_msglose	= _this select 5;

_position				= position _crate;
_timeout 				= false;
_complete				= false;
_playerPresent 			= false;
_starttime 				= time;
_timeoutTime			= ((wai_mission_timeout select 0) + random((wai_mission_timeout select 1) - (wai_mission_timeout select 0)));
_maxai					= (wai_mission_data select _mission) select 0;

[nil,nil,rTitleText,_msgstart,"PLAIN",10] call RE;

while {!_timeout && !_complete} do {

	sleep 1;
	_currenttime = time;
	{
		if((isPlayer _x) && (_x distance _position <= wai_timeout_distance)) then {
			_starttime = time;
		};
		
	} forEach playableUnits;

	if (_currenttime - _starttime >= _timeoutTime) then {
		_timeout = true;
	};
	
	call {
		if (_type == "crate") exitWith {
			{
				if((isPlayer _x) && (_x distance _position <= 20)) then {
					_complete = true
				};
			} forEach playableUnits;
		};
		if (_type == "kill") exitWith {
			_killpercent = _maxai - (_maxai * (_objectivetarget / 100));
			if(((wai_mission_data select _mission) select 0) <= _killpercent) then {
				_complete = true
			};
		};
		if (_type == "assassinate") exitWith {
			{
				_complete = true;
				if (alive _x) exitWith {_complete = false;};
			} count units _objectivetarget;
		};
	};
};

if (_complete) then {
	if(wai_crates_smoke) then {
		_marker = "smokeShellPurple" createVehicle getPosATL _crate;
		_marker setPosATL (getPosATL _crate);
		_marker attachTo [_crate,[0,0,0]];
	};
	if (wai_crates_flares && sunOrMoon != 1) then {
		_marker = "RoadFlare" createVehicle getPosATL _crate;
		_marker setPosATL (getPosATL _crate);
		_marker attachTo [_crate, [0,0,0]];
		
		_inRange = _crate nearEntities ["CAManBase",1250];
		
		{
			if(isPlayer _x && _x != player) then {
				PVDZE_send = [_x,"RoadFlare",[_marker,0]];
				publicVariableServer "PVDZE_send";
			};
		} count _inRange;

	};

	_delete_mines = ((wai_mission_data select _mission) select 2);
	if(count _delete_mines > 0) then {
		{
			if(typeName _x == "ARRAY") then {
			
				{
					deleteVehicle _x;
				} forEach _x;
			
			} else {
			
				deleteVehicle _x;
			};
			
		} forEach _delete_mines;
	};
	
	wai_mission_data set [_mission, -1];
	[nil,nil,rTitleText,_msgwin,"PLAIN",10] call RE;
};

if (_timeout) then {
	{
		_cleanunits = _x getVariable "missionclean";
	
		if (!isNil "_cleanunits") then {

			switch (_cleanunits) do {
				case "ground" :  {ai_ground_units = (ai_ground_units -1);};
				case "air" :     {ai_air_units = (ai_air_units -1);};
				case "vehicle" : {ai_vehicle_units = (ai_vehicle_units -1);};
				case "static" :  {ai_emplacement_units = (ai_emplacement_units -1);};
			};
			sleep .1;
		};
		if (_x getVariable ["mission", nil] == _mission) then {	deleteVehicle _x; };
	} forEach allUnits + vehicles;
	
	{
		if(typeName _x == "ARRAY") then {
		
			{
				deleteVehicle _x;
			} forEach _x;
		
		} else {
		
			deleteVehicle _x;
		};
		
	} forEach _baseclean + ((wai_mission_data select _mission) select 2) + [_crate];
		
	wai_mission_data set [_mission, -1];
	[nil,nil,rTitleText,_msglose,"PLAIN",10] call RE;
};








