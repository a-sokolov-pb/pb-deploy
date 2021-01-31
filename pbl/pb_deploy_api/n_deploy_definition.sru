$PBExportHeader$n_deploy_definition.sru
forward
global type n_deploy_definition from nonvisualobject
end type
end forward

global type n_deploy_definition from nonvisualobject
end type
global n_deploy_definition n_deploy_definition

type variables
private:

string is_exe
string is_pbr
string is_favicon
string is_zip
string is_resources[]
end variables
forward prototypes
public function string get_exe ()
public function string get_pbr ()
public function string get_favicon ()
public subroutine parse (readonly n_json_parser an_json) throws exception
public function string get_zip ()
public function integer get_resources (ref string as_resources[])
end prototypes

public function string get_exe ();return is_exe
end function

public function string get_pbr ();return is_pbr
end function

public function string get_favicon ();return is_favicon
end function

public subroutine parse (readonly n_json_parser an_json) throws exception;is_exe = an_json.get_attribute("exe")
if an_json.is_attribute_exists("pbr") then
	is_pbr = an_json.get_attribute("pbr")
end if
if an_json.is_attribute_exists("favicon") then
	is_favicon = an_json.get_attribute("favicon")
end if
if an_json.is_attribute_exists("zip") then
	is_zip = an_json.get_attribute("zip")
end if
if an_json.is_attribute_exists("resources") then
	an_json.get_item("resources").get_string_array(ref is_resources)
end if

return
end subroutine

public function string get_zip ();return is_zip
end function

public function integer get_resources (ref string as_resources[]);as_resources = is_resources

return upperbound(as_resources)
end function

on n_deploy_definition.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_deploy_definition.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

