#!/bin/bash
GREEN='\033[1;32m'
NC='\033[0m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
printf "${GREEN} Running from ${SCRIPT_DIR} ${NC}\n\n"

if [ -f $SCRIPT_DIR/.env ]; then
  export $(grep -v '^#' $SCRIPT_DIR/.env | xargs -d '\n')
  printf "${GREEN} Imported user data: ${USER_NAME} <${USER_MAIL}> ${NC}\n\n"
fi

case "$1" in
initialize-host)
	cd .scripts
	bash edit-host-file.sh
	bash certificates.sh root
	bash certificates.sh generate
	bash certificates.sh install
	;;
init)
	cd $SCRIPT_DIR
	git config --global core.filemode false
	git config --global pull.rebase false
	composer install
	cd public
	for D in *; do [ -d "${D}" ] && bash $SCRIPT_DIR/workspace.sh setup "${D}"; done
	bash $SCRIPT_DIR/workspace.sh workspace
	;;
setup)
	cd $2
	printf "${GREEN} Setting up the ${2} project ${NC}\n\n"
	if [ -f composer.json ]; then
		composer install
	fi
	if [ -f wp-cli.yml ]; then
		wp db create
		wp core install --url=wordpress.local --title=WordPress --admin_user=admin --admin_password=admin --admin_email=$USER_MAIL
	fi
	;;
workspace)
	if [ ! -f .devcontainer/.ssh/id_rsa ]; then
    	ssh-keygen -t ed25519 -f .devcontainer/.ssh/id_rsa -N ''
	fi
	eval "$(ssh-agent -s)"
	ssh-add .devcontainer/.ssh/id_rsa
	printf "${GREEN}Copy the content bellow into the following github page: https://github.com/settings/ssh/new${NC} \n\n"
	cat .devcontainer/.ssh/id_rsa.pub
	printf "\n\n"
	read -p "Press any key when you're done..."
	ssh-add -l -E sha256

	#git configuration
	git config --global pull.rebase false
	git config --global user.name $USER_NAME
	git config --global user.email $USER_MAIL
	git config --global merge.tool vscode
	git config --global mergetool.vscode.cmd 'code --wait $MERGED'
	git config --global diff.tool vscode
	git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
	printf "${GREEN} Setting github user to ${USER_NAME} <${USER_MAIL}> ${NC}\n\n"

	ssh -T git@github.com
	
	phpcs --config-set installed_paths ../../automattic/phpcs-neutron-standard,../../automattic/vipwpcs,../../inpsyde/php-coding-standards,../../phpcompatibility/php-compatibility,../../sirbrillig/phpcs-variable-analysis,../../wp-coding-standards/wpcs
	;;
*)
	cat <<EOF

Command line interface of the Workspace project.

Usage:
    bash workspace.sh <command> [options]

Available commands:
    initialize-host ........................... Command specific to be used in the host, NOT the Docker container
    init ...................................... Initiates the projects, installing composer dependencies
	setup [directory] ......................... Setups a WordPress project inside the directory passed in the options
    workspace ................................. Runs configurations for the workspace, relies in .env file

EOF
	exit 1
	;;
esac
