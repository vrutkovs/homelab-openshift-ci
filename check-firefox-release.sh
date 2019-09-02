#!/bin/bash
set -eux
set -o pipefail

# Check that firefox version has been updated
cd /tmp
curl -I https://download.mozilla.org/\?product\=firefox-beta-latest\&os\=linux64\&lang\=en-US 2>/dev/null | grep "Location:" | cut -d ' ' -f 2 > firefox-download-url
NEW_VERSION=$(cat firefox-download-url | cut -d '/' -f 7)
echo "new version: ${NEW_VERSION}"

# Update the repo
git clone -b binaries git@github.com:vrutkovs/firefox-flatpak.git
cd firefox-flatpak
CURRENT_VERSION_STRING=$(cat update-firefox-version | grep CURRENT_VERSION | head -n1)
echo "current version: ${CURRENT_VERSION_STRING}"
NEW_VERSION_STRING="CURRENT_VERSION = '${NEW_VERSION}'"

if [[ "${CURRENT_VERSION}" != "${NEW_VERSION_STRING}" ]]; then
  sed -i "s,${CURRENT_VERSION},${NEW_VERSION_STRING},g" update-firefox-version
  ./update-firefox-version
  git commit -am "Updated to version ${NEW_VERSION}"
  git push origin -fu
fi
