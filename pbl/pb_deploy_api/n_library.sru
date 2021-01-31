$PBExportHeader$n_library.sru
forward
global type n_library from nonvisualobject
end type
end forward

global type n_library from nonvisualobject
end type
global n_library n_library

type variables
private:

string is_order
string is_name
string is_dir
string is_scope
end variables
forward prototypes
public function string get_name ()
public function n_library set_name (readonly string as_name)
public function n_library set_dir (readonly string as_dir)
public function string get_dir ()
public function string get_scope ()
public function n_library set_scope (readonly string as_scope)
public function string get_order ()
public function n_library set_order (readonly string as_order)
end prototypes

public function string get_name ();return is_name
end function

public function n_library set_name (readonly string as_name);is_name = as_name

return this
end function

public function n_library set_dir (readonly string as_dir);is_dir = as_dir

return this
end function

public function string get_dir ();return is_dir
end function

public function string get_scope ();return is_scope
end function

public function n_library set_scope (readonly string as_scope);is_scope = as_scope

return this
end function

public function string get_order ();return is_order
end function

public function n_library set_order (readonly string as_order);is_order = as_order

return this
end function

on n_library.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_library.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

