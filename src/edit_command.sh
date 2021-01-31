if [ ! -f ~/.cloudenvrc ]
then
	echo
	echo "Not logged in"
	echo
	echo "Please run: cloudenv login"
	echo
	exit
fi

if [ ! -f .cloudenv-secret-key ]
then
	echo
	echo "Couldn't find a cloudenv project in $PWD/.cloudenv-secret-key"
	echo
	echo "Please run: cloudenv init"
	echo
	echo "Or cd into the root directory of your app to make env edits"
	echo
	exit
fi

tempdir=${CLOUDENV_TMPDIR:-`mktemp -d ~/.tmp.XXXXXXXX`}
editor="${EDITOR:-nano}"
bearer=`cat ~/.cloudenvrc | tr -d " \t\n\r"`
app=`head -1 .cloudenv-secret-key`
secretkey=`tail -1 .cloudenv-secret-key`
environment="${args[environment]}"

curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=$environment&version=$CLOUDENV_CLI_VERSION&lang=cli" > "$tempdir/cloudenv-edit-$environment-encrypted"

if [ -s "$tempdir/cloudenv-edit-$environment-encrypted" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit-$environment-encrypted" -out "$tempdir/cloudenv-edit-$environment" 2> /dev/null
else
	touch "$tempdir/cloudenv-edit-$environment"
fi

cp "$tempdir/cloudenv-edit-$environment" "$tempdir/cloudenv-orig-$environment"
"$editor" "$tempdir/cloudenv-edit-$environment"

if cmp --silent "$tempdir/cloudenv-edit-$environment" "$tempdir/cloudenv-orig-$environment"
then
	echo "No changes detected"
else
	openssl enc -a -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit-$environment" -out "$tempdir/cloudenv-edit-$environment-encrypted" 2> /dev/null

	curl -s -H "Authorization: Bearer $bearer" -F "data=@$tempdir/cloudenv-edit-$environment-encrypted" "$BASE_URL/api/v1/envs?name=$app&environment=$environment&version=$CLOUDENV_CLI_VERSION&lang=cli" > /dev/null
fi

rm -rf "$tempdir"