#/bin/sh

# setup alias
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.svn-diff '!f() { git svn dcommit -n | grep diff | awk -F'\''diff-tree'\'' -v opt=$@ '\''{print "git diff "opt" "$2}'\'' | sh; }; f'

