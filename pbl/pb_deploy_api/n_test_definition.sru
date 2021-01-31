$PBExportHeader$n_test_definition.sru
forward
global type n_test_definition from nonvisualobject
end type
end forward

global type n_test_definition from nonvisualobject
end type
global n_test_definition n_test_definition

type variables
private:

string is_script
end variables
forward prototypes
public function string get_script ()
public function n_test_definition set_script (readonly string as_script)
end prototypes

public function string get_script ();return is_script
end function

public function n_test_definition set_script (readonly string as_script);is_script = as_script

return this
end function

on n_test_definition.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_test_definition.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

