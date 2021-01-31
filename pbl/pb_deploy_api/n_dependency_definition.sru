$PBExportHeader$n_dependency_definition.sru
forward
global type n_dependency_definition from nonvisualobject
end type
end forward

global type n_dependency_definition from nonvisualobject
end type
global n_dependency_definition n_dependency_definition

type variables
private:

string is_dir
n_repository in_repository
n_dependency_library in_libraries[]
n_dependency_package in_packages[]

n_artifact in_empty[]
end variables

forward prototypes
public subroutine parse (readonly n_json_parser an_json) throws exception
public function integer get_libraries (ref n_dependency_library an_libraries[])
public function integer get_packages (ref n_dependency_package an_packages[])
public function string get_dir ()
public function n_repository get_repository ()
private subroutine set_libraries (readonly n_json_parser an_json) throws exception
private subroutine set_packages (readonly n_json_parser an_json) throws exception
end prototypes

public subroutine parse (readonly n_json_parser an_json) throws exception;is_dir = an_json.get_attribute("dir")

n_json_attribute ln_repository_attr
ln_repository_attr = an_json.get_item("repository")
if ln_repository_attr.is_exists() then
	in_repository = create n_repository
	if ln_repository_attr.is_exists("type") &
		and ln_repository_attr.is_exists("value") then
		in_repository.set_type(ln_repository_attr.get_string_value("type")) &
						 .set_value(ln_repository_attr.get_string_value("value"))
	end if
	if ln_repository_attr.is_exists("postfix") then
		in_repository.set_postfix(ln_repository_attr.get_string_value("postfix"))
	end if
	if ln_repository_attr.is_exists("credentials") then
		in_repository.set_credentials(ln_repository_attr.get_boolean_value("credentials"))
	end if
end if

if an_json.is_attribute_exists("libraries") then
	this.set_libraries(an_json)
end if

if an_json.is_attribute_exists("packages") then
	this.set_packages(an_json)
end if

return
end subroutine

public function integer get_libraries (ref n_dependency_library an_libraries[]);an_libraries = in_libraries

return upperbound(an_libraries)
end function

public function integer get_packages (ref n_dependency_package an_packages[]);an_packages = in_packages

return upperbound(an_packages)
end function

public function string get_dir ();return is_dir
end function

public function n_repository get_repository ();return in_repository
end function

private subroutine set_libraries (readonly n_json_parser an_json) throws exception;n_json_parser ln_libraries
ln_libraries = an_json.get_attribute("libraries")

string ls_libraries_pairs_name[]
ln_libraries.get_pairs_name(ref ls_libraries_pairs_name)

int li_lib
for li_lib = 1 to upperbound(ls_libraries_pairs_name)
	string ls_library_definition
	ls_library_definition = ls_libraries_pairs_name[li_lib]
	
	n_json_attribute ln_library_attr
	ln_library_attr = ln_libraries.get_item(ls_library_definition)
	
	string ls_version
	string ls_file
	string ls_type
	string ls_dir
	string ls_name
	string ls_scope
	
	ls_scope = ""
	ls_file = ""
	ls_type = ""
	ls_dir = ""
	ls_name = ""

	if ln_library_attr.is_object() then
		ls_version = ln_library_attr.get_string_value("version")
		if ln_library_attr.is_exists("type") then
			ls_type = ln_library_attr.get_string_value("type")
		end if
		if ln_library_attr.is_exists("dir") then
			ls_dir = ln_library_attr.get_string_value("dir")
		end if
		if ln_library_attr.is_exists("scope") then
			ls_scope = ln_library_attr.get_string_value("scope")
		end if
		if ln_library_attr.is_exists("file") then
			ls_file = ln_library_attr.get_string_value("file")
		end if
		if ln_library_attr.is_exists("name") then
			ls_name = ln_library_attr.get_string_value("name")
		end if
	else
		string ls_temp
		ls_temp = ln_library_attr.get_value()
		if pos(ls_temp, "@") > 0 then
			ls_version = f_string().left_part(ls_temp, "@")
			ls_file = f_string().right_part(ls_temp, "@")
		else
			ls_version = ls_temp
		end if
	end if
	
	if f_string().is_empty(ls_type) then
		ls_type = "pbd"
	end if
	if f_string().is_empty(ls_dir) then
		ls_dir = is_dir
	end if
	if ls_dir = "." then
		ls_dir = ".\\"
	end if
	
	string ls_group_id
	string ls_artifact_id
	ls_group_id = f_string().left_part(ls_library_definition, "@")
	ls_artifact_id = f_string().right_part(ls_library_definition, "@")
	
	in_libraries[li_lib] = create n_dependency_library
	in_libraries[li_lib].set_group_id(ls_group_id) &
										.set_artifact_id(ls_artifact_id) &
										.set_type(ls_type) &
										.set_version(ls_version) &
										.set_dir(ls_dir) &
										.set_scope(f_deploy().get_scope(ls_scope)) &
										.set_file(ls_file) &
										.set_name(ls_name)
next

return
end subroutine

private subroutine set_packages (readonly n_json_parser an_json) throws exception;n_json_parser ln_packages
ln_packages = an_json.get_attribute("packages")

string ls_packages_pairs_name[]
ln_packages.get_pairs_name(ref ls_packages_pairs_name)

int li_pac
for li_pac = 1 to upperbound(ls_packages_pairs_name)
	string ls_package_definition
	ls_package_definition = ls_packages_pairs_name[li_pac]
	
	n_json_attribute ln_package_attr
	ln_package_attr = ln_packages.get_item(ls_package_definition)
	
	string ls_version
	string ls_dir
	string ls_scope
	
	ls_dir = ""
	ls_scope = ""
	
	ls_version = ln_package_attr.get_string_value("version")
	if ln_package_attr.is_exists("dir") then
		ls_dir = ln_package_attr.get_string_value("dir")
	end if
	if ln_package_attr.is_exists("scope") then
		ls_scope = ln_package_attr.get_string_value("scope")
	end if

	if f_string().is_empty(ls_dir) then
		ls_dir = is_dir
	end if
	if ls_dir = "." then
		ls_dir = ".\\"
	end if
	
	string ls_package_group_id
	string ls_package_artifact_id
	ls_package_group_id = f_string().left_part(ls_package_definition, "@")
	ls_package_artifact_id = f_string().right_part(ls_package_definition, "@")
	
	in_packages[li_pac] = create n_dependency_package
	in_packages[li_pac].set_group_id(ls_package_group_id) &
										.set_artifact_id(ls_package_artifact_id) &
										.set_type("zip") &
										.set_version(ls_version) &
										.set_dir(ls_dir) &
										.set_scope(f_deploy().get_scope(ls_scope))
										
	if ln_package_attr.is_exists("artifacts") then
		n_json_parser ln_artifacts_json
		ln_artifacts_json = ln_package_attr.get_value("artifacts")
		
		string ls_artifact_pair_names[]
		ln_artifacts_json.get_pairs_name(ref ls_artifact_pair_names)
		
		n_artifact ln_artifacts[]
		ln_artifacts = in_empty
		
		int li_artifact
		for li_artifact = 1 to upperbound(ls_artifact_pair_names)
			string ls_artifact_id
			ls_artifact_id = ls_artifact_pair_names[li_artifact]
			
			n_json_attribute ln_artifact_attr
			ln_artifact_attr = ln_artifacts_json.get_item(ls_artifact_id)
			
			ln_artifacts[li_artifact] = create n_artifact
			
			string ls_artifact_file
			string ls_artifact_dir
			string ls_artifact_scope
			string ls_artifact_type
			string ls_artifact_name
			
			ls_artifact_dir = ""
			ls_artifact_scope = ""
			ls_artifact_file = ""
			ls_artifact_name = ""
			if ln_artifact_attr.is_object() then
				if ln_artifact_attr.is_exists("file") then
					ls_artifact_file = ln_artifact_attr.get_string_value("file")
				end if
				if ln_artifact_attr.is_exists("dir") then
					ls_artifact_dir = ln_artifact_attr.get_string_value("dir")
				end if
				if ln_artifact_attr.is_exists("scope") then
					ls_artifact_scope = ln_artifact_attr.get_string_value("scope")
				end if
				if ln_artifact_attr.is_exists("name") then
					ls_artifact_name = ln_artifact_attr.get_string_value("name")
				end if
				ls_artifact_type = ln_artifact_attr.get_string_value("type")
			else
				ls_artifact_type = string(ln_artifact_attr.get_value())
			end if
			ln_artifacts[li_artifact].set_file(ls_artifact_file) &
							     .set_dir(ls_artifact_dir) &
								  .set_scope(f_deploy().get_scope(ls_artifact_scope)) &
								  .set_id(ls_artifact_id) &
								  .set_type(ls_artifact_type) &
								  .set_name(ls_artifact_name)
		next
		
		in_packages[li_pac].set_artifacts(ln_artifacts)
	end if
next

return
end subroutine

on n_dependency_definition.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_dependency_definition.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

