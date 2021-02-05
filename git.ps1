# setup alias
git config --global alias.co checkout
git config --global alias.sw switch
git config --global alias.re restore
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global color.ui auto
git config --global push.default simple
git config --global pull.rebase false
git config --global alias.kfetch 'fetch --all --prune'
git config --global core.autocrlf input
git config --global alias.brmd '!powershell -NoProfile -Command ''git branch --merged | Where-Object { $_ -NotMatch \"^\*\" } | %{&git branch -d $_.Trim()}'''