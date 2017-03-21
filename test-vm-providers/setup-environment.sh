#!/usr/bin/zsh

OLDPWD="$(pwd)"
cd $HOME

TESTFOLDER="${HOME}/p9k"
mkdir -p $TESTFOLDER
cd $TESTFOLDER

# Make a deep test folder
mkdir -p deep-folder/1/12/123/1234/12345/123456/1234567/123455678/123456789

# Make a git repo
mkdir git-repo
cd git-repo
git config --global user.email "test@powerlevel9k.theme"
git config --global user.name  "Testing Tester"
git init
echo "TEST" >> testfile
git add testfile
git commit -m "Initial commit"
cd $TESTFOLDER

# Make a Mercurial repo
mkdir hg-repo
cd hg-repo
export HGUSER="Test bot <bot@example.com>"
hg init
echo "TEST" >> testfile
hg add testfile
hg ci -m "Initial commit"
cd $TESTFOLDER

# Setup a SVN folder
svnadmin create ~/.svn-repo
mkdir svn-repo
svn checkout "file://${HOME}/.svn-repo" "svn-repo"
cd svn-repo
echo "TEST" >> testfile
svn add testfile
svn commit -m "Initial commit"
cd $TESTFOLDER

cd $OLDPWD