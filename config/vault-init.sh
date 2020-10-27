#!/bin/bash

securedb=secrets.kdbx

unseal_key_protected=($(echo -e "$SECDBPASS" | keepassxc-cli  show --show-protected \
--quiet secrets.kdbx vault_unseal_key   | grep -i "password: " | cut -d: -f2))

pass_gen=`pwgen`

if [ -z "$SECDBPASS" ]
then
      echo "
      \$SECDBPASS is empty, going to exit!!
      Please set the proper envirnoment variable such:
      export SECDBPASS=\"somepassword\" "
      exit
else
      echo ""
fi

help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "g     Print the GPL license notification."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

init () {
  rm -f secrets.kdbx
  echo -e "$SECDBPASS\n$SECDBPASS" |keepassxc-cli db-create $securedb -p
  echo "Initializing  VAULT"
  read_vault_init_secrets=`vault operator init -key-shares=1 -key-threshold=1`
  unseal_key=$(echo "$read_vault_init_secrets" | grep "Unseal Key 1:"  |  awk '{ print $4 }')
  initial_root_token=$(echo "$read_vault_init_secrets" | grep "Initial Root Token:" |  awk '{ print $4 }' > initial_root_token.txt)
  vault operator unseal ${unseal_key}
  echo -e "$SECDBPASS\n$unseal_key" |   keepassxc-cli add   $securedb vault_unseal_key  -u key -p
}

unseal () {
  vault operator unseal ${unseal_key_protected}
}

# seal () {
#   vault operator seal ${unseal_key_protected}
# }

prep () {
  echo "Login"
  initial_root_token=`cat initial_root_token.txt`
  vault login  -no-print "${initial_root_token}"
  vault audit enable file file_path=/vault/logs/audit.log
  vault auth enable userpass
  ##Super Admin policy and admin user that can sobsitute almost root.
  admin_pass=${pass_gen}
  admin_pass_store=$admin_pass
  echo "Adding admin user to password store!!!"
  echo -e "$SECDBPASS\n$admin_pass_store" |   keepassxc-cli add   $securedb users_admin  -u admin -p
  vault policy write super-admin super-admin-policy.hcl
  vault write auth/userpass/users/admin password=$admin_pass_store policies=super-admin

  echo "Revoking initial ROOT token!!!"
  vault token revoke -self
  rm -f initial_root_token.txt
  echo "Vault is up an running at https://vault.traefik.me:8200 !!!" 🍺
}

get_new_root_token () {
  sleep 5
  otp=`vault operator generate-root -generate-otp`
  nonce_token=`vault operator generate-root -init -otp="$otp" | grep "Nonce" | awk '{ print $2 }'`
  root_token_encoded=`vault operator generate-root -otp="$otp" -nonce="$nonce_token" "${unseal_key_protected}"   | grep "Encoded Token" | awk '{ print $3 }'`
  root_token_decoded=`vault operator generate-root -decode="$root_token_encoded" -otp="$otp"`
  echo -e "$SECDBPASS" |   keepassxc-cli rm   $securedb vault_root_token || true
  sleep 5
  echo -e "$SECDBPASS\n$root_token_decoded" |   keepassxc-cli add   $securedb vault_root_token  -u key -p
}

show_secure_db_entries () {
  echo "Show Secure DB entries:"
  echo -e "$SECDBPASS" |   keepassxc-cli  ls $securedb -q
}

get_secure_db_entries () {
  echo -e "$SECDBPASS" |   keepassxc-cli  show --show-protected --quiet  $securedb $1  | grep -i "password: " | cut -d: -f2
}

"$@"
