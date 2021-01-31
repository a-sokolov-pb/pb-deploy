$PBExportHeader$n_pb_deploy_manager.sru
forward
global type n_pb_deploy_manager from nonvisualobject
end type
type n_pb_deploy_manager_output_callback from n_output_callback within n_pb_deploy_manager
end type
end forward

global type n_pb_deploy_manager from nonvisualobject
n_pb_deploy_manager_output_callback n_pb_deploy_manager_output_callback
end type
global n_pb_deploy_manager n_pb_deploy_manager

type variables
private:

int ii_output_log_file_handle
string is_current_folder
string is_error_log_file

n_output_callback in_output

constant string IS_ERROR_FILE = "pb_deployment.error.log"
constant string IS_OUTPUT_FILE = "pb_deployment.output.log"
constant string IS_CONFIG_FILE = "build.package.json"
end variables
forward prototypes
public subroutine output (readonly string as_text)
private subroutine free_resources ()
public function long start (readonly string as_command_line)
public subroutine log_error (readonly string as_text)
public subroutine log_error (readonly exception err)
public subroutine deploy_block (readonly n_command_line_parser an_parser) throws exception
private subroutine parse_block (ref n_command_line_parser an_parser) throws exception
private subroutine append (ref string as_output, readonly string as_line)
private function datetime parse_datetime (string as_line)
private function string calc_total_time (readonly datetime adt_start, readonly datetime adt_end)
public subroutine set_output (readonly n_output_callback an_output)
end prototypes

public subroutine output (readonly string as_text);if ii_output_log_file_handle > 0 then
	filewrite(ii_output_log_file_handle, string(now(), "hh:mm:ss") + " " + as_text)
end if

if isvalid(in_output) then
	in_output.log(as_text)
end if

return
end subroutine

private subroutine free_resources ();if ii_output_log_file_handle > 0 then
	fileclose(ii_output_log_file_handle)
	ii_output_log_file_handle = 0
end if

if isvalid(w_listbox_container) then
	close(w_listbox_container)
end if

return
end subroutine

public function long start (readonly string as_command_line);is_current_folder = getcurrentdirectory()
if not right(is_current_folder, 1) = "\" then
	is_current_folder += "\"
end if

// Файл ошибок по умолчанию
is_error_log_file = is_current_folder + IS_ERROR_FILE

try
	n_command_line_parser ln_parser
	ln_parser = create n_command_line_parser
	if ln_parser.parse(as_command_line) > 0 then
		if f_string().starts_with(as_command_line, "deploy") then
			this.deploy_block(ln_parser)
		elseif f_string().starts_with(as_command_line, "parse") then
			this.parse_block(ln_parser)
		else
			throw f_exception().exception("Unknown block type for command line '" + as_command_line + "'")
		end if
	end if
catch (exception err)
	this.log_error(err)
	if f_pb_addon().is_pb_mode() then
		messagebox(getapplication().displayname, err.getmessage(), stopsign!)
	end if
	
	return 1
finally
	this.free_resources()
end try

return 0
end function

public subroutine log_error (readonly string as_text);try
	datetime ldt_now
	ldt_now = datetime(today(), now())
	
	n_file_writer ln_writer
	ln_writer = create n_file_writer
	ln_writer.ci(f_file_factory().get_for_write(is_error_log_file, linemode!, append!))
	ln_writer.write_in(string(ldt_now, "dd.mm.yyyy hh:mm:ss") + " " + as_text)
	
	if isvalid(in_output) then
		in_output.log(as_text)
	end if
catch (exception err_log)
	// silent mode
end try

return
end subroutine

public subroutine log_error (readonly exception err);this.log_error(classname(err) + ": " + err.getmessage())

return
end subroutine

public subroutine deploy_block (readonly n_command_line_parser an_parser) throws exception;open(w_listbox_container)
if not isvalid(w_listbox_container) then
	throw f_exception().exception("Can't initialize ListBox container")
end if

/*
	/gen:test={имя файла} - генерируем PowerGen файл для сборки с тестами
							Если значение не указано, то создаём build.test.gen
							
	/gen:release={имя файла} - генерируем PowerGen файл для релизной сборки
							Если значение не указано, то создаём build.release.gen

	/get:dev={имя файла} - генерируем PowerGen файл для девелоперской сборки
							Если значение не указано, то создаём build.dev.gen
							
	/pbt={имя файла} - генерируем PowerBuilder target файл
							Если значение не указано, то берём из настройки
							
	/pbw[:имя таргета]={имя файла} - генерируем PowerBuilder workspace файл с указанным таргетом
							Если значения не указаны, то берём из настроек
							
	/pbr={имя файла} - генерируем PowerBuilder resource файл
							Если значение не указано, то генерируем из настройки {deploy#pbr} или {application#name}.pbr
							
	/ant:dependencies={имя файла} - генерируем xml файл, в котором скачиваем зависимости с nexus'а.
							Если значение не указано, то создаём build.download-dependencies.xml
							
	/ant:properties={имя файла} - генерируем .propertie файл, в который сохраняем нужные свойства
							Если значение не указано, то создает build.properties
											
	/config.file={имя файла} - имя JSON файла, где указаны описание проекта, зависимости.
							Если значение не указано, то ищем build.package.json
	/log.file=path
*/
string ls_config_file

n_command_param ln_config_file_cmd
if an_parser.get_param("config.file", ref ln_config_file_cmd) then
	ls_config_file = ln_config_file_cmd.get_value()
	if f_string().is_empty(ls_config_file) then
		throw f_exception().exception("Specify /config.file param value")
	end if
else
	ls_config_file = is_current_folder + IS_CONFIG_FILE
end if

if not fileexists(ls_config_file) then
	throw f_exception().exception("Config file '" + ls_config_file + "' does not exists")
end if

string ls_config_file_folder
ls_config_file_folder = f_file_factory().get_file_path(ls_config_file)

// Переопределяем путь файла ошибок
is_error_log_file = ls_config_file_folder + IS_ERROR_FILE

// Создаем лог файл, там где лежит файл конфигурации
string ls_output_log_file
ls_output_log_file = ls_config_file_folder + IS_OUTPUT_FILE
ii_output_log_file_handle = fileopen(ls_output_log_file, linemode!, write!, lockwrite!, append!)
if not ii_output_log_file_handle > 0 then
	throw f_exception().exception("Error while opening '" + ls_output_log_file + "' file")
end if

this.output("Working with '" + ls_config_file + "'")

n_build_properties ln_properties
ln_properties = create n_build_properties
ln_properties.set_file(ls_config_file)

int li_index
n_generate_file_definition_base ln_generate_file_defs[]

li_index ++
ln_generate_file_defs[li_index] = create n_generate_ant_file
ln_generate_file_defs[li_index].set_param_name("ant:dependencies") &
										 .set_default_file_name("build.download-dependencies.xml")
										 
li_index ++
ln_generate_file_defs[li_index] = create n_generate_ant_prop_file
ln_generate_file_defs[li_index].set_param_name("ant:properties") &
										 .set_default_file_name("build.properties") 
										 
li_index ++
ln_generate_file_defs[li_index] = create n_generate_gen_file
ln_generate_file_defs[li_index].set_param_name("gen:dev") &
										 .set_default_file_name("build.dev.gen")

li_index ++
ln_generate_file_defs[li_index] = create n_generate_gen_file
ln_generate_file_defs[li_index].set_param_name("gen:test") &
										 .set_default_file_name("build.test.gen")

li_index ++
ln_generate_file_defs[li_index] = create n_generate_gen_file
ln_generate_file_defs[li_index].set_param_name("gen:release") &
										 .set_default_file_name("build.release.gen")

li_index ++
ln_generate_file_defs[li_index] = create n_generate_pbt_file
ln_generate_file_defs[li_index].set_param_name("pbt") &
										 .set_default_file_name(ln_properties.get_application().get_target())

li_index ++
ln_generate_file_defs[li_index] = create n_generate_pbw_file
ln_generate_file_defs[li_index].set_param_name("pbw") &
										 .set_default_file_name(ln_properties.get_application().get_ws())


string ls_pbr
ls_pbr = ln_properties.get_deploy().get_pbr()
if f_string().is_empty(ls_pbr) then
	ls_pbr = ln_properties.get_application().get_name() + ".pbr"
end if

li_index ++
ln_generate_file_defs[li_index] = create n_generate_pbr_file
ln_generate_file_defs[li_index].set_param_name("pbr") &
										 .set_default_file_name(ls_pbr)
										
int li_file_def
for li_file_def = 1 to upperbound(ln_generate_file_defs)
	n_generate_file_definition_base ln_generate_file
	ln_generate_file = ln_generate_file_defs[li_file_def]
	
	n_command_param ln_file_param
	if an_parser.get_param_starts_with(ln_generate_file.get_param_name() &
												, ref ln_file_param) then
		ln_generate_file.set_properties(ln_properties)
		ln_generate_file.set_output(n_pb_deploy_manager_output_callback)
		ln_generate_file.set_folder(ls_config_file_folder)
		ln_generate_file.set_container(w_listbox_container.box)
		ln_generate_file.generate(ln_file_param)
	end if
next

return
end subroutine

private subroutine parse_block (ref n_command_line_parser an_parser) throws exception;/*
	/powergen.log={имя файла} - парсим PowerGen лога файл на предмет ошибок, чтобы их записать в отдельный файл.
*/

n_command_param ln_pg_log
if an_parser.get_param("powergen.log", ref ln_pg_log) then
	string ls_powergen_log_file
	ls_powergen_log_file = ln_pg_log.get_value()
	if f_string().is_empty(ls_powergen_log_file) then
		throw f_exception().exception("Specify /powergen.log param value")
	end if
	
	if not fileexists(ls_powergen_log_file) then
		throw f_exception().exception("File '" + ls_powergen_log_file + "' does not exists")
	end if
	
	string ls_powergen_log_file_folder
	ls_powergen_log_file_folder = f_file_factory().get_file_path(ls_powergen_log_file)
	
	// Переопределяем путь файла ошибок
	is_error_log_file = ls_powergen_log_file_folder + IS_ERROR_FILE
	
	// Создаем лог файл, там где лежит файл конфигурации
	string ls_output_log_file
	ls_output_log_file = ls_powergen_log_file_folder + f_file_factory().get_file_name(ls_powergen_log_file) + ".output.log"

	string ls_output_data

	n_file_reader ln_powergen_log_reader
	ln_powergen_log_reader = create n_file_reader
	ln_powergen_log_reader.ci(ls_powergen_log_file, linemode!)
	ln_powergen_log_reader.open_ref()
	
	try
		datetime ldt_log_started
		datetime ldt_log_ended
		setnull(ldt_log_started)
		setnull(ldt_log_ended)
		
		string ls_line_data
		boolean lb_start_writing_output
		boolean lb_library_list_logged
		
		do while ln_powergen_log_reader.read_line(ref ls_line_data)
			if not lb_library_list_logged then
				do
					if f_string().starts_with(ls_line_data, "Bootstrap Import") then
						exit
					end if
					
					if f_string().starts_with(ls_line_data, "Log Started on") &
						and isnull(ldt_log_started) then
						ldt_log_started = this.parse_datetime(ls_line_data)
					end if
					
					if not isnumber(left(trim(ls_line_data), 1)) then
						this.append(ref ls_output_data, ls_line_data)
					end if
				loop while ln_powergen_log_reader.read_line(ref ls_line_data)
				
				lb_library_list_logged = true
			end if
			
			if f_string().starts_with(ls_line_data, "Creating PBD's/DLL's") then
				do
					if f_string().starts_with(ls_line_data, "Log Ended on") &
						and isnull(ldt_log_ended) then
						ldt_log_ended = this.parse_datetime(ls_line_data)
					end if
					
					this.append(ref ls_output_data, ls_line_data)
				loop while ln_powergen_log_reader.read_line(ref ls_line_data)
				
				exit
			end if
			
			if f_string().starts_with(ls_line_data, "Performing Phase ") &
				or f_string().starts_with(ls_line_data, "Bootstrap Import") &
				or f_string().starts_with(ls_line_data, "Synchronizing PBLs to source objects") &
				or f_string().starts_with(ls_line_data, "Log Started on") &
				or f_string().starts_with(ls_line_data, "Log Ended on") then

				this.append(ref ls_output_data, "~r~n" + ls_line_data)
			end if
			
			if not lb_start_writing_output &
				and (f_string().starts_with(ls_line_data, " Library:") &
					or f_string().starts_with(ls_line_data, "     Object:")) then
				lb_start_writing_output = true
			elseif lb_start_writing_output then
				lb_start_writing_output = (left(ls_line_data, 1) = " ")
			end if
			
			if lb_start_writing_output then
				this.append(ref ls_output_data, ls_line_data)
			end if
		loop
		
		if not (isnull(ldt_log_started) or isnull(ldt_log_ended)) then
			this.append(ref ls_output_data, this.calc_total_time(ldt_log_started, ldt_log_ended))
		end if
		
		f_file_factory().write_file_data(ls_output_log_file, ls_output_data)
	finally
		ln_powergen_log_reader.close_ref()
	end try	
end if

return
end subroutine

private subroutine append (ref string as_output, readonly string as_line);if len(as_output) > 0 then
	as_output += "~r~n"
end if

as_output += as_line

return
end subroutine

private function datetime parse_datetime (string as_line);as_line = right(as_line, 17)
return datetime(date(left(as_line, 8)), time(right(as_line, 8)))
end function

private function string calc_total_time (readonly datetime adt_start, readonly datetime adt_end);long ll_seconds
long ll_minutes
long ll_hours

ll_seconds = daysafter(date(adt_start), date(adt_end)) * (3600 * 24)
ll_seconds += secondsafter(time(adt_start), time(adt_end))

ll_hours = truncate(ll_seconds / 3600, 0)
ll_minutes = truncate(mod(ll_seconds, 3600) / 60, 0)
ll_seconds = mod(ll_seconds, 60)

string ls_time
if ll_hours > 0 then
	ls_time = string(ll_hours) + "h"
end if

if ll_minutes > 0 then
	if len(ls_time) > 0 then
		ls_time += " "
	end if
	ls_time += string(ll_minutes) + "min"
end if

if ll_seconds > 0 then
	if len(ls_time) > 0 then
		ls_time += " "
	end if
	ls_time += string(ll_seconds) + "s"
end if

return "Total time: " + ls_time
end function

public subroutine set_output (readonly n_output_callback an_output);in_output = an_output

return
end subroutine

on n_pb_deploy_manager.create
call super::create
this.n_pb_deploy_manager_output_callback=create n_pb_deploy_manager_output_callback
TriggerEvent( this, "constructor" )
end on

on n_pb_deploy_manager.destroy
TriggerEvent( this, "destructor" )
call super::destroy
destroy(this.n_pb_deploy_manager_output_callback)
end on

event destructor;this.free_resources()

return
end event

type n_pb_deploy_manager_output_callback from n_output_callback within n_pb_deploy_manager descriptor "pb_nvo" = "true" 
end type

on n_pb_deploy_manager_output_callback.create
call super::create
end on

on n_pb_deploy_manager_output_callback.destroy
call super::destroy
end on

event log;call super::log;parent.output(as_text)

return
end event

