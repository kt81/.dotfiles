#/bin/sh

# setup alias
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global color.ui auto
git config --global push.default simple
git config --global alias.svn-diff '!f() { git svn dcommit -n | grep diff | awk -F'\''diff-tree'\'' -v opt=$@ '\''{print "git diff "opt" "$2}'\'' | sh; }; f'
git config --global alias.kfetch 'fetch --all --prune'
git config --global alias.kup '!git fetch --all --prune && git checkout master && git merge --ff-only upstream/master && git push origin master'
