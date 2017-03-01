#!/bin/bash

# SETTINGS
# =======================================================

# Project config file

# Clone/create project
NEW_PROJECT=true
YII2_VERSION='2.0.11'

# Repository
REPO_TYPE='git|svn'
REPO_URL=''
REPO_USER=''
REPO_PASS=''
REPO_EMAIL=''
REPO_DIR=''

# Repository branch
DEV_BRANCH='master'

# Privilage for Directory - chown
RIGHTS='user:www-data'

# Yii2
ENV='Development'

# Hosts
HOSTS=("frontend.loc" "dir/frontend/web/" "backend.loc" "dir/backend/web/")

# Create DB
DB_CREATE=true
DB_HOST='localhost'
DB_ROOT_PASS=''

# DB
DB_HOST=''

# scritp variables
# =======================================================
g_mode=0
g_user='orginal value'
g_dir='orginal value'
# =======================================================



function generate_config()
{
  echo "This will create new project.cfg file and overwrite existing one."
  read -p "Are you sure? (Y/n) " -n 1 -r
  if ! [[ $REPLY =~ ^[Nn]$ ]]
  then

    # --- Config file scheme ---
    cat <<EOF > project.cfg
# Project config file

# Clone/create project
NEW_PROJECT=true
YII2_VERSION='2.0.11'

# Repository
REPO_TYPE='git|svn'
REPO_URL=''
REPO_USER=''
REPO_PASS=''
REPO_EMAIL=''
REPO_DIR=''

# Repository branch
DEV_BRANCH='master'

# Privilage for Directory - chown
RIGHTS='user:www-data'

# Yii2
ENV='Development'

# Hosts
HOSTS=("frontend.loc" "dir/frontend/web/" "backend.loc" "dir/backend/web/")

# Create DB
DB_CREATE=true
DB_HOST='localhost'
DB_ROOT_PASS=''

# DB
DB_HOST=''

EOF
  # --- Config file scheme ---

  fi
}

function clone_repository()
{
  echo 'clone_repository'
  if [[ "$REPO_TYPE" == "git" ]]; then

    regexHttps='(https)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    regexHttp='(http)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

    if [[ $REPO_URL =~ $regexHttps ]]; then

      url="https://$REPO_USER:$REPO_PASS@${REPO_URL:8}"
      git clone $url

    elif [[ $REPO_URL =~ $regexHttp ]]; then

      url="http://$REPO_USER:$REPO_PASS@${REPO_URL:8}"
      git clone $url

    else

      echo 'Repo url isnt valid.'

    fi

  elif [[ "$REPO_TYPE" == "svn" ]]; then
    echo 'svn'

  else
    echo 'Not correct repository type.'
    exit 128
  fi
}

# $1 - string - rootDir in dir
# $2 - string - dir with project
function add2hosts
{
	$CMD_ROOT echo "127.0.0.1		${1}" >> /etc/hosts
	$CMD_ROOT echo "127.0.0.1		www.${1}" >> /etc/hosts
}

# $1 - string - domain
# $2 - string - path to root
function add2apache
{

	read -r -d '' vhosts << EOM

<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        ServerName www.${1}
        ServerAlias ${1}

        DocumentRoot ${2}

        <Directory "${2}">
                Options Indexes FollowSymLinks Includes ExecCGI
                AllowOverride All
                Require all granted
                Allow from all
        </Directory>

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/${1}-error.log
        CustomLog ${APACHE_LOG_DIR}/${1}-access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

EOM

	$CMD_ROOT echo "${vhosts}" >> ${APACHE2_SITES_PATH}/${1}.conf
	$CMD_ROOT a2ensite ${1}

}

function create_project()
{
  clone_repository

  #install yii2
  composer create-project yiisoft/yii2-app-advanced advanced $YII2_VERSION
  mv ./advanced/* ./$REPO_DIR/
  rm -rf advanced

  php init --env=${ENV} --overwrite=All

  cd ./$REPO_DIR
  git add .
  git commit -m"Init project in Yii2"


}

function clone_project()
{
  clone_repository
}

function doit()
{
  # load cfg settings
  # ========================================================
  if [[ -e "./project.cfg" ]]; then
    source "./project.cfg"
    if [[ $NEW_PROJECT ]]; then
      create_project
    else
      clone_project
    fi
  else
    echo 'Cannot find project.cfg file.'
    exit 128
  fi
}

function attrs()
{
  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      -c|--config)
        g_mode='CONFIG'
      ;;
      "-h"|"--help")
				cat add_domain.md
				exit
			;;
      -U|--user)
        g_user="$2"
        shift # past argument
      ;;
			-di|--dir)
      	g_dir="$2"
      	shift # past argument=value
      ;;
			-do|--doit)
        g_mode='DOIT'
				domains="$2"
				shift # past argument
			;;
      *)
        # unknown option
      ;;
    esac
    shift # past argument or value
  done
}

function run()
{
  if [[ "$g_mode" == "CONFIG" ]]; then
    generate_config
  elif [[ "$g_mode" == "DOIT" ]]; then
    doit
  fi
}

attrs $@
run
