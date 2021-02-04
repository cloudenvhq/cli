check_logged_in
check_for_project

file="${args[file]}"
environment="${args[environment]}"

echo

if [ -f "$file" ]
then
	upload_env "$file"
	ohai "Environment $environment in app $app has been updated"
else
	warn "File '$file' does not exist"
	echo
	echo "Usage: cloudenv push [environment] [filename]"
fi

echo

rm -rf "$tempdir"