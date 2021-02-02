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
secretkey=`head -2 .cloudenv-secret-key | tail -1`
environment="${args[environment]}"
file="${args[file]}"

if [ -f "$file" ]
then
	openssl enc -a -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in "$file" -out "$tempdir/cloudenv-edit-$environment-encrypted" 2> /dev/null
	curl -s -H "Authorization: Bearer $bearer" -F "data=@$tempdir/cloudenv-edit-$environment-encrypted" "$BASE_URL/api/v1/envs?name=$app&environment=$environment" > /dev/null
else
	echo "File $file does not exist"
fi

rm -rf "$tempdir"