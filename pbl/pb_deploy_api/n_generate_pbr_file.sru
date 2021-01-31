$PBExportHeader$n_generate_pbr_file.sru
forward
global type n_generate_pbr_file from n_generate_file_definition_base
end type
end forward

global type n_generate_pbr_file from n_generate_file_definition_base
end type
global n_generate_pbr_file n_generate_pbr_file

type variables
private:

datastore ids_resources
end variables

forward prototypes
private subroutine get_files_by_path (readonly string as_path)
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
end prototypes

private subroutine get_files_by_path (readonly string as_path);listbox lb_container
lb_container = this.get_container()
lb_container.dirlist(this.get_folder() + as_path + "*.*", 16)

int li_index
string ls_folders[]

int i
for i = 1 to lb_container.totalitems()
	string ls_value
	ls_value = lb_container.text(i)
	if not ls_value = "[..]" then
		if f_string().starts_with(ls_value, "[") &
			and f_string().ends_with(ls_value, "]") then
			li_index ++
			ls_folders[li_index] = mid(ls_value, 2, len(ls_value) - 2)
		else
			long ll_row
			ll_row = ids_resources.insertrow(0)
			ids_resources.setitem(ll_row, "folder", as_path)
			ids_resources.setitem(ll_row, "name", ls_value)
			ids_resources.setitem(ll_row, "extension", f_file_factory().get_file_extension(ls_value))
		end if
	end if
next

for i = 1 to upperbound(ls_folders)
	this.get_files_by_path(as_path + ls_folders[i] + "\")
next

return
end subroutine

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_resources[]
if not an_properties.get_deploy().get_resources(ref ls_resources) > 0 then
	ls_resources = {"resources"}
end if

ids_resources = create datastore
ids_resources.dataobject = "d_resource_files"
ids_resources.reset()

int i
for i = 1 to upperbound(ls_resources)
	string ls_folder
	ls_folder = ls_resources[i]
	if not right(ls_folder, 1) = "\" then
		ls_folder += "\"
	end if
	this.get_files_by_path(ls_folder)
next

ids_resources.setfilter("lower(extension) in ('bmp', 'jpg', 'jpeg', 'ico', 'cur', 'gif')")
ids_resources.filter()
ids_resources.sort()

string ls_template
for i = 1 to ids_resources.rowcount()
	if len(ls_template) > 0 then
		ls_template += "~r~n"
	end if
	
	string ls_resource
	ls_resource = ids_resources.getitemstring(i, "folder")
	ls_resource += ids_resources.getitemstring(i, "name")
	if not left(ls_resource, 1) = "." then
		ls_resource = ".\" + ls_resource
	end if
	ls_template += f_deploy().fix_dir(ls_resource)
next

if ids_resources.rowcount() = 0 then
	this.log("No data for generate .pbr file.")
end if

return ls_template
end function

on n_generate_pbr_file.create
call super::create
end on

on n_generate_pbr_file.destroy
call super::destroy
end on

