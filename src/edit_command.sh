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
project=`head -1 .cloudenv-secret-key`
secretkey=`tail -1 .cloudenv-secret-key`
environment="${args[environment]}"

curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/envs/get?project=$project&environment=$environment" > /tmp/cloudenv-edit

openssl enc -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in /tmp/cloudenv-edit -out /tmp/cloudenv-edit-decrypted

"$editor" /tmp/cloudenv-edit-decrypted

openssl enc -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in /tmp/cloudenv-edit-decrypted -out /tmp/cloudenv-edit

curl -s -H "Authorization: Bearer $bearer" -F "data=@/tmp/cloudenv-edit" "https://app.cloudenv.com/api/v1/envs/update?project=$project&environment=$environment"

rm /tmp/cloudenv-edit*