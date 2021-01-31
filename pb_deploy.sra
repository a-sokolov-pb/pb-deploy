$PBExportHeader$pb_deploy.sra
$PBExportComments$Generated Application Object
forward
global type pb_deploy from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables

end variables

global type pb_deploy from application
string appname = "pb_deploy"
string displayname = "PB Deployment API (version 9.0.9)"
end type
global pb_deploy pb_deploy

type variables
private:

long il_error_level
end variables

on pb_deploy.create
appname="pb_deploy"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pb_deploy.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;if not f_string().is_empty(commandline) then
	n_pb_deploy_manager ln_deploy_manager
	ln_deploy_manager = create n_pb_deploy_manager
	il_error_level = ln_deploy_manager.start(trim(commandline))
else
	open(w_pb_deploy)
end if

return
end event

event close;message.longparm = il_error_level

return
end event

