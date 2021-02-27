locked=0
ip_address=$(curl -s ident.me)
echo
ohai "Your current ip address is $ip_address"
echo
printf '%s ' 'Do you want to firewall this API token to this IP address (enhanced security on servers)? (N/y):'
read -r newkey
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
read -r newkey
echo
if [[ "$newkey" == "y" ]]
then
  readonly=1
fi

hostname > "$tempdir/cloudenv.auth"
base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 | tr '\n' '1' >> "$tempdir/cloudenv.auth"
echo >> "$tempdir/cloudenv.auth"
execute "curl" "-s" "-F" "\"data=@$tempdir/cloudenv.auth\"" "\"$base_url/initauth\""

echo
ohai "Please visit this url and login or register to authorize this computer: "
echo
echo "${tty_underline}$output${tty_reset}"
echo
echo

output=1
i=0

re='^[0-9]+$'

while [[ $output =~ $re ]]
do
  i=$((i+1))
  execute "curl" "-s" "-F" "\"data=@$tempdir/cloudenv.auth\"" "\"$base_url/checkauth?locked=$locked&readonly=$readonly&ip_address=$ip_address\""
  sleep 2
done

if [[ $output =~ $re ]]
then
  warn "Login failed, please try again"
  echo
else
  email="$(echo "$output" | awk '{print $1}')"
  token="$(echo "$output" | awk '{print $2}')"
  echo "$token" > ~/.cloudenvrc
  ohai "You are now logged in as ${tty_underline}$email${tty_reset}"
  echo
fi

rm -rf "$tempdir"