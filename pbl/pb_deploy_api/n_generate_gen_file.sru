$PBExportHeader$n_generate_gen_file.sru
forward
global type n_generate_gen_file from n_generate_file_definition_base
end type
end forward

global type n_generate_gen_file from n_generate_file_definition_base
end type
global n_generate_gen_file n_generate_gen_file

type variables
private:

constant string IS_TEMPLATE = '$PowerGenVersion=12&
~r~n$ProjectName="","powergen.log",1,""&
~r~n$DefaultApplication=""&
~r~n$DefaultLibrary=""&
~r~n$ApplicationName="@application.name",0,0,0,0,0,1357884061,0, 0&
~r~n$ApplicationLibrary="@application.library",0&
~r~n$EXEPath="@exe.path","",1,1&
~r~n$CodeSigning=&
~r~n$ICOPath="@ico.path"&
~r~n$PBRPath="@pbr.path"&
~r~n$PBDPath="",0,0&
~r~n$SourceControl="","","","",0,0'

constant string IS_LIBRARY_PBL = '~r~n$Library="@pbl","",0,2,0,"@pbg"'
constant string IS_LIBRARY_PBD = '~r~n$Library="@pbd","",1,1,0,""'
end variables

forward prototypes
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
protected function string get_dependecy_libraries_rows (readonly n_command_param an_param, readonly n_dependency_library an_libraries[])
protected function string get_dependecy_packages_rows (readonly n_command_param an_param, readonly n_dependency_package an_packages[])
private function boolean is_allow (readonly n_command_param an_param, readonly string as_scope)
end prototypes

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_template = IS_TEMPLATE

n_application_definition ln_application
ln_application = an_properties.get_application()
this.set_token(ref ls_template, "@application.name", ln_application.get_name())
this.set_token(ref ls_template, "@application.library", f_deploy().fix_dir(ln_application.get_library()))

n_deploy_definition ln_deploy
ln_deploy = an_properties.get_deploy()
this.set_token(ref ls_template, "@exe.path", f_deploy().fix_dir(ln_deploy.get_exe()))
this.set_token(ref ls_template, "@ico.path", f_deploy().fix_dir(ln_deploy.get_favicon()))
this.set_token(ref ls_template, "@pbr.path", f_deploy().fix_dir(ln_deploy.get_pbr()))

n_library ln_libraries[]
an_properties.get_libraries(ref ln_libraries)

int li_library
for li_library = 1 to upperbound(ln_libraries)
	n_library ln_library
	ln_library = ln_libraries[li_library]
	
	if this.is_allow(an_param, ln_library.get_scope()) then
		string ls_pb_library
		ls_pb_library = f_deploy().get_path(ln_library)
		
		string ls_extension
		ls_extension = lower(right(ls_pb_library, 3))

		string ls_library
		choose case ls_extension
			case "pbl"
				ls_library = IS_LIBRARY_PBL
				
				string ls_pbg
				ls_pbg = left(ls_pb_library, len(ls_pb_library) - 3) + "pbg"
				
				this.set_token(ref ls_library, "@pbl", f_deploy().fix_dir(ls_pb_library))
				this.set_token(ref ls_library, "@pbg", f_deploy().fix_dir(ls_pbg))
			case "pbd"
				ls_library = IS_LIBRARY_PBD
				this.set_token(ref ls_library, "@pbd", f_deploy().fix_dir(ls_pb_library))
			case else
				throw f_exception().exception("Unsuppported '" + ls_extension + "' library format")
		end choose
		
		ls_template += ls_library
	end if
next

n_dependency_definition ln_dependency_def
ln_dependency_def = an_properties.get_dependency()
if isvalid(ln_dependency_def) then
	n_dependency_library ln_dep_libraries[]
	ln_dependency_def.get_libraries(ref ln_dep_libraries)
	
	ls_template += this.get_dependecy_libraries_rows(an_param, ln_dep_libraries)
	
	n_dependency_package ln_dep_packages[]
	ln_dependency_def.get_packages(ref ln_dep_packages)
	
	ls_template += this.get_dependecy_packages_rows(an_param, ln_dep_packages)
end if

return ls_template
end function

protected function string get_dependecy_libraries_rows (readonly n_command_param an_param, readonly n_dependency_library an_libraries[]);string ls_template

int i
for i = 1 to upperbound(an_libraries)
	n_dependency_library ln_library
	ln_library = an_libraries[i]
	
	if f_string().equals(ln_library.get_type(), "pbd") then
		if this.is_allow(an_param, ln_library.get_scope()) then
			string ls_dependency
			ls_dependency = IS_LIBRARY_PBD
			
			string ls_pbd
			ls_pbd = f_deploy().get_path(ln_library)
			
			this.set_token(ref ls_dependency, "@pbd", f_deploy().fix_dir(ls_pbd))
			
			ls_template += ls_dependency
		end if
	end if
next

return ls_template
end function

protected function string get_dependecy_packages_rows (readonly n_command_param an_param, readonly n_dependency_package an_packages[]);string ls_template

int i
for i = 1 to upperbound(an_packages)
	n_dependency_package ln_package
	ln_package = an_packages[i]
	
	n_artifact ln_artifacts[]
	ln_package.get_artifacts(ref ln_artifacts)
	
	int li_artifact
	for li_artifact = 1 to upperbound(ln_artifacts)
		n_artifact ln_artifact
		ln_artifact = ln_artifacts[li_artifact]
		
		if f_string().equals(ln_artifact.get_type(), "pbd") then
			if this.is_allow(an_param, ln_artifact.get_scope()) then
				string ls_dependency
				ls_dependency = IS_LIBRARY_PBD
				
				string ls_pbd
				ls_pbd = f_deploy().get_path(ln_artifact, ln_package)
				
				this.set_token(ref ls_dependency, "@pbd", f_deploy().fix_dir(ls_pbd))
				
				ls_template += ls_dependency
			end if
		end if
	next
next

return ls_template
end function

private function boolean is_allow (readonly n_command_param an_param, readonly string as_scope);return (pos(an_param.get_name(), "release") > 0 and (as_scope = c_scope.IS_DEFAULT or as_scope = c_scope.IS_RUNTIME)) &
				or (pos(an_param.get_name(), "test") > 0 and not as_scope = c_scope.IS_DEV) &
				or (pos(an_param.get_name(), "dev") > 0 and not as_scope = c_scope.IS_RUNTIME)
end function

on n_generate_gen_file.create
call super::create
end on

on n_generate_gen_file.destroy
call super::destroy
end on

