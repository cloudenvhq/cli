check_logged_in
check_for_project

file="${args[file]}"

if [ -f "$file" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in "$file" -out "$tempdir/cloudenv-edit-$environment-encrypted" 2> /dev/null
	curl -s -H "Authorization: Bearer $bearer" -F "data=@$tempdir/cloudenv-edit-$environment-encrypted" "$BASE_URL/api/v1/envs?name=$app&environment=$environment" > /dev/null
	ohai "Environment $environment in app $app has been updated"
else
	warn "File $file does not exist"
fi

rm -rf "$tempdir"