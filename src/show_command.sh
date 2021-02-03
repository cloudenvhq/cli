check_logged_in
check_for_project

if [ "$environment" != "default" ]
then
	curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=default&version=$version&lang=cli" > "$tempdir/cloudenv-show-default-encrypted"

	if [ -s "$tempdir/cloudenv-show-default-encrypted" ]
	then
		openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-show-default-encrypted" 2> /dev/null
	else
		echo "# ${tty_red}Warning${tty_reset}: Couldn't get the $environment environment from $app"
	fi
fi

curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=$environment&version=$version&lang=cli" > "$tempdir/cloudenv-show-$environment-encrypted"

if [ -s "$tempdir/cloudenv-show-$environment-encrypted" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-show-$environment-encrypted" 2> /dev/null
else
	echo "# ${tty_red}Warning${tty_reset}: Couldn't get the $environment environment from $app"
fi

rm -rf "$tempdir"