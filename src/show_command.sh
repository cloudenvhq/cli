environment="${args[environment]}"

check_logged_in
check_for_project
check_can_read_env

if [ "$environment" != "default" ]
then
	get_env "default"
fi

get_env "$environment"

rm -rf "$tempdir"