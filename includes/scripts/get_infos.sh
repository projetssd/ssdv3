#!/bin/bash
########################################
# Gestion des infos Kubeseed
########################################
# Permet de récupérer des infos
# qui seront traitées par la suite
########################################

source "${SETTINGS_SOURCE}/includes/functions.sh"
source "${SETTINGS_SOURCE}/includes/variables.sh"


echo -e "${BLUE}### INFORMATIONS UTILISATEURS ###${NC}"

if [ ! -f "${ANSIBLE_VARS}" ]; then
  mkdir -p "${HOME}/.ansible/inventories/group_vars"
  cp "${SETTINGS_SOURCE}/includes/files/account.yml" "${ANSIBLE_VARS}"
fi

echo ""
echo -e "${BLUE}L'utilisateur et mot de passe demandés${NC}"
echo -e "${BLUE}serviront à vous authentifier sur les différents services en mode web${NC}"



USERNAME=$(ks_get_from_account_yml user.name)
if [ "${USERNAME}" == notfound ]; then
  ks_manage_account_yml user.name "${USER}"
else
  echo -e "${BLUE}Username déjà renseigné${CEND}"
  user=${USERNAME}
fi


ks_get_and_store_info  "user.pass" "Mot de passe" KS_PASSWORD
ks_get_and_store_info  "user.mail" "Adresse mail" KS_MAIL
ks_get_and_store_info  "user.domain" "Domaine" KS_DOMAIN
ks_get_and_store_info  "cloudflare.login" "Votre Email cloudflare" KS_CF_MAIL
ks_get_and_store_info  "cloudflare.api" "Votre API cloudflare" KS_CF_API
# On met le ssl CF à full
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cf_force_full_ssl.yml"

# creation utilisateur
userid=$(id -u)
grpid=$(id -g)

# on reprend les valeurs du account.yml, juste au cas où
user=$(ks_get_from_account_yml user.name)
pass=$(ks_get_from_account_yml user.pass)

ks_manage_account_yml user.htpwd $(htpasswd -nb "${user}" "${pass}")

ks_manage_account_yml user.userid "$userid"
ks_manage_account_yml user.groupid "$grpid"

ks_manage_account_yml user.k3s_secret $(htpasswd -nb "${user}" "${pass}" | openssl base64)
