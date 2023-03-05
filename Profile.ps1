
$fileContents = [string]::join([environment]::newline, 
(get-content -path  "$HOME\dotfiles\profile.ps1"))

invoke-expression $fileContents
#Invoke-Command -ScriptBlock {
#  . "$HOME\dotfiles\profile.ps1"
#  }
