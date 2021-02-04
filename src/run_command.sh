check_logged_in
check_for_project

command="${args[command]}"
environment="${args[environment]}"

get_env "$environment" > "$tempdir/cloudenv-edit-$environment"

bash -c "source '$tempdir/cloudenv-edit-$environment'; rm -rf $tempdir; $command"

rm -rf "$tempdir"