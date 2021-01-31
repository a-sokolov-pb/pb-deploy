$PBExportHeader$n_generate_ant_file.sru
forward
global type n_generate_ant_file from n_generate_file_definition_base
end type
end forward

global type n_generate_ant_file from n_generate_file_definition_base
end type
global n_generate_ant_file n_generate_ant_file

type variables
private:

constant string IS_TYPE_FOLDER = "disk"
constant string IS_TYPE_URL = "url"

constant string IS_TEMPLATE = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>&
~r~n<project name="pb-dependencies" basedir=".">&
~r~n    <!-- This is an ANT download dependencies file. -->&
~r~n	&
~r~n	<!-- Environment -->&
~r~n    <property environment="env" />&
~r~n	&
~r~n	<target name="download">&
~r~n		@dep.list&
~r~n	</target>&
~r~n</project>'

constant string IS_DEP_TEMPLATE_URL = '~r~n		&
~r~n		<mkdir dir="@dir" />&
~r~n		<echo>@artifact.info</echo>&
~r~n		<get @credentialssrc="@nexus.url@url"&
~r~n			dest="@file" />'

constant string IS_DEP_TEMPLATE_PACKAGE_URL = '~r~n		&
~r~n		<mkdir dir="${temp.dir}\\@dir" />&
~r~n		<echo>@artifact.info</echo>&
~r~n		<get @credentialssrc="@nexus.url@url"&
~r~n			dest="${temp.dir}\\@file" />'

constant string IS_CREDENTIALS = 'username="${nexus.login}"&
~r~n			password="${nexus.pass}"&
~r~n			'

constant string IS_DEP_TEMPLATE_FOLDER = '~r~n		&
~r~n		<mkdir dir="@dir" />&
~r~n		<echo>@artifact.info</echo>&
~r~n		<copy file="@nexus.url@url"&
~r~n			tofile="@file" />'

constant string IS_DEP_TEMPLATE_PACKAGE_FOLDER = '~r~n		&
~r~n		<mkdir dir="${temp.dir}\\@dir" />&
~r~n		<echo>@artifact.info</echo>&
~r~n		<copy file="@nexus.url@url"&
~r~n			tofile="${temp.dir}\\@file" />'

constant string IS_DEP_TEMPLATE_PACKAGE = '~r~n		<unzip src="${temp.dir}\\@file"&
~r~n			dest="${temp.dir}\\@zip.folder"&
~r~n			overwrite="true"&
~r~n		/>'

constant string IS_DEP_TEMPLATE_PACKAGE_DELETE = '~r~n		<delete dir="${temp.dir}\\@zip.folder" />'
constant string IS_DEP_TEMPLATE_COPY_ARTIFACT = '~r~n		<mkdir dir="@dir" />&
~r~n		<echo>@artifact.info</echo>&
~r~n		<move file="${temp.dir}\\@package.file"&
~r~n			tofile="@file" />'
end variables
forward prototypes
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
private function string get_packages_list (readonly n_dependency_definition an_dep_definition, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials)
private function string get_libraries_list (readonly n_dependency_definition an_dep_definition, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials)
private function string get_dependency_template (readonly n_dependency an_dependency, readonly string as_template, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials)
end prototypes

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_dep_list

n_dependency_definition ln_dep_definition
ln_dep_definition = an_properties.get_dependency()
if isvalid(ln_dep_definition) then
	string ls_repository_type = IS_TYPE_URL
	string ls_repository_url = "${nexus.url}"
	string ls_postfix
	
	n_repository ln_repository
	ln_repository = ln_dep_definition.get_repository()
	if isvalid(ln_repository) then
		ls_repository_type = ln_repository.get_type()
		ls_repository_url = ln_repository.get_value()
		
		choose case ls_repository_type
			case IS_TYPE_FOLDER
				if not right(ls_repository_url, 2) = "\\" then
					ls_repository_url += "\\"
				end if
			case IS_TYPE_URL
				if not right(ls_repository_url, 1) = "/" then
					ls_repository_url += "/"
				end if
		end choose
		
		if ls_repository_type = "" or ls_repository_type = IS_TYPE_URL then
			// postfix, только для типа {url}
			ls_postfix = ln_repository.get_postfix()
		end if
	end if
	
	ls_dep_list = this.get_libraries_list(ln_dep_definition &
													, ls_repository_type &
													, ls_repository_url &
													, ls_postfix &
													, ln_repository.get_credentials())
	ls_dep_list += this.get_packages_list(ln_dep_definition &
													, ls_repository_type &
													, ls_repository_url &
													, ls_postfix &
													, ln_repository.get_credentials())
end if

string ls_template = IS_TEMPLATE
this.set_token(ref ls_template, "@dep.list", ls_dep_list)

return ls_template
end function

private function string get_packages_list (readonly n_dependency_definition an_dep_definition, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials);string ls_template
choose case as_repository_type
	case IS_TYPE_FOLDER
		ls_template = IS_DEP_TEMPLATE_PACKAGE_FOLDER
	case else
		ls_template = IS_DEP_TEMPLATE_PACKAGE_URL
end choose

string ls_depependency_list

n_dependency_package ln_packages[]
an_dep_definition.get_packages(ref ln_packages)

int i
for i = 1 to upperbound(ln_packages)
	n_dependency_package ln_package
	ln_package = ln_packages[i]
	
	ls_depependency_list += this.get_dependency_template(ln_package &
													, ls_template &
													, as_repository_type &
													, as_repository_url &
													, as_postfix &
													, ab_credentials)

	string ls_file
	ls_file = f_deploy().get_path(ln_package)
	
	string ls_zip_folder
	ls_zip_folder = f_deploy().get_dir(ls_file)
	
	string ls_package
	ls_package = IS_DEP_TEMPLATE_PACKAGE
	this.set_token(ref ls_package, "@zip.folder", ls_zip_folder)
	this.set_token(ref ls_package, "@file", ls_file)
	
	ls_depependency_list += ls_package
	
	n_artifact ln_artifacts[]
	ln_package.get_artifacts(ref ln_artifacts)
	
	int li_artifact
	for li_artifact = 1 to upperbound(ln_artifacts)
		string ls_artifact
		ls_artifact = IS_DEP_TEMPLATE_COPY_ARTIFACT
		
		string ls_artifact_file
		ls_artifact_file = f_deploy().get_path(ln_artifacts[li_artifact], ln_package)
		
		string ls_artifact_dir
		ls_artifact_dir = f_deploy().get_dir(ls_artifact_file)
		
		string ls_package_file
		ls_package_file = f_deploy().get_package_file(ln_artifacts[li_artifact], ln_package)
		
		this.set_token(ref ls_artifact, "@dir", ls_artifact_dir)
		this.set_token(ref ls_artifact, "@package.file", ls_package_file)
		this.set_token(ref ls_artifact, "@file", ls_artifact_file)
		this.set_token(ref ls_artifact, "@artifact.info", f_deploy().get_info(ln_artifacts[li_artifact], ln_package))
		
		ls_depependency_list += ls_artifact
	next
	
	string ls_delete_package
	ls_delete_package = IS_DEP_TEMPLATE_PACKAGE_DELETE
	this.set_token(ref ls_delete_package, "@zip.folder", ls_zip_folder)
	
	ls_depependency_list += ls_delete_package
next

return ls_depependency_list
end function

private function string get_libraries_list (readonly n_dependency_definition an_dep_definition, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials);string ls_template
choose case as_repository_type
	case IS_TYPE_FOLDER
		ls_template = IS_DEP_TEMPLATE_FOLDER
	case else
		ls_template = IS_DEP_TEMPLATE_URL
end choose

string ls_dependency_list

n_dependency_library ln_libraries[]
an_dep_definition.get_libraries(ref ln_libraries)

int i
for i = 1 to upperbound(ln_libraries)
	ls_dependency_list += this.get_dependency_template(ln_libraries[i] &
													, ls_template &
													, as_repository_type &
													, as_repository_url &
													, as_postfix &
													, ab_credentials)
next

return ls_dependency_list
end function

private function string get_dependency_template (readonly n_dependency an_dependency, readonly string as_template, readonly string as_repository_type, readonly string as_repository_url, readonly string as_postfix, readonly boolean ab_credentials);string ls_url
ls_url = f_deploy().get_url(an_dependency)

string ls_file
ls_file = f_deploy().get_path(an_dependency)

string ls_dir
ls_dir = f_deploy().get_dir(ls_file)

if as_repository_type = IS_TYPE_FOLDER then
	ls_url = f_string().replace_all(ls_url, "/", "\\")
end if

string ls_artifact_info
ls_artifact_info = f_deploy().get_info(an_dependency)

string ls_template
ls_template = as_template

this.set_token(ref ls_template, "@dir", ls_dir)
this.set_token(ref ls_template, "@url", ls_url + as_postfix)
this.set_token(ref ls_template, "@file", ls_file)
this.set_token(ref ls_template, "@nexus.url", as_repository_url)
this.set_token(ref ls_template, "@artifact.info", ls_artifact_info)
if ab_credentials then
	this.set_token(ref ls_template, "@credentials", IS_CREDENTIALS)
else
	this.set_token(ref ls_template, "@credentials", "")
end if

return ls_template
end function

on n_generate_ant_file.create
call super::create
end on

on n_generate_ant_file.destroy
call super::destroy
end on

