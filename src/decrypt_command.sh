file="${args[file]}"

decrypt_file "$file"
print_result

rm -rf "$tempdir"