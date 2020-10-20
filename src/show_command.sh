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
bearer=`cat ~/.cloudenvrc`
app=`head -1 .cloudenv-secret-key`
secretkey=`tail -1 .cloudenv-secret-key`
environment="${args[environment]}"
tempdir="$(mktemp -d ~/.tmp.XXXXXXXX)"

curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/envs?name=$app&environment=$environment" > "$tempdir/cloudenv-edit-$environment-encrypted"

if [ -s "$tempdir/cloudenv-edit-$environment-encrypted" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit-$environment-encrypted" -out "$tempdir/cloudenv-edit-$environment"
	cat "$tempdir/cloudenv-edit-$environment"
fi

rm -rf "$tempdir"