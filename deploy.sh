#!/bin/bash

REMOTE_REPO="https://github.com/yq314/autodeploy.git"
PROJECT_NAME="autodeploy"
WORKING_DIR="./tmp"
DEST_CGI="/home/wwwroot/cgi-bin"
DEST_HTDOCS="/home/wwwroot/htdocs"
BACKUP_DIR="/var/backups/"

HELP="Usage: $0 <env> [command]
    env:        prod - deploy to production
            dev - deploy to staging
    command:    go - do a real deployment
            <blank> - dry run

Example:
    $0 dev go - will deploy staging
    $0 prod go - will deploy production
    $0 prod - will simulate deployment to production
"

echo "####################################"
echo "#      DEPLOY SCRIPT               #"
echo "#      V0.02                       #"
echo "####################################"
echo ""

if [ $# = 0 ]; then
    echo "Error: missing parameters!"
fi

if [ $# = 0 ] || [ "$1" = "help" ] || [ "$1" = "h" ]; then
    echo "$HELP"
    exit
fi

if [ "$1" = "prod" ]; then
    DIR_SUFFIX=""
    echo "Deploying to PRODUCTION"
else
    DIR_SUFFIX="_stage"
    echo "Deploying to STAGING"
fi

if [ "$2" = "go" ]; then
    DRY_RUN=0
else
    DRY_RUN=1
    echo "*** This is a DRY RUN ***"
fi

echo ""
echo "+++ Preparing +++"
if [ ! -d "$WORKING_DIR" ]; then
    echo "Create temp folder $WORKING_DIR ..."
    mkdir "$WORKING_DIR"
fi

echo "Go in working directory $WORKING_DIR"
cd "$WORKING_DIR"

need_clone=1

if [ -d "$PROJECT_NAME" ]; then
    if [ -d "$PROJECT_NAME/.git" ]; then
        echo "Local dir exists, try to pull lastest codes ..."
        need_clone=0
        cd "$PROJECT_NAME"
        git pull
    else
        echo "Local dir exists but not under version, delete first ..."
        rm -rf "$PROJECT_NAME"
    fi
fi

if [ "$need_clone" = 1 ]; then
    echo "Clone remote repo $REMOTE_REPO to local"
    git clone "$REMOTE_REPO"
    cd "$PROJECT_NAME"
fi

echo ""
echo "+++ Backing up +++"
timestamp=`date +"%Y%m%d%H%M"`
echo ""
echo "Backup htdocs to ${BACKUP_DIR}${PROJECT_NAME}${DIR_SUFFIX}_${timestamp}.zip ..."
if [ ! "$DRY_RUN" = 1 ]; then
    zip -r -q "${BACKUP_DIR}${PROJECT_NAME}${DIR_SUFFIX}_${timestamp}" "$DEST_HTDOCS/${PROJECT_NAME}$DIR_SUFFIX"
fi
echo "Backup cgi-bin to ${BACKUP_DIR}${PROJECT_NAME}${DEST_SUFFIX}_${timestamp}.zip ..."
if [ ! "$DRY_RUN" = 1 ]; then
    zip -r -q "${BACKUP_DIR}${PROJECT_NAME}${DEST_SUFFIX}_${timestamp}" "$DEST_CGI/${PROJECT_NAME}$DIR_SUFFIX"
fi


echo ""
echo "+++ Deploying +++"
echo "Deploy htdocs"
if [ "$DRY_RUN" = 1 ]; then
    rsync --dry-run --force --delete -avPC "htdocs/${PROJECT_NAME}" "$DEST_HTDOCS/${PROJECT_NAME}${DIR_SUFFIX}$DIR_HTDOCS"
else
    rsync --force --delete -aPC "htdocs/${PROJECT_NAME}" "$DEST_HTDOCS/${PROJECT_NAME}${DIR_SUFFIX}$DIR_HTDOCS"
fi

echo "Deploy cgi-bin"
if [ "$DRY_RUN" = 1 ]; then
        rsync --dry-run --force --delete -avPC "cgi-bin/${PROJECT_NAME}" "$DEST_CGI/${PROJECT_NAME}$DIR_SUFFIX"
else
        rsync --force --delete -aPC "cgi-bin/${PROJECT_NAME}" "$DEST_CGI/${PROJECT_NAME}$DIR_SUFFIX"
fi

echo ""
echo "+++ Update .htaccess +++"
if [ ! "$DRY_RUN" = 1 ]; then
    sed -i "s/RewriteBase \/cgi-bin\/${PROJECT_NAME}\//RewriteBase \/cgi-bin\/${PROJECT_NAME}$DIR_SUFFIX\//" "$DEST_CGI/${PROJECT_NAME}$DIR_SUFFIX/.htaccess"
fi

echo "==== Done ==="

