environment="${args[environment]}"

check_logged_in
check_for_project
check_can_read_env

env_file=`mktemp`
IFS=$'\n'
re=^\s*[A-Za-z_][A-Za-z0-9_]*=

if [[ "$environment" != "default" ]]
then
  for line in $(get_env "default"); do
    if [[ $line =~ $re ]]; then
      echo "export $line" >> $env_file
    else
      echo "$line" >> $env_file
    fi
  done
fi

for line in $(get_env "$environment"); do
  if [[ $line =~ $re ]]; then
    echo "export $line" >> $env_file
  else
    echo "$line" >> $env_file
  fi
done

echo ". $env_file && rm $env_file"

rm -rf "$tempdir"