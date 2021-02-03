check_logged_in
check_for_project

command="${args[command]}"

curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=$environment&version=$version&lang=cli" > "$tempdir/cloudenv-edit-$environment-encrypted"

if [ -s "$tempdir/cloudenv-edit-$environment-encrypted" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit-$environment-encrypted" -out "$tempdir/cloudenv-edit-$environment" 2> /dev/null
	bash -c "source '$tempdir/cloudenv-edit-$environment'; rm -rf $tempdir; $command"
else
	bash -c "$command"
fi

rm -rf "$tempdir"