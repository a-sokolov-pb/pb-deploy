$PBExportHeader$n_dependency.sru
forward
global type n_dependency from nonvisualobject
end type
end forward

global type n_dependency from nonvisualobject
end type
global n_dependency n_dependency

type variables
private:

string is_group_id
string is_artifact_id
string is_type
string is_version
string is_dir
string is_scope
string is_file
string is_name
end variables

forward prototypes
public function string get_group_id ()
public function string get_artifact_id ()
public function string get_type ()
public function string get_dir ()
public function string get_version ()
public function n_dependency set_group_id (readonly string as_group_id)
public function n_dependency set_artifact_id (readonly string as_artifact_id)
public function n_dependency set_type (readonly string as_type)
public function n_dependency set_dir (readonly string as_dir)
public function n_dependency set_version (readonly string as_version)
public function string get_file ()
public function n_dependency set_file (readonly string as_file)
public function string get_scope ()
public function n_dependency set_scope (readonly string as_scope)
public function n_dependency clone ()
public function string get_name ()
public function n_dependency set_name (readonly string as_name)
end prototypes

public function string get_group_id ();return is_group_id
end function

public function string get_artifact_id ();return is_artifact_id
end function

public function string get_type ();return is_type
end function

public function string get_dir ();return is_dir
end function

public function string get_version ();return is_version
end function

public function n_dependency set_group_id (readonly string as_group_id);is_group_id = as_group_id

return this
end function

public function n_dependency set_artifact_id (readonly string as_artifact_id);is_artifact_id = as_artifact_id

return this
end function

public function n_dependency set_type (readonly string as_type);is_type = as_type

return this
end function

public function n_dependency set_dir (readonly string as_dir);is_dir = as_dir

return this
end function

public function n_dependency set_version (readonly string as_version);is_version = as_version

return this
end function

public function string get_file ();return is_file
end function

public function n_dependency set_file (readonly string as_file);is_file = as_file

return this
end function

public function string get_scope ();return is_scope
end function

public function n_dependency set_scope (readonly string as_scope);is_scope = as_scope

return this
end function

public function n_dependency clone ();n_dependency ln_clone
ln_clone = create n_dependency

ln_clone.is_group_id = this.is_group_id
ln_clone.is_artifact_id = this.is_artifact_id
ln_clone.is_type = this.is_type
ln_clone.is_version = this.is_version
ln_clone.is_dir = this.is_dir
ln_clone.is_scope = this.is_scope
ln_clone.is_file = this.is_file
ln_clone.is_name = this.is_name

return ln_clone
end function

public function string get_name ();return is_name
end function

public function n_dependency set_name (readonly string as_name);is_name = as_name

return this
end function

on n_dependency.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_dependency.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

