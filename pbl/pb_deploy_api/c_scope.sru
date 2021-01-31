$PBExportHeader$c_scope.sru
forward
global type c_scope from nonvisualobject
end type
end forward

global type c_scope from nonvisualobject
end type
global c_scope c_scope

type variables
public:

constant string IS_DEFAULT = "default"
constant string IS_TEST = "test"
constant string IS_RUNTIME = "runtime"
constant string IS_DEV = "dev"
end variables
on c_scope.create
call super::create
TriggerEvent( this, "constructor" )
end on

on c_scope.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

