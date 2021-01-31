$PBExportHeader$n_generate_pbt_file.sru
forward
global type n_generate_pbt_file from n_generate_file_definition_base
end type
end forward

global type n_generate_pbt_file from n_generate_file_definition_base
end type
global n_generate_pbt_file n_generate_pbt_file

type variables
private:

constant string IS_TEMPLATE = 'Save Format v3.0(19990112)&
~r~n@begin Projects&
~r~n@end;&
~r~nappname "@app.name";&
~r~napplib "@app.lib";&
~r~nLibList "@lib.list";&
~r~ntype "pb";'
end variables

forward prototypes
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
end prototypes

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_template = IS_TEMPLATE

n_application_definition ln_application
ln_application = an_properties.get_application()
this.set_token(ref ls_template, "@app.name", ln_application.get_name())
this.set_token(ref ls_template, "@app.lib", ln_application.get_library())

string ls_lib_list

n_library ln_libraries[]
an_properties.get_libraries(ref ln_libraries)

int li_lib
for li_lib = 1 to upperbound(ln_libraries)
	if not ln_libraries[li_lib].get_scope() = c_scope.IS_RUNTIME then
		if len(ls_lib_list) > 0 then
			ls_lib_list += ";"
		end if
		ls_lib_list += f_deploy().get_path(ln_libraries[li_lib])
	end if
next

n_dependency_definition ln_dependency_def
ln_dependency_def = an_properties.get_dependency()
if isvalid(ln_dependency_def) then
	n_dependency_library ln_dep_libraries[]
	ln_dependency_def.get_libraries(ref ln_dep_libraries)
	
	for li_lib = 1 to upperbound(ln_dep_libraries)
		if not ln_dep_libraries[li_lib].get_scope() = c_scope.IS_RUNTIME &
			and f_string().equals(ln_dep_libraries[li_lib].get_type(), "pbd") then
			ls_lib_list += ";" + f_deploy().get_path(ln_dep_libraries[li_lib])
		end if
	next
	
	n_dependency_package ln_dep_packages[]
	ln_dependency_def.get_packages(ref ln_dep_packages)
	
	for li_lib = 1 to upperbound(ln_dep_packages)
		n_artifact ln_artifacts[]
		ln_dep_packages[li_lib].get_artifacts(ref ln_artifacts)
		
		int li_artifact
		for li_artifact = 1 to upperbound(ln_artifacts)
			if not ln_artifacts[li_artifact].get_scope() = c_scope.IS_RUNTIME &
				and f_string().equals(ln_artifacts[li_artifact].get_type(), "pbd") then
				ls_lib_list += ";" + f_deploy().get_path(ln_artifacts[li_artifact], ln_dep_packages[li_lib])
			end if
		next
	next
end if

this.set_token(ref ls_template, "@lib.list", ls_lib_list)

return ls_template
end function

on n_generate_pbt_file.create
call super::create
end on

on n_generate_pbt_file.destroy
call super::destroy
end on

