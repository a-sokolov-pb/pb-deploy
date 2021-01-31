$PBExportHeader$n_generate_file_definition_base.sru
forward
global type n_generate_file_definition_base from nonvisualobject
end type
end forward

global type n_generate_file_definition_base from nonvisualobject
end type
global n_generate_file_definition_base n_generate_file_definition_base

type variables
private:

string is_param_name
string is_default_file_name
string is_folder
boolean ib_must_specify = false

n_build_properties in_properties
n_output_callback in_output
listbox ilb_container
end variables
forward prototypes
public subroutine set_properties (readonly n_build_properties an_properties)
public function string get_param_name ()
public function n_generate_file_definition_base set_param_name (readonly string as_param_name)
public function n_generate_file_definition_base set_default_file_name (readonly string as_default_file_name)
public function n_generate_file_definition_base set_must_specify (readonly boolean ab_must_specify)
public subroutine set_output (readonly n_output_callback an_output)
protected subroutine log (readonly string as_text)
protected subroutine set_token (ref string as_template, readonly string as_token, readonly string as_value)
public subroutine set_folder (readonly string as_folder)
public subroutine generate (readonly n_command_param an_param) throws exception
public subroutine set_container (readonly listbox alb_container)
protected function string get_folder ()
protected function listbox get_container ()
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
end prototypes

public subroutine set_properties (readonly n_build_properties an_properties);in_properties = an_properties

return
end subroutine

public function string get_param_name ();return is_param_name
end function

public function n_generate_file_definition_base set_param_name (readonly string as_param_name);is_param_name = as_param_name

return this
end function

public function n_generate_file_definition_base set_default_file_name (readonly string as_default_file_name);is_default_file_name = as_default_file_name

return this
end function

public function n_generate_file_definition_base set_must_specify (readonly boolean ab_must_specify);ib_must_specify = ab_must_specify

return this
end function

public subroutine set_output (readonly n_output_callback an_output);in_output = an_output

return
end subroutine

protected subroutine log (readonly string as_text);in_output.log(as_text)

return
end subroutine

protected subroutine set_token (ref string as_template, readonly string as_token, readonly string as_value);as_template = f_string().replace_all(as_template, as_token, as_value)

return
end subroutine

public subroutine set_folder (readonly string as_folder);is_folder = as_folder

return
end subroutine

public subroutine generate (readonly n_command_param an_param) throws exception;string ls_file_name
ls_file_name = an_param.get_value()
if f_string().is_empty(ls_file_name) then
	if ib_must_specify then
		throw f_exception().exception("Specify /" + an_param.get_name() + " param value")
	else
		ls_file_name = is_default_file_name
	end if
end if

ls_file_name = is_folder + ls_file_name

string ls_source
ls_source = this.generate_by_properties(an_param, in_properties)
if not f_string().is_empty(ls_source) then
	f_file_factory().write_file_data(ls_file_name, ls_source)
	this.log("Generated '" + ls_file_name + "' file data")
end if

return
end subroutine

public subroutine set_container (readonly listbox alb_container);ilb_container = alb_container

return
end subroutine

protected function string get_folder ();return is_folder
end function

protected function listbox get_container ();return ilb_container
end function

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;return ""
end function

on n_generate_file_definition_base.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_generate_file_definition_base.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

