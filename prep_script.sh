#!/bin/bash
google-chrome --version
export TRAVIS_BUILD_DIR=`pwd`
export PORT=4231
google-chrome --version | grep -o -E [0-9.]+
export CHROME_VERSION=`google-chrome --version | grep -o -E [0-9]+\.[0-9]+\.[0-9]+`
wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION
wget https://chromedriver.storage.googleapis.com/`cat LATEST_RELEASE_$CHROME_VERSION`/chromedriver_linux64.zip

mkdir driver && unzip chromedriver_linux64.zip -d $TRAVIS_BUILD_DIR/driver/ && rm chromedriver_linux64.zip LATEST_RELEASE_$CHROME_VERSION
export PATH=$PATH:$TRAVIS_BUILD_DIR/driver/
echo $PATH

#nvm install 10.10.0
git submodule -q foreach git pull -q origin master
#psql -c 'create database travis_ci_test;' -U postgres
cd $TRAVIS_BUILD_DIR/front
npm install
cd $TRAVIS_BUILD_DIR/back
python3 -m venv virtualenv
. virtualenv/bin/activate
. ../secrets.sh
pip install -r requirements.txt
./manage.py migrate

#script:
cd $TRAVIS_BUILD_DIR/front
# - nvm use node
node_modules/@angular/cli/bin/ng build -c test
npm start&
cd $TRAVIS_BUILD_DIR/back
./manage.py test e2e.test_e2e

kill %1
