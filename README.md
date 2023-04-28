# GPT-CLI - Natural Language Command Line Interface

This project uses [GPT-3.5](https://openai.com/blog/chatgpt) to convert natural language commands into commands in PowerShell, Z shell and Bash.

![Codex Cli GIF](codex_cli.gif)

The Command Line Interface (CLI) was the first major User Interface we used to interact with machines. It's incredibly powerful, you can do almost anything with a CLI, but it requires the user to express their intent extremely precisely. The user needs to _know the language of the computer_. 

With the advent of Large Language Models (LLMs), particularly those that have been trained on code, it's possible to interact with a CLI using Natural Language (NL). In effect, these models understand natural language _and_ code well enough that they can translate from one to another. 

This project aims to offer a PowerShell NL->Code experience to allow users to interact with their favorite CLI using NL. The user enters a command, like "what's my IP address", hits `Ctrl + G` and gets a suggestion for a command. The project uses the gpt-3.5-turbo model off-the-shelf, meaning the model has not been explicitly trained for the task. Instead we rely on a discipline called prompt engineering (see [section](#prompt-engineering-and-context-files) below) to coax the right commands from Codex. 

**Note: The model can still make mistakes! Don't run a command if you don't understand it. If you're not sure what a command does, hit `Esc` to cancel it**.

This project took technical inspiration from the [Codex CLI](https://github.com/microsoft/Codex-CLI) project, extending its functionality to use the latest chat-based API, customize the prompts passed to the model (see prompt engineering section below), and retain a history of executed commands.

## Requirements
* An [OpenAI account](https://openai.com/api/)
    * [OpenAI API Key](https://platform.openai.com/account/api-keys).
    * [OpenAI Engine Id](https://platform.openai.com/docs/models/model-endpoint-compatibility). It provides access to a model. For example, `gpt-3.5-turbo` or `gpt-4`. See [here](#what-openai-engines-are-available-to-me) for checking available engines.

## Installation

Please follow the installation instructions for PowerShell from [here](./Installation.md).

## Usage

Once configured for your shell of preference, you can use the GPT-CLI by writing a comment (starting with `#`) into your shell, and then hitting `Ctrl + G`.

The GPT-CLI will "remember" past interactions with the model, allowing you to refer back to previous actions and entities.
If, for example, you asked the GPT-CLI to change your time zone to mountain, and then said "change it back to pacific", the model would have the context from the previous interaction to know that "it" is the user's timezone:

```powershell
# change my timezone to mountain
tzutil /s "Mountain Standard Time"

# change it back to pacific
tzutil /s "Pacific Standard Time"
```

The tool creates a `session-context.json` file that keeps track of past interactions, and passes them to the model on each subsequent command. 

There are tradeoffs to using multi-turn mode - though it enables compelling context resolution, it also increases overhead.
If, for example, the model produces the wrong script for the job, the user will want to remove that from the context, otherwise future conversation turns will be more likely to produce the wrong script again.

## Prompt Engineering and Context Files

This project uses a discipline called _prompt engineering_ to coax GPT-3.5 to generate commands from natural language.
Specifically, we pass the model a series of examples of NL->Commands, to give it a sense of the kind of code it should be writing, and also to nudge it towards generating commands idiomatic to the shell you're using.
These examples live in the `contexts` directory. See snippet from the PowerShell context below:

```powershell
# what's the weather in New York?
(Invoke-WebRequest -uri "wttr.in/NewYork").Content

# make a git ignore with node modules and src in it
"node_modules
src" | Out-File .gitignore

# open it in notepad
notepad .gitignore
```

Note that this project models natural language commands as comments, and provide examples of the kind of PowerShell scripts we expect the model to write. These examples include single line completions, multi-line completions, and multi-turn completions (the "open it in notepad" example refers to the `.gitignore` file generated on the previous turn). 

When a user enters a new command (say "what's my IP address"), we simple append that command onto the context (as a comment) and ask Codex to generate the code that should follow it. Having seen the examples above, Codex will know that it should write a short PowerShell script that satisfies the comment. 

## Building your own Contexts

This project comes pre-loaded with a context for PowerShell.
You can modify the system context to coax other behaviors out of the model.
For example, if you want the GPT-CLI to produce Kubernetes scripts, you can edit the system context with examples of commands and the `kubectl` script the model might produce:

```bash
# make a K8s cluster IP called my-cs running on 5678:8080
kubectl create service clusterip my-cs --tcp=5678:8080
```

Note that GPT-3.5 will often produce correct scripts without any examples.
Having been trained on a large corpus of code, it frequently knows how to produce specific commands.
That said, editing the system context helps coax the specific kind of script you're looking for - whether it's long or short, whether it declares variables or not, whether it refers back to previous commands, etc.
You can also provide examples of your own CLI commands and scripts, to show GPT-3.5 other tools it should consider using.

## Troubleshooting

Add a `Proxy` to `Invoke-WebRequest` (e.g., `Invoke-WebRequest -Proxy "http://127.0.0.1:8888"` for Fiddler Classic) to inspect the requests and responses to and from the OpenAI API.

## FAQ

### What OpenAI engines are available to me?

You might have access to different [OpenAI engines](https://platform.openai.com/docs/models/model-endpoint-compatibility) per OpenAI organization.
To check what engines are available to you, one can query the [List models API](https://platform.openai.com/docs/api-reference/models/list) for available engines.
See the following commands:

* Shell
```
curl https://api.openai.com/v1/engines -H 'Authorization: Bearer YOUR_API_KEY'
```

* PowerShell

    PowerShell v7
    ```powershell
    (Invoke-WebRequest -Uri https://api.openai.com/v1/engines -Authentication Bearer -Token (ConvertTo-SecureString "YOUR_API_KEY" -AsPlainText)).Content
    ```
