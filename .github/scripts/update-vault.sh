#!/usr/bin/env bash
set -euo pipefail

branch=$1
semvar_bump=$2

git config user.name github-actions
git config user.email github-actions@github.com
git config --global url."https://$GITHUB_TOKEN:x-oauth-basic@github.com/".insteadOf "https://github.com/"
git checkout -b update-"$GITHUB_REPOSITORY"-"$VERSION"-"$(date +%s)"

go get github.com/hashicorp/vault-plugin-mock"$semvar_bump"
go mod tidy
rm -rf vendor
go mod vendor

git add .
git commit --allow-empty -m "Updating $GITHUB_REPOSITORY deps"

command=$(hub pull-request -m "Update version of $GITHUB_REPOSITORY." -b "sarahethompson/vault:$branch" \
-h "sarahethompson/vault:update-$GITHUB_REPOSITORY-$VERSION-$(date +%s)" \
-l "plugin-update" -a "$ACTOR" -p | tail -1) || return 1

echo "$command"

json='
{
	"blocks": [
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "<'$command'|PR on Vault '$branch'> successfully created! ('$GITHUB_REPOSITORY' version: '$VERSION')"
			}
		}
	]
}'

echo $json | curl -X POST -H "Content-type: application/json; charset=utf-8" \
--data @- \
$SLACK_WEBHOOK_URL