# Add this comment to file under documents\windowspowershell\profile.ps1
# To source this file as powershell profile from dotfiles folder
# Invoke-Command -ScriptBlock {
#   . "$HOME\dotfiles\profile.ps1"
#     }
# 

using namespace System.Management.Automation
using namespace System.Management.Automation.Language
function openNvimWithTerminal{
    nvim +"terminal powershell"
}

# set global because alias default alias is for script scope
New-Alias -Name nvimt -Value openNvimWithTerminal

Set-PSReadLineOption -EditMode Emacs

# CaptureScreen is good for blog posts or email showing a transaction
# of what you did when asking for help or demonstrating a technique.
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen

# Clipboard interaction is bound by default in Windows mode, but not Emacs mode.
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste

# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
#Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
#Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
#Set-PSReadLineKeyHandler -Key LeftArrow -Function ShellBackwardWord
#Set-PSReadLineKeyHandler -Key RightArrow -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Shift+Ctrl+LeftArrow -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Shift+Ctrl+RightArrow -Function SelectShellForwardWord


# CaptureScreen is good for blog posts or email showing a transaction
# of what you did when asking for help or demonstrating a technique.
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen
#
# In Emacs mode - Tab acts like in bash, but the Windows style completion
# is still useful sometimes, so bind some keys so we can do both
Set-PSReadLineKeyHandler -Key Ctrl+q -Function TabCompleteNext
Set-PSReadLineKeyHandler -Key Ctrl+Q -Function TabCompletePrevious

#
# Ctrl+Shift+j then type a key to mark the current directory.
# Ctrj+j then the same key will change back to that directory without
# needing to type cd and won't change the command line.

#
$global:PSReadLineMarks = @{}

Set-PSReadLineKeyHandler -Key Ctrl+J `
                         -BriefDescription MarkDirectory `
                         -LongDescription "Mark the current directory" `
                         -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey($true)
    $global:PSReadLineMarks[$key.KeyChar] = $pwd
}

Set-PSReadLineKeyHandler -Key Ctrl+j `
                         -BriefDescription JumpDirectory `
                         -LongDescription "Goto the marked directory" `
                         -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey()
    $dir = $global:PSReadLineMarks[$key.KeyChar]
    if ($dir)
    {
        cd $dir
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

Set-PSReadLineKeyHandler -Key Alt+j `
                         -BriefDescription ShowDirectoryMarks `
                         -LongDescription "Show the currently marked directories" `
                         -ScriptBlock {
    param($key, $arg)

    $global:PSReadLineMarks.GetEnumerator() | % {
        [PSCustomObject]@{Key = $_.Key; Dir = $_.Value} } |
        Format-Table -AutoSize | Out-Host

    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
#region Smart Insert/Delete

# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample.

#Set-PSReadLineKeyHandler -Key '"',"'" `
#                         -BriefDescription SmartInsertQuote `
#                         -LongDescription "Insert paired quotes if not already on a quote" `
#                         -ScriptBlock {
#    param($key, $arg)
#
#    $quote = $key.KeyChar
#
#    $selectionStart = $null
#    $selectionLength = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
#
#    $line = $null
#    $cursor = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#
#    # If text is selected, just quote it without any smarts
#    if ($selectionStart -ne -1)
#    {
#        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
#        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
#        return
#    }
#
#    $ast = $null
#    $tokens = $null
#    $parseErrors = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)
#
#    function FindToken
#    {
#        param($tokens, $cursor)
#
#        foreach ($token in $tokens)
#        {
#            if ($cursor -lt $token.Extent.StartOffset) { continue }
#            if ($cursor -lt $token.Extent.EndOffset) {
#                $result = $token
#                $token = $token -as [StringExpandableToken]
#                if ($token) {
#                    $nested = FindToken $token.NestedTokens $cursor
#                    if ($nested) { $result = $nested }
#                }
#
#                return $result
#            }
#        }
#        return $null
#    }
#
#    $token = FindToken $tokens $cursor
#
#    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
#    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
#        # If we're at the start of the string, assume we're inserting a new string
#        if ($token.Extent.StartOffset -eq $cursor) {
#            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
#            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
#            return
#        }
#
#        # If we're at the end of the string, move over the closing quote if present.
#        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
#            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
#            return
#        }
#    }
#
#    if ($null -eq $token -or
#        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
#        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
#            # Odd number of quotes before the cursor, insert a single quote
#            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
#        }
#        else {
#            # Insert matching quotes, move cursor to be in between the quotes
#            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
#            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
#        }
#        return
#    }
#
#    # If cursor is at the start of a token, enclose it in quotes.
#    if ($token.Extent.StartOffset -eq $cursor) {
#        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
#            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
#            $end = $token.Extent.EndOffset
#            $len = $end - $cursor
#            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
#            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
#            return
#        }
#    }
#
#    # We failed to be smart, so just insert a single quote
#    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
#}
#
#Set-PSReadLineKeyHandler -Key '(','{','[' `
#                         -BriefDescription InsertPairedBraces `
#                         -LongDescription "Insert matching braces" `
#                         -ScriptBlock {
#    param($key, $arg)
#
#    $closeChar = switch ($key.KeyChar)
#    {
#        <#case#> '(' { [char]')'; break }
#        <#case#> '{' { [char]'}'; break }
#        <#case#> '[' { [char]']'; break }
#    }
#
#    $selectionStart = $null
#    $selectionLength = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
#
#    $line = $null
#    $cursor = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#    
#    if ($selectionStart -ne -1)
#    {
#      # Text is selected, wrap it in brackets
#      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
#      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
#    } else {
#      # No text is selected, insert a pair
#      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
#      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
#    }
#}
#
#Set-PSReadLineKeyHandler -Key ')',']','}' `
#                         -BriefDescription SmartCloseBraces `
#                         -LongDescription "Insert closing brace or skip" `
#                         -ScriptBlock {
#    param($key, $arg)
#
#    $line = $null
#    $cursor = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#
#    if ($line[$cursor] -eq $key.KeyChar)
#    {
#        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
#    }
#    else
#    {
#        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
#    }
#}
#
#Set-PSReadLineKeyHandler -Key Backspace `
#                         -BriefDescription SmartBackspace `
#                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
#                         -ScriptBlock {
#    param($key, $arg)
#
#    $line = $null
#    $cursor = $null
#    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#
#    if ($cursor -gt 0)
#    {
#        $toMatch = $null
#        if ($cursor -lt $line.Length)
#        {
#            switch ($line[$cursor])
#            {
#                <#case#> '"' { $toMatch = '"'; break }
#                <#case#> "'" { $toMatch = "'"; break }
#                <#case#> ')' { $toMatch = '('; break }
#                <#case#> ']' { $toMatch = '['; break }
#                <#case#> '}' { $toMatch = '{'; break }
#            }
#        }
#
#        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
#        {
#            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
#        }
#        else
#        {
#            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
#        }
#    }
#}

#endregion Smart Insert/Delete

# Cycle through arguments on current line and select the text. This makes it easier to quickly change the argument if re-running a previously run command from the history
# or if using a psreadline predictor. You can also use a digit argument to specify which argument you want to select, i.e. Alt+1, Alt+a selects the first argument
# on the command line. 
Set-PSReadLineKeyHandler -Key Alt+a `
                         -BriefDescription SelectCommandArguments `
                         -LongDescription "Set current selection to next command argument in the command line. Use of digit argument selects argument by position" `
                         -ScriptBlock {
    param($key, $arg)
  
    $ast = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$null, [ref]$null, [ref]$cursor)
  
    $asts = $ast.FindAll( {
        $args[0] -is [System.Management.Automation.Language.ExpressionAst] -and
        $args[0].Parent -is [System.Management.Automation.Language.CommandAst] -and
        $args[0].Extent.StartOffset -ne $args[0].Parent.Extent.StartOffset
      }, $true)
  
    if ($asts.Count -eq 0) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        return
    }
    
    $nextAst = $null

    if ($null -ne $arg) {
        $nextAst = $asts[$arg - 1]
    }
    else {
        foreach ($ast in $asts) {
            if ($ast.Extent.StartOffset -ge $cursor) {
                $nextAst = $ast
                break
            }
        } 
        
        if ($null -eq $nextAst) {
            $nextAst = $asts[0]
        }
    }

    $startOffsetAdjustment = 0
    $endOffsetAdjustment = 0

    if ($nextAst -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
        $nextAst.StringConstantType -ne [System.Management.Automation.Language.StringConstantType]::BareWord) {
            $startOffsetAdjustment = 1
            $endOffsetAdjustment = 2
    }
  
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($nextAst.Extent.StartOffset + $startOffsetAdjustment)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetMark($null, $null)
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($nextAst.Extent.EndOffset - $nextAst.Extent.StartOffset) - $endOffsetAdjustment)
}

Set-PSReadLineKeyHandler -Key F7 `
                         -BriefDescription History `
                         -LongDescription 'Show command history' `
                         -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern)
    {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath))
        {
            if ($line.EndsWith('`'))
            {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines)
                {
                    "$lines`n$line"
                }
                else
                {
                    $line
                }
                continue
            }

            if ($lines)
            {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern)))
            {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}

