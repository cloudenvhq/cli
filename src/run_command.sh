command="${args[command]}"
environment="${args[environment]}"

check_logged_in
check_for_project
check_can_read_env

get_env "$environment" > "$tempdir/cloudenv-edit-$environment"

bash -c "source '$tempdir/cloudenv-edit-$environment'; rm -rf $tempdir; $command"

rm -rf "$tempdir"