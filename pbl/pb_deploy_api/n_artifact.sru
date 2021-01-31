$PBExportHeader$n_artifact.sru
forward
global type n_artifact from nonvisualobject
end type
end forward

global type n_artifact from nonvisualobject
end type
global n_artifact n_artifact

type variables
private:

string is_id
string is_type
string is_file
string is_dir
string is_scope
string is_name
end variables

forward prototypes
public function string get_dir ()
public function n_artifact set_dir (readonly string as_dir)
public function string get_scope ()
public function n_artifact set_scope (readonly string as_scope)
public function string get_id ()
public function n_artifact set_id (readonly string as_id)
public function n_artifact set_file (readonly string as_file)
public function string get_file ()
public function string get_type ()
public function n_artifact set_type (readonly string as_type)
public function string get_name ()
public function n_artifact set_name (readonly string as_name)
end prototypes

public function string get_dir ();return is_dir
end function

public function n_artifact set_dir (readonly string as_dir);is_dir = as_dir

return this
end function

public function string get_scope ();return is_scope
end function

public function n_artifact set_scope (readonly string as_scope);is_scope = as_scope

return this
end function

public function string get_id ();return is_id
end function

public function n_artifact set_id (readonly string as_id);is_id = as_id

return this
end function

public function n_artifact set_file (readonly string as_file);is_file = as_file

return this
end function

public function string get_file ();return is_file
end function

public function string get_type ();return is_type
end function

public function n_artifact set_type (readonly string as_type);is_type = as_type

return this
end function

public function string get_name ();return is_name
end function

public function n_artifact set_name (readonly string as_name);is_name = as_name

return this
end function

on n_artifact.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_artifact.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

