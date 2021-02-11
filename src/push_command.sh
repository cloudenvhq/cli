file="${args[file]}"
environment="${args[environment]}"

check_logged_in
check_for_project
check_can_write_env

echo

if [ -f "$file" ]
then
	upload_env "$file"
	ohai "Environment $environment in app $(get_current_app) has been updated"
else
	warn "File '$file' does not exist"
	echo
	echo "Usage: cloudenv push [environment] [filename]"
fi

echo

rm -rf "$tempdir"