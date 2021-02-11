locked=0
ip_address=`curl -s ident.me`
echo
ohai "Your current ip address is $ip_address"
echo
printf '%s ' 'Do you want to firewall this API token to this IP address (enhanced security on servers)? (N/y):'
read newkey
echo
if [[ "$newkey" == "y" ]]
then
  locked=1
fi

readonly=0
echo
ohai "CloudEnv can prevent writes from this computer"
echo
printf '%s ' 'Do you want this API token to be read-only? (N/y):'
read newkey
echo
if [[ "$newkey" == "y" ]]
then
  readonly=1
fi

echo "-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=YJ9q
-----END PGP PUBLIC KEY BLOCK-----" > "$tempdir/cloudenv.pub"

yes | gpg --import "$tempdir/cloudenv.pub" &> /dev/null
rm "$tempdir/cloudenv.pub"
hostname > ~/.cloudenvrc-setup
base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> ~/.cloudenvrc-setup
echo >> ~/.cloudenvrc-setup
gpg --encrypt --always-trust --armor --recipient support@cloudenv.com --no-version < ~/.cloudenvrc-setup > "$tempdir/cloudenv.auth"
curl -s -F "data=@$tempdir/cloudenv.auth" "$BASE_URL/initauth" > "$tempdir/cloudenv.auth-url"
rm "$tempdir/cloudenv.auth"

echo
ohai "Please visit this url and login or register to authorize this computer: "
echo
echo "${tty_underline}$(cat "$tempdir/cloudenv.auth-url")${tty_reset}"
echo
echo

data=1
i=0

re='^[0-9]+$'

while [[ $data =~ $re ]]
do
  i=$((i+1))
  data=`curl -s -F "data=@$HOME/.cloudenvrc-setup" "$BASE_URL/checkauth?locked=$locked&readonly=$readonly&ip_address=$ip_address"`
  sleep 2
done

if [[ $data =~ $re ]]
then
  warn "Login failed, please try again"
  echo
else
  email="$(echo $data | awk '{print $1}')"
  token="$(echo $data | awk '{print $2}')"
  echo $token > ~/.cloudenvrc
  ohai "You are now logged in as ${tty_underline}$email${tty_reset}"
  echo
fi

rm -rf ~/.cloudenvrc-setup