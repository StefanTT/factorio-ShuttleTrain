#!/bin/bash -e

name=$(grep '"name"' info.json | sed 's/^.*: *"\([^"]*\)".*$/\1/')
version=$(grep '"version"' info.json | sed 's/^.*: *"\([^"]*\)".*$/\1/')

cd ..
set -x
zip -r "${name}_${version}.zip" ${name} -x ${name}/doc/\* -x '*.xcf' -x ${name}/.git/\* -x ${name}/.git\* -x ${name}/release.sh

