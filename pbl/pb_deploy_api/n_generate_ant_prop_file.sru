$PBExportHeader$n_generate_ant_prop_file.sru
forward
global type n_generate_ant_prop_file from n_generate_file_definition_base
end type
end forward

global type n_generate_ant_prop_file from n_generate_file_definition_base
end type
global n_generate_ant_prop_file n_generate_ant_prop_file

type variables
private:

constant string IS_TEMPLATE = '# Имя проекта&
~r~nproject.name=@project.name&
~r~n# Исполняемый файл&
~r~nproject.executable=@project.executable&
~r~n# Путь к таргету приложения&
~r~nproject.target=@project.target&
~r~n# Путь к .zip дистрибутиву&
~r~nzip.package=@zip.package&
~r~n# Скрипт запуска юнит тестов&
~r~ntest.script=@test.script'

string is_reserved_words[] = {"project.name" &
                            , "project.executable" &
									 , "project.target" &
									 , "zip.package" &
									 , "test.script" &
									 , "nexus.url" &
									 , "nexus.login" &
									 , "nexus.pass" &
									 , "powergen.test.file" &
									 , "powergen.release.file" &
									 , "log.file" &
									 , "distrib.dir" &
									 , "target.dir" &
									 , "temp.dir" &
									 , "download.dependencies.file" &
									 , "config.file" &
									 , "properties.file" &
									 , "powergen.output.log.file" &
									 , "deploy-api.dir" &
									 , "deploy-api.exe" &
									 , "deploy-api.url" &
									 , "unit-test.dir" &
									 , "unit-test.exe" &
									 , "unit-test.url" &
									 , "deploy-api.version" &
									 , "unit-test.version" &
									 , "nexus.properties" &
									 , "nexus.username" &
									 , "nexus.password"}
end variables
forward prototypes
protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception
end prototypes

protected function string generate_by_properties (readonly n_command_param an_param, readonly n_build_properties an_properties) throws exception;string ls_template = IS_TEMPLATE

this.set_token(ref ls_template, "@project.name", an_properties.get_name())

n_application_definition ln_application
ln_application = an_properties.get_application()
this.set_token(ref ls_template, "@project.target", ln_application.get_target())

n_deploy_definition ln_deploy
ln_deploy = an_properties.get_deploy()

string ls_zip
ls_zip = ln_deploy.get_zip()
if f_string().is_empty(ls_zip) then
	ls_zip = ln_application.get_name() + ".zip"
end if
this.set_token(ref ls_template, "@zip.package", ls_zip)

string ls_test_script = "test.all"
if isvalid(an_properties.get_test()) then
	ls_test_script = an_properties.get_test().get_script()
end if
this.set_token(ref ls_template, "@project.executable", ln_deploy.get_exe())
this.set_token(ref ls_template, "@test.script", ls_test_script)

n_ant_property ln_properties[]
an_properties.get_ant_properties(ref ln_properties)

int i
for i = 1 to upperbound(ln_properties)
	string ls_name
	ls_name = ln_properties[i].get_name()
	if f_array().contains(is_reserved_words, lower(ls_name)) then
		throw f_exception().exception("Ant property '" + ls_name + "' is reserved")
	end if
	
	if not f_string().is_empty(ln_properties[i].get_info()) then
		ls_template += "~r~n# " + ln_properties[i].get_info()
	end if
	ls_template += "~r~n" + ls_name + "=" + ln_properties[i].get_value()
next

return ls_template
end function

on n_generate_ant_prop_file.create
call super::create
end on

on n_generate_ant_prop_file.destroy
call super::destroy
end on

