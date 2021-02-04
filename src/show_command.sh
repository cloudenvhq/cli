check_logged_in
check_for_project

environment="${args[environment]}"

if [ "$environment" != "default" ]
then
	get_env "default"
fi

get_env "$environment"

rm -rf "$tempdir"