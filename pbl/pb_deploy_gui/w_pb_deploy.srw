$PBExportHeader$w_pb_deploy.srw
forward
global type w_pb_deploy from window
end type
type dw_log from datawindow within w_pb_deploy
end type
type shl_log from statichyperlink within w_pb_deploy
end type
type shl_genenerate from statichyperlink within w_pb_deploy
end type
type st_select from statictext within w_pb_deploy
end type
type dw_deploy_params from datawindow within w_pb_deploy
end type
type shl_get_json from statichyperlink within w_pb_deploy
end type
type tv_json from treeview within w_pb_deploy
end type
type ddplb_json from dropdownpicturelistbox within w_pb_deploy
end type
type n_pb_deploy_gui_output_callback from n_output_callback within w_pb_deploy
end type
end forward

global type w_pb_deploy from window
integer width = 2528
integer height = 1748
boolean titlebar = true
string title = "Untitled"
string menuname = "m_pb_deploy"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
dw_log dw_log
shl_log shl_log
shl_genenerate shl_genenerate
st_select st_select
dw_deploy_params dw_deploy_params
shl_get_json shl_get_json
tv_json tv_json
ddplb_json ddplb_json
n_pb_deploy_gui_output_callback n_pb_deploy_gui_output_callback
end type
global w_pb_deploy w_pb_deploy

type variables
private:

int ii_root_index
int ii_object_index
int ii_array_index
int ii_element_index

int ii_json_picture_index

constant string IS_SECTION = "HKEY_CURRENT_USER\Software\PBDeploymentAPI"
constant string IS_LAST_JSON_FILE = "LastJSONFile"
constant string IS_JSON_FILES_LIST = "JSONFilesList"
end variables

forward prototypes
private subroutine build_json_tree (readonly string as_json_path) throws exception
private subroutine generate_files () throws exception
private subroutine set_log_visible (readonly boolean ab_switch)
private subroutine add_json_file (readonly string as_file_path)
private subroutine show_file_data (readonly string as_file_path) throws exception
end prototypes

private subroutine build_json_tree (readonly string as_json_path) throws exception;try
	tv_json.setredraw(false)

	do while tv_json.finditem(roottreeitem!, 0) > 0
		tv_json.deleteitem(tv_json.finditem(roottreeitem!, 0))
	loop
	
	n_json_parser ln_json
	ln_json = create n_json_parser
	ln_json.parse(f_file_factory().read_file_data(as_json_path))
	
	long ll_root_index
	ll_root_index = tv_json.insertitemfirst(0, this.title, ii_root_index) 
	
	ln_json.build_tree(tv_json, ll_root_index, ii_object_index, ii_array_index, ii_element_index)
	tv_json.selectitem(ll_root_index)
	tv_json.expanditem(ll_root_index)
finally
	tv_json.setredraw(true)	
end try

return
end subroutine

private subroutine generate_files () throws exception;this.set_log_visible(false)

if f_string().is_empty(ddplb_json.text) then
	ddplb_json.setfocus()
	throw f_exception().exception("JSON file must be specified!")
end if

dw_deploy_params.accepttext()
if not dw_deploy_params.find("selected = 1", 0 &
     , dw_deploy_params.rowcount()) > 0 then
	dw_deploy_params.setfocus()
	throw f_exception().exception("Deploy params must be specified!")
end if

this.set_log_visible(true)
dw_log.reset()

string ls_command_line
ls_command_line = "deploy /config.file=" + ddplb_json.text

long ll_row
for ll_row = 1 to dw_deploy_params.rowcount()
	if dw_deploy_params.getitemnumber(ll_row, "selected") = 1 then
		
		ls_command_line += " " + dw_deploy_params.getitemstring(ll_row, "param_name")
		
		string ls_value
		ls_value = trim(dw_deploy_params.getitemstring(ll_row, "param_value"))
		if len(ls_value) > 0 then
			ls_command_line += "=" + ls_value
		end if
	end if
next

n_pb_deploy_manager ln_deploy_manager
ln_deploy_manager = create n_pb_deploy_manager
ln_deploy_manager.set_output(n_pb_deploy_gui_output_callback)
ln_deploy_manager.start(trim(ls_command_line))

return
end subroutine

private subroutine set_log_visible (readonly boolean ab_switch);constant string LS_SHOW_LOG = "show log"
constant string LS_HIDE_LOG = "hide log"

if ab_switch then
	shl_log.text = LS_HIDE_LOG
else
	shl_log.text = LS_SHOW_LOG
end if

dw_log.visible = ab_switch

return
end subroutine

private subroutine add_json_file (readonly string as_file_path);int li_index
li_index = ddplb_json.finditem(as_file_path, 0)
if not li_index > 0 then
	li_index = ddplb_json.additem(as_file_path, ii_json_picture_index)
end if

ddplb_json.selectitem(li_index)
ddplb_json.event selectionchanged(li_index)

string ls_json_files[]

int i
for i = 1 to ddplb_json.totalitems()
	ls_json_files[i] = ddplb_json.text(i)
next

registryset(IS_SECTION, IS_JSON_FILES_LIST, f_string().join(ls_json_files, "~t"))

return
end subroutine

private subroutine show_file_data (readonly string as_file_path) throws exception;f_pb_addon().run_command(as_file_path)

return
end subroutine

on w_pb_deploy.create
if this.MenuName = "m_pb_deploy" then this.MenuID = create m_pb_deploy
this.dw_log=create dw_log
this.shl_log=create shl_log
this.shl_genenerate=create shl_genenerate
this.st_select=create st_select
this.dw_deploy_params=create dw_deploy_params
this.shl_get_json=create shl_get_json
this.tv_json=create tv_json
this.ddplb_json=create ddplb_json
this.n_pb_deploy_gui_output_callback=create n_pb_deploy_gui_output_callback
this.Control[]={this.dw_log,&
this.shl_log,&
this.shl_genenerate,&
this.st_select,&
this.dw_deploy_params,&
this.shl_get_json,&
this.tv_json,&
this.ddplb_json}
end on

on w_pb_deploy.destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.dw_log)
destroy(this.shl_log)
destroy(this.shl_genenerate)
destroy(this.st_select)
destroy(this.dw_deploy_params)
destroy(this.shl_get_json)
destroy(this.tv_json)
destroy(this.ddplb_json)
destroy(this.n_pb_deploy_gui_output_callback)
end on

event open;this.title = getapplication().displayname

ii_root_index = tv_json.addpicture(this.icon)
ii_object_index = tv_json.addpicture(".\assets\node.ico")
ii_array_index = tv_json.addpicture(".\assets\tree.ico")
ii_element_index = tv_json.addpicture("VCRNext!")

string ls_keys[] = {"/get:test", "/gen:dev", "/gen:release" &
                  , "/pbt", "/pbw", "/pbr", "/ant:dependencies" &
						, "/ant:properties"}

int i
for i = 1 to upperbound(ls_keys)
	long ll_row
	ll_row = dw_deploy_params.insertrow(0)
	dw_deploy_params.setitem(ll_row, "param_name", ls_keys[i])
	choose case ls_keys[i]
		case "/pbt", "/pbw"
			//
		case else
			dw_deploy_params.setitem(ll_row, "selected", 1)
	end choose
next

ii_json_picture_index = ddplb_json.addpicture(".\assets\json.ico")

string ls_temp
registryget(IS_SECTION, IS_JSON_FILES_LIST, ref ls_temp)

if not f_string().is_empty(ls_temp) then
	string ls_json_files[]
	f_string().split(ls_temp, "~t", ref ls_json_files)
	
	for i = 1 to upperbound(ls_json_files)
		ddplb_json.additem(ls_json_files[i], ii_json_picture_index)
	next
end if

string ls_last_json_file
registryget(IS_SECTION, IS_LAST_JSON_FILE, ref ls_last_json_file)

int li_index
li_index = ddplb_json.finditem(ls_last_json_file, 0)
if li_index > 0 then
	ddplb_json.selectitem(li_index)
	ddplb_json.event selectionchanged(li_index)
end if

this.resize(pixelstounits(800, xpixelstounits!) &
          , pixelstounits(600, ypixelstounits!))

return
end event

event resize;if not sizetype = 1 then
	constant int GAP = 20
	
	ddplb_json.width = newwidth - ddplb_json.x - tv_json.x
	tv_json.width = newwidth - tv_json.x * 2
	dw_deploy_params.width = newwidth - dw_deploy_params.x * 2
	shl_genenerate.y = newheight - shl_genenerate.height - GAP
	shl_log.y = shl_genenerate.y
	dw_deploy_params.y = shl_log.y - dw_deploy_params.height - GAP
	st_select.y = dw_deploy_params.y - st_select.height - GAP
	tv_json.height = st_select.y - tv_json.y - GAP
	dw_log.move(dw_deploy_params.x, dw_deploy_params.y)
	dw_log.resize(dw_deploy_params.width, dw_deploy_params.height)
end if

return
end event

type dw_log from datawindow within w_pb_deploy
boolean visible = false
integer x = 14
integer y = 688
integer width = 2455
integer height = 780
integer taborder = 50
string title = "Deploy log"
string dataobject = "d_deploy_log"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event clicked;if row > 0 then
	string ls_file
	ls_file = this.getitemstring(row, "file")
	if len(ls_file) > 0 then
		try
			setpointer(hourglass!)
			
			parent.show_file_data(ls_file)
		catch (exception err)
			messagebox(parent.title, err.getmessage(), stopsign!)
		finally
			setpointer(arrow!)
		end try
	end if
end if

return
end event

type shl_log from statichyperlink within w_pb_deploy
integer x = 416
integer y = 1472
integer width = 215
integer height = 52
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "show log"
boolean focusrectangle = false
end type

event clicked;parent.set_log_visible(not dw_log.visible)

return
end event

type shl_genenerate from statichyperlink within w_pb_deploy
integer x = 23
integer y = 1476
integer width = 370
integer height = 52
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "Generate files..."
boolean focusrectangle = false
boolean disabledlook = true
end type

event clicked;try
	setpointer(hourglass!)
	
	parent.generate_files()
catch (exception err)
	messagebox(parent.title, err.getmessage(), stopsign!)
finally
	setpointer(arrow!)
end try

return
end event

type st_select from statictext within w_pb_deploy
integer x = 55
integer y = 624
integer width = 645
integer height = 52
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Choose Deploy params:"
boolean focusrectangle = false
end type

type dw_deploy_params from datawindow within w_pb_deploy
integer x = 14
integer y = 688
integer width = 2455
integer height = 780
integer taborder = 30
string title = "Deploy params"
string dataobject = "d_deploy_params"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type shl_get_json from statichyperlink within w_pb_deploy
integer x = 23
integer y = 32
integer width = 302
integer height = 56
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "get JSON file"
boolean focusrectangle = false
end type

event clicked;string ls_current_folder
ls_current_folder = getcurrentdirectory()

string ls_json_path

try
	string ls_file_name
	if not getfileopenname("Choose build.package.json file" &
						  , ref ls_json_path &
						  , ref ls_file_name &
						  , "json", "JSON (*.json), *.json") = 1 then
		return
	end if
finally
	changedirectory(ls_current_folder)
end try

if not f_string().equals(ls_file_name, "build.package.json") then
	messagebox("Warning" &
			   , "Can only specified 'build.package.json' file!" &
				, exclamation!)
	return
end if

parent.add_json_file(ls_json_path)

return
end event

type tv_json from treeview within w_pb_deploy
integer x = 9
integer y = 124
integer width = 2455
integer height = 488
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean hideselection = false
boolean trackselect = true
boolean fullrowselect = true
long picturemaskcolor = 12632256
long statepicturemaskcolor = 536870912
end type

type ddplb_json from dropdownpicturelistbox within w_pb_deploy
integer x = 334
integer y = 20
integer width = 2135
integer height = 892
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
string item[] = {""}
borderstyle borderstyle = stylelowered!
integer itempictureindex[] = {0}
long picturemaskcolor = 536870912
end type

event selectionchanged;if not index > 0 then
	return
end if

string ls_json_path
ls_json_path = this.text(index)
registryset(IS_SECTION, IS_LAST_JSON_FILE, ls_json_path)

try
	setpointer(hourglass!)
	
	parent.build_json_tree(ls_json_path)
catch (exception err)
	messagebox(parent.title, err.getmessage(), stopsign!)
finally
	setpointer(arrow!)
end try

return
end event

type n_pb_deploy_gui_output_callback from n_output_callback within w_pb_deploy descriptor "pb_nvo" = "true" 
end type

on n_pb_deploy_gui_output_callback.create
call super::create
end on

on n_pb_deploy_gui_output_callback.destroy
call super::destroy
end on

event log;call super::log;long ll_row
ll_row = dw_log.insertrow(0)
dw_log.setitem(ll_row, "text", as_text)

string ls_file
if pos(as_text, "Generated '") > 0 then
	ls_file = f_string().between(as_text, "Generated '", "' file data")
end if

dw_log.setitem(ll_row, "file", ls_file)

dw_log.scrolltorow(ll_row)

return
end event

