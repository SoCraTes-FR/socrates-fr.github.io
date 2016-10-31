#!/bin/bash
set -e

echo "SOURCE_DIR: ${SOURCE_DIR}"

## Generated folder must exist
if [ ! -d "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR (${SOURCE_DIR}) does not exist, build the source directory before deploying"
  exit 1
fi

## Prevent publish on tags
CURRENT_TAG=$(git tag --contains HEAD)

if [ -z "${STOP_PUBLISH}" ] && [ "$TRAVIS_OS_NAME" = "linux" ] && [ "$TRAVIS_BRANCH" = "$BUILD_BRANCH" ] && [ -z "$CURRENT_TAG" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ]
then
  echo 'Publishing...'
else
  echo 'Skipping publishing'
  exit 0
fi

SSH_KEY_NAME="travis_rsa"

## Git configuration
git config --global user.email ${USER_EMAIL}
git config --global user.name "${USER_NAME}"

## Repository URL
REPO=$(git config remote.origin.url)
REPO=${REPO/git:\/\/github.com\//git@github.com:}
REPO=${REPO/https:\/\/github.com\//git@github.com:}

echo "REPO: ${REPO}"

## Loading SSH key
echo "Loading key..."
openssl aes-256-cbc -K "$encrypted_e144d6cc32a7_key" -iv "$encrypted_e144d6cc32a7_iv" -in .travis/${SSH_KEY_NAME}.enc -out ~/.ssh/${SSH_KEY_NAME} -d
eval "$(ssh-agent -s)"
chmod 600 ~/.ssh/${SSH_KEY_NAME}
ssh-add ~/.ssh/${SSH_KEY_NAME}

REV=$(git rev-parse HEAD)

## Create deploy content directory
REPO_NAME=$(basename $REPO)
TARGET_DIR=$(mktemp -d /tmp/$REPO_NAME.XXXX)

echo "TARGET_DIR: ${TARGET_DIR}"

git clone --branch "${DEPLOY_BRANCH}" "${REPO}" "${TARGET_DIR}"

## Copy public content
rsync -rt --delete --exclude=".git" "${SOURCE_DIR}/" "${TARGET_DIR}/"

cd $TARGET_DIR

## Add content
git add -A

## Commit and push if mandatory
if git diff --quiet --exit-code --cached
then
  echo 'No change'
else
  git commit -m "Publish from $REV"
  git push --follow-tags origin ${DEPLOY_BRANCH}
fi

