#! /bin/sh

set -e

if [ $# -ne 1 ] ; then
  echo "usage: $0 <new-version>"
  exit 1
fi

VERSION="${1}"

sed -e "s:VERSION.*:VERSION = '${VERSION}':" -i lib/marathon/version.rb

bundle exec rake spec

git commit -m "prepare release ${VERSION}" lib/marathon/version.rb

gem build "marathon-api.gemspec"
git tag "${VERSION}"

echo "upload?"
read ok

gem push "marathon-api-${VERSION}.gem"

echo "push?"
read ok

git push
git push --tags
