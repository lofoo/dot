
#command
alias ls='ls --color=auto'
alias sudo='nircmd elevate'
alias e='explorer'
alias wget='wget -4'
alias ssh='ssh -4'
alias curl='curl -4'
alias 7zgit='7z a *.zip .git'


#Handy Git Aliases
alias g="git"
alias ga="git add"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbdr="git push origin --delete"
alias gc="git commit"
alias gca="git commit -am"
alias gch="git checkout"
alias gl="git log --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr)%Creset %Cblue[%an]%Creset' --date=relative"
alias gchp="git cherry-pick"
alias gs="git status"
alias gsb="gs -sb"
alias gst="git stash"
alias gf="git fetch"
alias gm="git merge"
alias gpsh="git push --tags"
alias gpl="git pull"
alias gpsho="gpsh origin"
alias gplo="gpl origin"
alias gd="git diff --color"
alias gdpat="gd --patience"
alias gds="gd --stat"
alias gdl="gl --cherry-pick"
alias gt="git tag"
alias gsh="git show --color"
alias gshs="gsh -s"
alias gshst="gsh --stat"
alias gbl="git blame --date=short"

#quick jump
alias zt='cd /c/tmp'
alias zd='cd ~/Downloads'

#export 
export EDITOR=vim
export PATH=$PATH:/c/cygwin/bin
export PATH=$PATH:/c/Program\ Files/Far\ Manager
export PATH=$PATH:/c/Users/me/lofoo/depfiles
export PATH=$PATH:/c/Users/me/lofoo/depfiles/git-extras


#Vim
alias vim='vim --cmd "set encoding=cp936"'

#utf-8
alias u='iconv -f UTF-8'

#misc.
alias n='C:\\Program\ Files\ \(x86\)\\Notepad++\\notepad++.exe'
alias subl='C:\\Program\ Files\\Sublime\ Text\ 2\\sublime_text.exe'

#gitRepo
#alias t='C:\\gitrepo\\todo.txt_cli-2.10\\todo.sh'


cd ~

#source file
#source ~/.git-completion.bash
