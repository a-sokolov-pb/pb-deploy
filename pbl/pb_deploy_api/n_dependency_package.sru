$PBExportHeader$n_dependency_package.sru
forward
global type n_dependency_package from n_dependency
end type
end forward

global type n_dependency_package from n_dependency
end type
global n_dependency_package n_dependency_package

type variables
private:

n_artifact in_artifacts[]
end variables
forward prototypes
public function n_dependency_package set_artifacts (readonly n_artifact an_artifacts[])
public function integer get_artifacts (ref n_artifact an_artifacts[])
end prototypes

public function n_dependency_package set_artifacts (readonly n_artifact an_artifacts[]);in_artifacts = an_artifacts

return this
end function

public function integer get_artifacts (ref n_artifact an_artifacts[]);an_artifacts = in_artifacts

return upperbound(an_artifacts)
end function

on n_dependency_package.create
call super::create
end on

on n_dependency_package.destroy
call super::destroy
end on

