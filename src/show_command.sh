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

bearer=`cat ~/.cloudenvrc | tr -d " \t\n\r"`
app=`head -1 .cloudenv-secret-key`
secretkey=`tail -1 .cloudenv-secret-key`
environment="${args[environment]}"
tempdir="$(mktemp -d ~/.tmp.XXXXXXXX)"

if [ "$environment" != "default" ]
then
	curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=default" > "$tempdir/cloudenv-show-default-encrypted"

	if [ -s "$tempdir/cloudenv-show-default-encrypted" ]
	then
		openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-show-default-encrypted" 2> /dev/null
	fi
fi

curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?name=$app&environment=$environment" > "$tempdir/cloudenv-show-$environment-encrypted"

if [ -s "$tempdir/cloudenv-show-$environment-encrypted" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-show-$environment-encrypted" 2> /dev/null
fi

rm -rf "$tempdir"