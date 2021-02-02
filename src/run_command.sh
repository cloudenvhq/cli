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

editor="${EDITOR:-nano}"
bearer=`cat ~/.cloudenvrc | tr -d " \t\n\r"`
app=`head -1 .cloudenv-secret-key`
secretkey=`head -2 .cloudenv-secret-key | tail -1`
environment="${args[environment]}"
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