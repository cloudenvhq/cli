environment="${args[environment]}"

check_logged_in
check_for_project
check_can_read_env

IFS=$'\n'
re=^\s*[A-Za-z_][A-Za-z0-9_]*=

if [[ "$environment" != "default" ]]
then
  for line in $(get_env "default"); do
    if [[ $line =~ $re ]]; then
      echo "export $line"
    else
      echo "$line"
    fi
  done
fi

for line in $(get_env "$environment"); do
  if [[ $line =~ $re ]]; then
    echo "export $line"
  else
    echo "$line"
  fi
done

rm -rf "$tempdir"