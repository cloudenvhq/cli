environment="${args[environment]:-default}"

check_logged_in

if [ -f .cloudenv-secret-key ]
then
	echo
	warn "Already found an existing CloudEnv project in $PWD/.cloudenv-secret-key"
	echo
	printf '%s ' 'Generate a new secret key for this project? (N/y):'
	read newkey
	echo
	if [ "$newkey" == "y" ]
	then
		check_can_write_env
		get_env "default" > "$tempdir/cloudenv-edit-decrypted"
		if [ -s "$tempdir/cloudenv-edit-decrypted" ]
		then
			head -1 .cloudenv-secret-key > .cloudenv-secret-key-new
			base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key-new
			echo >> .cloudenv-secret-key-new
			mv .cloudenv-secret-key-new .cloudenv-secret-key
			sha="$(openssl dgst -sha256 .cloudenv-secret-key | awk '{print $2}')"
			curl -s --data-urlencode "name=$name" --data-urlencode "sha=${ADDR[1]}" --data-urlencode "version=$version" --data-urlencode "lang=cli" -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps"
			secretkey=`head -2 .cloudenv-secret-key | tail -1`
			upload_env "$tempdir/cloudenv-edit-decrypted"
		else
			warn "Couldn't find this app in CloudEnv, try deleting $PWD/.cloudenv-secret-key and starting over"
			echo
			rm -rf "$tempdir/cloudenv-edit*"
			exit
		fi
		ohai "SUCCESS: New encryption key generated"
		echo
		ohai "You need to re-distribute the following file to all your team members and deployment servers"
		echo
		echo "$PWD/.cloudenv-secret-key"
		echo
		rm -rf "$tempdir/cloudenv-edit*"
	fi
else
	account_number=$(curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/accounts.txt?version=$version&lang=cli" | wc -l | xargs)

	if [ "$account_number" -gt "1" ]
	then
		echo
		ohai "Which account would you like this app to be associated with?"
		echo
		curl -s -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/accounts.txt?version=$version&lang=cli"
		echo
		printf '%s' 'Account number (1-'
		printf '%s' $account_number
		printf '%s ' '):'
		read account_number
		echo
		ohai "Got it, now let's name your app."
		echo
	else
		echo
		ohai "Let's name your app."
		echo
	fi

	printf '%s ' 'Name of App:'
	read name
	# first, replace spaces with dashes
	slug=${name// /-}
	# now, clean out anything that's not alphanumeric or a dash
	slug=${slug//[^a-zA-Z0-9\-]/}
	# finally, lowercase with TR
	slug=`echo -n $slug | tr A-Z a-z`

	status_code=`curl -s --data-urlencode "slug=$slug" --data-urlencode "name=$name" --data-urlencode "version=$version" --data-urlencode "lang=cli" --data-urlencode "account=$account_number" -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps"`
	if [ "$status_code" == 401 ]
	then
		echo
		warn "ERROR (401): This app name already exists, please choose a different one and try again."
		rm .cloudenv-secret-key
		exit
	fi
	if [ "$status_code" == 200 ]
	then
		echo
		warn "ERROR (200): This app name already exists."
		echo
		ohai "To get access to the variables, you must get a copy of .cloudenv-secret-key from a team member into this directory"
		echo
		exit
	fi
	echo $slug > .cloudenv-secret-key
	base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> .cloudenv-secret-key
	echo >> .cloudenv-secret-key
	sha="$(openssl dgst -sha256 .cloudenv-secret-key | awk '{print $2}')"
	curl -s --data-urlencode "slug=$slug" --data-urlencode "name=$name" --data-urlencode "version=$version" --data-urlencode "lang=cli" --data-urlencode "account=$account_number" --data-urlencode "sha=${ADDR[1]}" -H "Authorization: Bearer $bearer" "$BASE_URL/api/v1/apps" > "$tempdir/cloudenv-app"
	if [ "$status_code" == 201 ]
	then
		echo
		echo > "$tempdir/cloudenv-edit-decrypted"
		upload_env "$tempdir/cloudenv-edit-decrypted"
		ohai "SUCCESS: You have created the app '$name' in CloudEnv"
		echo
		ohai "You need to distribute the following file to all your team members and deployment servers"
		echo
		echo "$PWD/.cloudenv-secret-key"
		echo
	else
		if [ "$status_code" == 401 ]
		then
			echo
			warn "ERROR ($status_code): Authentication error. Please run: cloudenv login"
			rm .cloudenv-secret-key
			exit
		else
			echo
			warn "ERROR ($status_code): There was a problem creating app '$name' with slug '$slug'. Please try to create the app at app.cloudenv.com"
			rm .cloudenv-secret-key
			exit
		fi
	fi
fi

rm -rf "$tempdir"