### Codex CLI setup - start
function CreateGptCompletion {
    param (
        [Parameter(Mandatory)]
        [string] $buffer
    )

    # create .gpt-cli folder in user profile to store data
    $contextFolderPath = Join-Path -Path $env:USERPROFILE -ChildPath '.gpt-cli'
    if (-not (Test-Path -Path $contextFolderPath)) {
        New-Item -Path $contextFolderPath -ItemType Directory -Force | Out-Null
    }

    # read rc file as key/value pairs
    $config = Get-Content -Path (Join-Path -Path $contextFolderPath -ChildPath 'openaiapirc') -Raw -ErrorAction SilentlyContinue | ConvertFrom-StringData

    # read the system context from JSON
    $systemContextPath = Join-Path -Path $contextFolderPath -ChildPath 'system-context.json'
    $systemContext = Get-Content -Path $systemContextPath -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    if ($null -eq $systemContext) { $systemContext = @() }

    # read the session context (which will have the most recent conversations appended to it)
    $sessionContextPath = Join-Path -Path $contextFolderPath -ChildPath 'session-context.json'
    $sessionContext = Get-Content -Path $sessionContextPath -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    if ($null -eq $sessionContext) { $sessionContext = @() }

    # trim the session context to not exceed the maximum number of tokens we can send
    while (($sessionContext | Measure-Object -Property Content.Length -Sum).Sum -gt 2500) {
        $sessionContext = $sessionContext | Select-Object -Skip 2
    }

    # trim any comment character off the user's input
    $buffer = ($buffer -replace '^#', '').Trim()

    # build the API request (by adding a new message from the user)
    $sessionContext += @{
        'role'   = 'user'
        'content'= $buffer
    }

    $apiUrl = 'https://api.openai.com/v1/chat/completions'

    $requestBody = @{
        'model'       = $config.engine
        'messages'    = $systemContext + $sessionContext
        'temperature' = 0.2
        'n'           = 1
    } | ConvertTo-Json

    $headers = @{
        'Content-Type'  = 'application/json'
    }

    try {
        # get a response from the OpenAI API
        $response = Invoke-WebRequest -Uri $apiUrl -Authentication Bearer -Token (ConvertTo-SecureString $config.secret_key -AsPlainText) -Method POST -Headers $headers -Body $requestBody
        $responseContent = $response.Content | ConvertFrom-Json
        $completion = $responseContent.choices[0].message.content

        if (-not [string]::IsNullOrEmpty($completion)) {
            # add the returned completion to the session context
            $completion = $completion.Trim()
            $sessionContext += @{
                'role'   = 'assistant'
                'content'= $completion
            }
            $sessionContext | ConvertTo-Json | Set-Content -Path $sessionContextPath -Force
        }

        return $completion
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
}

Set-PSReadLineKeyHandler -Key Ctrl+g `
                         -BriefDescription GptCli `
                         -LongDescription "Runs GPT-3.5 on the current buffer" `
                         -ScriptBlock {
    param($key, $arg)
    
    $line = $null
    $cursor = $null

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $output = CreateGptCompletion($line)
    
    # check if output is not null
    if ($output -ne $null) {
        foreach ($str in $output) {
            if (-not [string]::IsNullOrEmpty($str)) {
                [Microsoft.PowerShell.PSConsoleReadLine]::AddLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($str)
            }
        }
    }
}
### Codex CLI setup - end
