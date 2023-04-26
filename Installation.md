# Codex CLI Installation

In order to leverage the Codex CLI tool, you will need to prepare your environment for the shell of your choice. Installation instructions are shown below for each supported shell environment. 

The following terminal environments are supported:  

* [Powershell](#powershell-instructions)

Learn to install PowerShell on Linux/MacOS
[here](https://docs.microsoft.com/powershell/scripting/install/installing-powershell).

## Prerequisites

An OpenAI API key and engine id are required to execute the Codex CLI tool. 

To obtain the OpenAI API key information, go to (https://platform.openai.com/account/api-keys) and login into your account. 

Once logged in you will see: 
![](images/OpenAI-apikey.png)

Create a new API key by clicking the _Create new secret key_ button, give it a name (e.g., GPT-CLI) and save the copied key where you can retrieve it.

To obtain the OpenAI engine id, go to OpenAI Engines page (https://platform.openai.com/docs/models/model-endpoint-compatibility) for the engines available for the `/v1/chat/completions` endpoint.
Select the desired engine and save the engine id with the API key stored in previous steps. 

## Powershell instructions

1. Download this project to wherever you want. For example, `C:\your\custom\path\` or `~/your/custom/path`.

```PowerShell
git clone https://github.com/bgrainger/GPT-CLI.git C:\your\custom\path\
```

2. Open PowerShell and run the following command. If running in Windows, start PowerShell "as an Administrator".

```PowerShell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

For more information about Execution Policies, see
[about_Execution_Policies](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies).


3. In the same Powershell terminal, go to `C:\your\custom\path\GPT-CLI\` (the folder that contains the cloned Codex CLI project).
Copy the following command, then replace `ENGINE_ID` with the OpenAI engine ID.
Run the command to setup your PowerShell environment.
It will prompt you for OpenAI access key.

```PowerShell
.\scripts\powershell_setup.ps1 -OpenAIEngineId 'ENGINE_ID'
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;See [About powershell_setup.ps1](#about-powershell_setupps1) section to learn script parameters.

4. Open a new PowerShell session, type in `#` followed by your natural language command and hit `Ctrl + G`!

### Clean up
Once you are done, go to `C:\your\custom\path\` (the folder that contains the cloned Codex CLI project), then run the following command to clean up.
```
.\scripts\powershell_cleanup.ps1
```

If you want to revert the execution policy, run this command
```
Set-ExecutionPolicy Undefined -Scope CurrentUser
```

### About powershell_setup.ps1
`powershell_setup.ps1` supports the following parameters:
| Parameter | Type | Description |
|--|--|--|
| `-OpenAIApiKey` | [SecureString](https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring) | Required. If is not supplied, the script will prompt you to input the value. You can find this value at [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys). To provide the value via PowerShell parameter, this is an example for PowerShell 7: <br/> `.\scripts\powershell_setup.ps1 -OpenAIApiKey (ConvertTo-SecureString "YOUR_OPENAI_API_KEY" -AsPlainText -Force)` | 
| `-OpenAIEngineId` | String | Required. The [OpenAI engine Id](https://beta.openai.com/docs/engines/codex-series-private-beta) that provides access to a model.|
| `-RepoRoot` | [FileInfo](https://docs.microsoft.com/en-us/dotnet/api/system.io.fileinfo) | Optional. Default to the current folder.<br>The value should be the path of Codex CLI folder. Example:<br/>`.\scripts\powershell_setup.ps1 -RepoRoot 'C:\your\custom\path'`|
