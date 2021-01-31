$PBExportHeader$n_build_properties.sru
forward
global type n_build_properties from nonvisualobject
end type
end forward

global type n_build_properties from nonvisualobject
end type
global n_build_properties n_build_properties

type variables
private:

string is_name
string is_version
string is_description
n_application_definition in_application
n_deploy_definition in_deploy
n_dependency_definition in_dependency
n_test_definition in_test
n_library in_libraries[]
n_ant_property in_ant_properties[]
end variables

forward prototypes
public subroutine set_file (readonly string as_properties_file) throws exception
public function string get_name ()
public function string get_version ()
public function string get_description ()
public function n_application_definition get_application ()
public function n_deploy_definition get_deploy ()
public function integer get_libraries (ref n_library an_libraries[])
public function integer get_ant_properties (ref n_ant_property an_ant_properties[])
private subroutine set_ant_properties (readonly n_json_parser an_json) throws exception
private subroutine set_libraries (readonly n_json_parser an_json) throws exception
public function n_test_definition get_test ()
public function n_dependency_definition get_dependency ()
private subroutine set_libraries_by_scope (readonly n_json_parser an_json, readonly string as_scope) throws exception
private subroutine create_library (readonly string as_library_name, readonly n_json_attribute an_library_attribute, readonly string as_scope) throws exception
private subroutine sort_libraries ()
end prototypes

public subroutine set_file (readonly string as_properties_file) throws exception;n_json_parser ln_json
ln_json = create n_json_parser
ln_json.parse(f_file_factory().read_file_data(as_properties_file))

is_name = ln_json.get_attribute("name")
if ln_json.is_attribute_exists("version") then
	is_version = ln_json.get_attribute("version")
end if
if ln_json.is_attribute_exists("description") then
	is_description = ln_json.get_attribute("description")
end if

in_application = create n_application_definition
in_application.parse(ln_json.get_attribute("application"))

in_deploy = create n_deploy_definition
in_deploy.parse(ln_json.get_attribute("deploy"))

this.set_libraries(ln_json)

if ln_json.is_attribute_exists("dependencies") then
	in_dependency = create n_dependency_definition 
	in_dependency.parse(ln_json.get_attribute("dependencies"))
end if

if ln_json.is_attribute_exists("antProperties") then
	this.set_ant_properties(ln_json)
end if

if ln_json.is_attribute_exists("test") then
	n_json_attribute ln_test_attr
	ln_test_attr = ln_json.get_item("test")
	
	in_test = create n_test_definition
	in_test.set_script(ln_test_attr.get_string_value("script"))
end if

return
end subroutine

public function string get_name ();return is_name
end function

public function string get_version ();return is_version
end function

public function string get_description ();return is_description
end function

public function n_application_definition get_application ();return in_application
end function

public function n_deploy_definition get_deploy ();return in_deploy
end function

public function integer get_libraries (ref n_library an_libraries[]);an_libraries = in_libraries

return upperbound(an_libraries)
end function

public function integer get_ant_properties (ref n_ant_property an_ant_properties[]);an_ant_properties = in_ant_properties

return upperbound(an_ant_properties)
end function

private subroutine set_ant_properties (readonly n_json_parser an_json) throws exception;n_json_parser ln_ant_properties
ln_ant_properties = an_json.get_attribute("antProperties")

string ls_prop_pairs_name[]
ln_ant_properties.get_pairs_name(ref ls_prop_pairs_name)

int li_prop
for li_prop = 1 to upperbound(ls_prop_pairs_name)
	string ls_prop
	ls_prop = ls_prop_pairs_name[li_prop]
	
	string ls_value
	string ls_info
	
	ls_value = ""
	ls_info = ""
	
	n_json_attribute ln_prop_attr
	ln_prop_attr = ln_ant_properties.get_item(ls_prop)
	if ln_prop_attr.is_object() then
		ls_value = ln_prop_attr.get_string_value("value")
		if ln_prop_attr.is_exists("info") then
			ls_info = ln_prop_attr.get_string_value("info")
		end if
	else
		ls_value = ln_prop_attr.get_value()
	end if
	
	in_ant_properties[li_prop] = create n_ant_property
	in_ant_properties[li_prop].set_name(ls_prop) &
									  .set_value(ls_value) &
									  .set_info(ls_info)
next

return
end subroutine

private subroutine set_libraries (readonly n_json_parser an_json) throws exception;n_json_parser ln_libraries
ln_libraries = an_json.get_attribute("libraries")

string ls_pairs_name[]
ln_libraries.get_pairs_name(ref ls_pairs_name)

int i
for i = 1 to upperbound(ls_pairs_name)
	string ls_pair_name
	ls_pair_name = ls_pairs_name[i]
	
	n_json_attribute ln_pair_attr
	ln_pair_attr = ln_libraries.get_item(ls_pair_name)
	if ln_pair_attr.is_object() then
		if ls_pair_name = "scopes" then
			n_json_parser ln_scopes_json
			ln_scopes_json = ln_pair_attr.get_value()
			
			string ls_scopes_pair_name[]
			ln_scopes_json.get_pairs_name(ref ls_scopes_pair_name)
			
			int li_scope
			for li_scope = 1 to upperbound(ls_scopes_pair_name)
				string ls_scope
				ls_scope = ls_scopes_pair_name[li_scope]
				
				this.set_libraries_by_scope(ln_scopes_json.get_attribute(ls_scope), ls_scope)
			next
		else
			this.create_library(ls_pair_name, ln_pair_attr, c_scope.IS_DEFAULT)
		end if
	else
		this.create_library(ls_pair_name, ln_pair_attr, c_scope.IS_DEFAULT)
	end if
next


this.sort_libraries()

return
end subroutine

public function n_test_definition get_test ();return in_test
end function

public function n_dependency_definition get_dependency ();return in_dependency
end function

private subroutine set_libraries_by_scope (readonly n_json_parser an_json, readonly string as_scope) throws exception;string ls_library_pairs_name[]
an_json.get_pairs_name(ref ls_library_pairs_name)

int i
for i = 1 to upperbound(ls_library_pairs_name)
	string ls_library_name
	ls_library_name = ls_library_pairs_name[i]
	this.create_library(ls_library_name &
						, an_json.get_item(ls_library_name) &
						, as_scope)
next

return
end subroutine

private subroutine create_library (readonly string as_library_name, readonly n_json_attribute an_library_attribute, readonly string as_scope) throws exception;string ls_dir
string ls_scope
if an_library_attribute.is_object() then
	ls_dir = an_library_attribute.get_string_value("dir")
	if an_library_attribute.is_exists("scope") then
		ls_scope = an_library_attribute.get_string_value("scope")
	end if
else
	ls_dir = an_library_attribute.get_value()
end if

if f_string().is_empty(ls_scope) then
	ls_scope = as_scope
end if

string ls_name
string ls_order
if pos(as_library_name, ":") > 0 then
	ls_name = f_string().right_part(as_library_name, ":")
	ls_order = f_string().left_part(as_library_name, ":")
else
	ls_name = as_library_name
	ls_order = "1000"
end if
if ls_dir = "." then
	ls_dir = ""
end if

int li_index
li_index = upperbound(in_libraries) + 1
in_libraries[li_index] = create n_library
in_libraries[li_index].set_name(ls_name) &
                      .set_order(ls_order) &
							 .set_dir(ls_dir) &
                      .set_scope(f_deploy().get_scope(ls_scope))

return
end subroutine

private subroutine sort_libraries ();datastore lds_sorting
lds_sorting = create datastore
lds_sorting.dataobject = "d_sort_array_by_order"

int i
for i = 1 to upperbound(in_libraries)
	string ls_order
	ls_order = in_libraries[i].get_order()
	ls_order = fill("0", 10 - len(ls_order)) + ls_order
	
	long ll_row
	ll_row = lds_sorting.insertrow(0)
	lds_sorting.setitem(ll_row, "order", ls_order)
	lds_sorting.setitem(ll_row, "index", i)
next

lds_sorting.sort()

n_library ln_libraries[]
for i = 1 to lds_sorting.rowcount()
	int li_index
	li_index = lds_sorting.getitemnumber(i, "index")
	ln_libraries[i] = in_libraries[li_index]
next

in_libraries = ln_libraries

return
end subroutine

on n_build_properties.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_build_properties.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

