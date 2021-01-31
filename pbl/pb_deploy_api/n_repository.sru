$PBExportHeader$n_repository.sru
forward
global type n_repository from nonvisualobject
end type
end forward

global type n_repository from nonvisualobject
end type
global n_repository n_repository

type variables
private:

string is_type
string is_value
string is_postfix
boolean ib_credentials = true
end variables
forward prototypes
public function string get_type ()
public function string get_value ()
public function n_repository set_type (readonly string as_type)
public function n_repository set_value (readonly string as_value)
public function string get_postfix ()
public subroutine set_postfix (readonly string as_postfix)
public function boolean get_credentials ()
public subroutine set_credentials (readonly boolean ab_credentials)
end prototypes

public function string get_type ();return is_type
end function

public function string get_value ();return is_value
end function

public function n_repository set_type (readonly string as_type);is_type = as_type

return this
end function

public function n_repository set_value (readonly string as_value);is_value = as_value

return this
end function

public function string get_postfix ();return is_postfix
end function

public subroutine set_postfix (readonly string as_postfix);is_postfix = as_postfix

return
end subroutine

public function boolean get_credentials ();return ib_credentials
end function

public subroutine set_credentials (readonly boolean ab_credentials);ib_credentials = ab_credentials

return
end subroutine

on n_repository.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_repository.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

