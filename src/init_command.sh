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
	echo "Already found existing CloudEnv project in $PWD/.cloudenv-secret-key"
	echo
	read -p "Generate a new secret key for this project? (N/y): " newkey
	if [ "$newkey" == "y" ]
	then
		head -1 .cloudenv-secret-key > .cloudenv-secret-key-new
		base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 >> .cloudenv-secret-key-new
		echo >> .cloudenv-secret-key-new
		mv .cloudenv-secret-key-new .cloudenv-secret-key
		keysha=`openssl dgst -sha256 .cloudenv-secret-key`
		curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/app/update.json?name=$name&keysha=$keysha" > /tmp/cloudenv-app
		echo
		echo "SUCCESS: New encryption key generated, you will now need to distribute $PWD/.cloudenv-secret-key to all your team members and servers"
	fi
else
	read -p "Name of App: " name
	curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/app/get.json?name=$name" > /tmp/cloudenv-app
	echo $name > .cloudenv-secret-key
	base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 >> .cloudenv-secret-key
	echo >> .cloudenv-secret-key
	keysha=`openssl dgst -sha256 .cloudenv-secret-key`
	curl -s -H "Authorization: Bearer $bearer" "https://app.cloudenv.com/api/v1/app/update.json?name=$name&keysha=$keysha" > /tmp/cloudenv-app
fi