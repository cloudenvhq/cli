if [ ! -f ~/.cloudenvrc ]
then
	echo
	echo "Not logged in"
	echo
	echo "Please run: cloudenv login"
	echo
	exit
fi

bearer=`cat ~/.cloudenvrc`

if [ -f .cloudenv-secret-key ]
then
	name=`head -1 .cloudenv-secret-key`
	secretkey=`tail -1 .cloudenv-secret-key`
	environment="default"
	echo "Already found an existing CloudEnv project in $PWD/.cloudenv-secret-key"
	echo
	read -p "Generate a new secret key for this project? (N/y): " newkey
	if [ "$newkey" == "y" ]
	then
		curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/envs?app=$name&environment=$environment" > /tmp/cloudenv-edit
		openssl enc -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in /tmp/cloudenv-edit -out /tmp/cloudenv-edit-decrypted
		head -1 .cloudenv-secret-key > .cloudenv-secret-key-new
		base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key-new
		echo >> .cloudenv-secret-key-new
		mv .cloudenv-secret-key-new .cloudenv-secret-key
		sha=`openssl dgst -sha256 .cloudenv-secret-key`
	    read -ra ADDR <<< "$sha"
		app=`curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/apps?name=$name&sha=${ADDR[1]}"`
		secretkey=`tail -1 .cloudenv-secret-key`
		openssl enc -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in /tmp/cloudenv-edit-decrypted -out /tmp/cloudenv-edit
		curl -s -H "Authorization: Bearer $bearer" -F "data=@/tmp/cloudenv-edit" "https://app.cloudenv.com/api/v1/envs?app=$name&environment=$environment"
		rm /tmp/cloudenv-edit*
		if [ "$app" != 200 ]
		then
			echo
			echo "ERROR ($app): I'm sorry but you do not have access to this app. If you believe this is in error, please contact another team member."
		else
			echo
			echo "SUCCESS: New encryption key generated"
			echo
			echo "You need to distribute $PWD/.cloudenv-secret-key to all your team members and servers"
		fi
	fi
else
	read -p "Name of App: " name
	app=`curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/apps?name=$name"`
	if [ "$app" == 401 ]
	then
		echo
		echo "ERROR ($app): This app name already exists, please choose a different one and try again."
		exit
	fi
	if [ "$app" == 200 ]
	then
		echo
		echo "This app name already exists."
		echo
		echo "To get access to the variables, you must get a copy of .cloudenv-secret-key from a team member into this directory"
		echo
		exit
	fi
	echo $name > .cloudenv-secret-key
	base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key
	echo >> .cloudenv-secret-key
	sha=`openssl dgst -sha256 .cloudenv-secret-key`
    read -ra ADDR <<< "$sha"
	curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/apps?name=$name&sha=${ADDR[1]}" > /tmp/cloudenv-app
	if [ "$app" == 201 ]
	then
		echo
		echo "SUCCESS: You have created the app '$name' in CloudEnv"
		echo
		echo "You need to distribute $PWD/.cloudenv-secret-key to all your team members and servers"
	else
		echo
		echo "ERROR ($app): This app name already exists, please choose a different one and try again."
		exit
	fi
fi