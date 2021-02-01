if [ ! -f ~/.cloudenvrc ]
then
	echo
	echo "Not logged in"
	echo
	echo "Please run: cloudenv login"
	echo
	exit
fi

bearer=`cat ~/.cloudenvrc | tr -d " \t\n\r"`

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
		curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/envs?app=$name&environment=$environment&version=$version&lang=cli" > "$tempdir/cloudenv-edit"
		if [ -s "$tempdir/cloudenv-edit" ]
		then
			openssl enc -aes-256-cbc -md sha512 -d -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit" -out "$tempdir/cloudenv-edit-decrypted"
			head -1 .cloudenv-secret-key > .cloudenv-secret-key-new
			base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key-new
			echo >> .cloudenv-secret-key-new
			mv .cloudenv-secret-key-new .cloudenv-secret-key
			sha=`openssl dgst -sha256 .cloudenv-secret-key`
		    read -ra ADDR <<< "$sha"
			app=`curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps?name=$name&sha=${ADDR[1]}"`
			secretkey=`tail -1 .cloudenv-secret-key`
			openssl enc -aes-256-cbc -md sha512 -pass pass:"$secretkey" -in "$tempdir/cloudenv-edit-decrypted" -out "$tempdir/cloudenv-edit"
			curl -s -H "Authorization: Bearer $bearer" -F "data=@$tempdir/cloudenv-edit" "$BASE_URL/api/v1/envs?app=$name&environment=$environment&version=$version&lang=cli"
		else
			echo "Couldn't find this app in CloudEnv, try deleting $PWD/.cloudenv-secret-key and starting over"
			exit
		fi
		rm "$tempdir/cloudenv-edit*"
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
	# first, replace spaces with dashes
	slug=${name// /-}
	# now, clean out anything that's not alphanumeric or a dash
	slug=${slug//[^a-zA-Z0-9\-]/}
	# finally, lowercase with TR
	slug=`echo -n $slug | tr A-Z a-z`

	app=`curl -s --data-urlencode "slug=$slug" --data-urlencode "name=$name" --data-urlencode "version=$version" --data-urlencode "lang=cli" -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps"`
	if [ "$app" == 401 ]
	then
		echo
		echo "ERROR (401): This app name already exists, please choose a different one and try again."
		exit
	fi
	if [ "$app" == 200 ]
	then
		echo
		echo "ERROR (200): This app name already exists."
		echo
		echo "To get access to the variables, you must get a copy of .cloudenv-secret-key from a team member into this directory"
		echo
		exit
	fi
	echo $slug > .cloudenv-secret-key
	base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key
	echo >> .cloudenv-secret-key
	sha=`openssl dgst -sha256 .cloudenv-secret-key`
  read -ra ADDR <<< "$sha"
	curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps?name=$name&slug=$slug&sha=${ADDR[1]}&version=$version&lang=cli" > "$tempdir/cloudenv-app"
	if [ "$app" == 201 ]
	then
		echo
		echo "SUCCESS: You have created the app '$name' in CloudEnv"
		echo
		echo "You need to distribute $PWD/.cloudenv-secret-key to all your team members and servers"
	else
		if [ "$app" == 401 ]
		then
			echo
			echo "ERROR ($app): Authentication error. Please run: cloudenv login"
			exit
		else
			if [ "$app" == 404 ]
			then
				echo
				echo "ERROR ($app): The CLI does not yet support accounts that are part of multiple organizations, please create this app at app.cloudenv.com"
				exit
			else
				echo
				echo "ERROR ($app): There was a problem creating app '$name' with slug '$slug'. Please try to create the app at app.cloudenv.com"
				exit
			fi
		fi
	fi
fi