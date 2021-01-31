$PBExportHeader$n_generate_pbw_file.sru
forward
global type n_generate_pbw_file from n_generate_file_definition_base
end type
end forward

global type n_generate_pbw_file from n_generate_file_definition_base
end type
global n_generate_pbw_file n_generate_pbw_file

type variables
private:

constant string IS_TEMPLATE = 'Save Format v3.0(19990112)&
~r~n@begin Targets&
~r~n 0 "@target";&
~r~n@end;'
end variables

forward prototypes
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
end prototypes

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_target
if pos(an_param.get_name(), ":") > 0 then
	ls_target = f_string().right_part(an_param.get_name(), ":")
else
	ls_target = an_properties.get_application().get_target()
end if

string ls_template = IS_TEMPLATE
this.set_token(ls_template, "@target", ls_target)
return ls_template
end function

on n_generate_pbw_file.create
call super::create
end on

on n_generate_pbw_file.destroy
call super::destroy
end on

