$PBExportHeader$n_application_definition.sru
forward
global type n_application_definition from nonvisualobject
end type
end forward

global type n_application_definition from nonvisualobject
end type
global n_application_definition n_application_definition

type variables
private:

string is_name
string is_library
string is_target
string is_ws
end variables
forward prototypes
public subroutine parse (readonly n_json_parser an_json) throws exception
public function string get_name ()
public function string get_library ()
public function string get_target ()
public function string get_ws ()
end prototypes

public subroutine parse (readonly n_json_parser an_json) throws exception;is_name = an_json.get_attribute("name")
is_library = an_json.get_attribute("library")
is_target = an_json.get_attribute("target")
is_ws = an_json.get_attribute("ws")

return
end subroutine

public function string get_name ();return is_name
end function

public function string get_library ();return is_library
end function

public function string get_target ();return is_target
end function

public function string get_ws ();return is_ws
end function

on n_application_definition.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_application_definition.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

