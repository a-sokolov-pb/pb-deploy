$PBExportHeader$n_ant_property.sru
forward
global type n_ant_property from nonvisualobject
end type
end forward

global type n_ant_property from nonvisualobject
end type
global n_ant_property n_ant_property

type variables
private:

string is_name
string is_value
string is_info
end variables
forward prototypes
public function string get_name ()
public function string get_value ()
public function string get_info ()
public function n_ant_property set_name (readonly string as_name)
public function n_ant_property set_value (readonly string as_value)
public function n_ant_property set_info (readonly string as_info)
end prototypes

public function string get_name ();return is_name
end function

public function string get_value ();return is_value
end function

public function string get_info ();return is_info
end function

public function n_ant_property set_name (readonly string as_name);is_name = as_name

return this
end function

public function n_ant_property set_value (readonly string as_value);is_value = as_value

return this
end function

public function n_ant_property set_info (readonly string as_info);is_info = as_info

return this
end function

on n_ant_property.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_ant_property.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

