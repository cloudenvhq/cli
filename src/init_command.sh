base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 256 > .cloudenv-secret-key
echo >> .cloudenv-secret-key