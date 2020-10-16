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

curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/get_env.json?project=$project&environment=$environment" > /tmp/cloudenv-edit

"$editor" /tmp/cloudenv-edit

curl -s -H "Authorization: Bearer $bearer" -F "data=@/tmp/cloudenv-edit" "https://app.cloudenv.com/api/v1/put_env.json?project=$project&environment=$environment"

rm /tmp/cloudenv-edit