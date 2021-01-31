$PBExportHeader$n_output_callback.sru
forward
global type n_output_callback from nonvisualobject
end type
end forward

global type n_output_callback from nonvisualobject
event log ( readonly string as_text )
end type
global n_output_callback n_output_callback

forward prototypes
public subroutine log (readonly string as_text)
end prototypes

event log(readonly string as_text);return
end event

public subroutine log (readonly string as_text);this.event log(as_text)

return
end subroutine

on n_output_callback.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_output_callback.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

