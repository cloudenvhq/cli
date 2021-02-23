environment="${args[environment]}"

check_logged_in
check_for_project
check_can_read_env

get_encrypted_env "$environment"
print_result

rm -rf "$tempdir"