$PBExportHeader$w_about.srw
forward
global type w_about from window
end type
type st_info from statictext within w_about
end type
type p_logo from picture within w_about
end type
type cb_default from commandbutton within w_about
end type
type st_line from statictext within w_about
end type
end forward

global type w_about from window
integer width = 1801
integer height = 1600
boolean titlebar = true
string title = "About"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_info st_info
p_logo p_logo
cb_default cb_default
st_line st_line
end type
global w_about w_about

on w_about.create
this.st_info=create st_info
this.p_logo=create p_logo
this.cb_default=create cb_default
this.st_line=create st_line
this.Control[]={this.st_info,&
this.p_logo,&
this.cb_default,&
this.st_line}
end on

on w_about.destroy
destroy(this.st_info)
destroy(this.p_logo)
destroy(this.cb_default)
destroy(this.st_line)
end on

event open;this.title = "About " + getapplication().displayname
st_info.text = "Application for generate PowerBuilder 9.0 deployment environment."
st_info.text += "~r~n~r~nAuthor, Sokolov A.V. 2020"

p_logo.picturename = ".\assets\logo.jpg"

return
end event

event resize;if not sizetype = 1 then
	cb_default.move(newwidth - cb_default.width - pixelstounits(5, xpixelstounits!) &
	              , newheight - cb_default.height - pixelstounits(5, ypixelstounits!))
end if

return
end event

type st_info from statictext within w_about
integer x = 41
integer y = 572
integer width = 1701
integer height = 792
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type p_logo from picture within w_about
integer width = 1920
integer height = 472
string picturename = ".\assets\logo.jpg"
boolean focusrectangle = false
end type

type cb_default from commandbutton within w_about
integer x = 1426
integer y = 1416
integer width = 343
integer height = 92
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Œ "
boolean cancel = true
boolean default = true
end type

event clicked;close(parent)

return
end event

type st_line from statictext within w_about
integer y = 468
integer width = 1847
integer height = 52
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 15780518
boolean focusrectangle = false
end type

