#!/bin/bash

REMOTE_REPO="https://github.com/yq314/autodeploy.git"
PROJECT_NAME="autodeploy"
WORKING_DIR="./tmp"
DEST_CGI="/home/wwwroot/cgi-bin"
DEST_HTDOCS="/home/wwwroot/htdocs"
DIR_SUFFIX="_stage" # set to blank for production

echo "####################################"
echo "#      DEPLOY SCRIPT               #"
echo "#      V0.01                       #"
echo "####################################"
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
echo "+++ Deploying +++"
time_today=`date +"%Y%m%d"`
echo ""
echo "Backup htdocs to $PROJECT_NAME${DIR_SUFFIX}_$time_today ..."
mv -v "$DEST_HTDOCS/$PROJECT_NAME$DIR_SUFFIX" "$DEST_HTDOCS/$PROJECT_NAME${DIR_SUFFIX}_$time_today"
echo "Deploy htdocs"
cp -vR "htdocs/$PROJECT_NAME" "$DEST_HTDOCS/$PROJECT_NAME${DIR_SUFFIX}$DIR_HTDOCS"

echo "Backup cgi-bin to $PROJECT_NAME${DEST_SUFFIX}_$time_today ..."
mv -v "$DEST_CGI/$PROJECT_NAME$DIR_SUFFIX" "$DEST_CGI/$PROJECT_NAME${DIR_SUFFIX}_$time_today"
echo "Deploy cgi-bin"
cp -vR "cgi-bin/$PROJECT_NAME" "$DEST_CGI/$PROJECT_NAME$DIR_SUFFIX"

echo "Update RewriteBase in .htaccess"
sed -i "s/RewriteBase \/cgi-bin\/$PROJECT_NAME\//RewriteBase \/cgi-bin\/$PROJECT_NAME$DIR_SUFFIX\//" "$DEST_CGI/$PROJECT_NAME$DIR_SUFFIX/.htaccess"

echo "==== Done ==="
