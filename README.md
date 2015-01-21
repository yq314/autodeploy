# autodeploy
This is a shell script used to deploy project automatically, the script will checkout the latest code from git, backup existing project and then deploy new version.

v0.02

```
Usage: ./deploy.sh <env> [command]
	env:		prod - deploy to production
			dev - deploy to staging
	command:	go - do a real deployment
			<blank> - dry run

Example:
	./deploy.sh dev go - will deploy to staging
	./deploy.sh prod go - will deploy to production
	./deploy.sh prod - will simulate deployment to production
```

Update these variables to use

```
REMOTE_REPO="https://github.com/yq314/autodeploy.git"
PROJECT_NAME="autodeploy"
WORKING_DIR="./tmp"
DEST_CGI="/home/wwwroot/cgi-bin"
DEST_HTDOCS="/home/wwwroot/htdocs"
BACKUP_DIR="/var/backups/"
```

The script will 

1. try to find the existing project under `WORKING_DIR`. Do a git pull if found, otherwise do git clone.

2. backup cgi folder and htdocs folder to `BACKUP_DIR` and zip them.

3. rsync with options `-aPC --force --delete`
