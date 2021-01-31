$PBExportHeader$n_deploy_helper.sru
forward
global type n_deploy_helper from nonvisualobject
end type
end forward

global type n_deploy_helper from nonvisualobject
end type
global n_deploy_helper n_deploy_helper

forward prototypes
public function string get_path (readonly n_library an_library)
public function string fix_dir (readonly string as_dir)
public function string get_path (readonly n_dependency an_dependency)
public function string get_info (readonly n_dependency an_dependency)
public function string get_url (readonly n_dependency an_dependency)
public function string get_path (readonly n_artifact an_artifact, readonly n_dependency an_dependency)
public function string get_package_file (readonly n_artifact an_artifact, readonly n_dependency an_package)
public function string get_dir (readonly string as_file)
public function string get_info (readonly n_artifact an_artifact, readonly n_dependency an_dependency)
private function n_dependency create_clone (readonly n_dependency an_dependency, readonly n_artifact an_artifact)
public function string get_scope (readonly string as_scope) throws exception
end prototypes

public function string get_path (readonly n_library an_library);string ls_path
ls_path = an_library.get_dir()
if not f_string().is_empty(ls_path) then
	if not right(ls_path, 2) = "\\" then
		ls_path += "\\"
	end if
end if
ls_path += an_library.get_name()

return ls_path
end function

public function string fix_dir (readonly string as_dir);return f_string().replace_all(as_dir, "\\", "\")
end function

public function string get_path (readonly n_dependency an_dependency);string ls_file
ls_file = an_dependency.get_file()
if not f_string().is_empty(ls_file) then
	return ls_file
else
	string ls_dir
	ls_dir = an_dependency.get_dir()
	if not f_string().is_empty(ls_dir) then
		if not right(ls_dir, 1) = "\\" then
			ls_dir += "\\"
		end if
	end if
	
	string ls_group_id
	ls_group_id = an_dependency.get_group_id()
	
	string ls_artifact_path
	ls_artifact_path = right(ls_group_id, len(ls_group_id) - lastpos(ls_group_id, "."))
	ls_artifact_path += "\\" + an_dependency.get_artifact_id()
	ls_artifact_path += "\\" + an_dependency.get_version()
	ls_artifact_path += "\\"
	
	string ls_name
	ls_name = an_dependency.get_name()
	if f_string().is_empty(ls_name) then
		ls_name = an_dependency.get_artifact_id()
		ls_name += "-" + an_dependency.get_version()
		ls_name += "." + an_dependency.get_type()
	end if
	
	return ls_dir + ls_artifact_path + ls_name
end if
end function

public function string get_info (readonly n_dependency an_dependency);return an_dependency.get_group_id() + "@" &
		+ an_dependency.get_artifact_id() + "-" &
		+ an_dependency.get_version() + "." + &
		+ an_dependency.get_type()
end function

public function string get_url (readonly n_dependency an_dependency);string ls_url
ls_url = an_dependency.get_group_id() + "/" + an_dependency.get_artifact_id()
ls_url = f_string().replace_all(ls_url, ".", "/")
ls_url += "/" + an_dependency.get_version()
ls_url += "/" + an_dependency.get_artifact_id() + "-" + an_dependency.get_version()
ls_url += "." + an_dependency.get_type()

return ls_url
end function

public function string get_path (readonly n_artifact an_artifact, readonly n_dependency an_dependency);return this.get_path(this.create_clone(an_dependency, an_artifact))
end function

public function string get_package_file (readonly n_artifact an_artifact, readonly n_dependency an_package);string ls_dir
ls_dir = this.get_dir(this.get_path(an_package))
return ls_dir + "\\" + an_artifact.get_id() + "." + an_artifact.get_type()
end function

public function string get_dir (readonly string as_file);return left(as_file, lastpos(as_file, "\\") - 1)
end function

public function string get_info (readonly n_artifact an_artifact, readonly n_dependency an_dependency);return this.get_info(this.create_clone(an_dependency, an_artifact))
end function

private function n_dependency create_clone (readonly n_dependency an_dependency, readonly n_artifact an_artifact);n_dependency ln_clone
ln_clone = an_dependency.clone()
ln_clone.set_artifact_id(an_artifact.get_id()) &
		  .set_file(an_artifact.get_file()) &
		  .set_type(an_artifact.get_type()) &
		  .set_name(an_artifact.get_name())

if not f_string().is_empty(an_artifact.get_dir()) then
	ln_clone.set_dir(an_artifact.get_dir())
end if

return ln_clone
end function

public function string get_scope (readonly string as_scope) throws exception;string ls_scope
if f_string().is_empty(as_scope) then
	ls_scope = c_scope.IS_DEFAULT
else
	ls_scope = as_scope
end if

choose case ls_scope
	case c_scope.IS_DEFAULT &
		, c_scope.IS_TEST &
		, c_scope.IS_DEV &
		, c_scope.IS_RUNTIME
	case else
		throw f_exception().exception("Unsupported scope '" + ls_scope + "' value")
end choose

return ls_scope
end function

on n_deploy_helper.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_deploy_helper.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

