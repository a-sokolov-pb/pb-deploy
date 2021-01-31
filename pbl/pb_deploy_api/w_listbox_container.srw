$PBExportHeader$w_listbox_container.srw
forward
global type w_listbox_container from window
end type
type box from listbox within w_listbox_container
end type
end forward

global type w_listbox_container from window
boolean visible = false
integer width = 9
integer height = 80
boolean titlebar = true
string title = "ListBox container"
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
box box
end type
global w_listbox_container w_listbox_container

type variables
private:

int ii_index
string is_files[]
end variables

on w_listbox_container.create
this.box=create box
this.Control[]={this.box}
end on

on w_listbox_container.destroy
destroy(this.box)
end on

type box from listbox within w_listbox_container
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

