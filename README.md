# Azk

ask is a tool to developers it assists in creation, maintenance and isolation
of the environments of development. Through the installation of some components
(cli and agent), you will be able easily to create isolated environments to many
projects and stack of languages.

**Features** : provision, monitoring, builtin load balancer, automatic startup script, logging...

## How It Works

Em alto nível, o azk é uma ferramenta de linha de comando, que com base em um arquivo configuração, o `azkfile.json`, determinar quais os passos necessários para construção (instalação e configuração) do ambiente para executar e/ou compilar uma determina aplicação.

Além disso ele conta com uma série de comandos que permitem executar estas tarefas e controlar a execução de serviços relacionados a aplicação, como banco de dados e filas.

No baixo nível, o azk é um ferramenta que tira proveito de um sistema de containers para Linux, o [docker](http://docker.io) para criar ambientes isolados para execução de cada parte de uma aplicação.

Ele faz isto através de chamadas a api do docker, dessa forma azk é capaz de provisionar imagens e controlar a execução de serviços com base nessas imagens. Além de tarefas mais gerais como: balancear chamadas http para as instâncias de uma aplicação, armazenar logs de execução e uso de recursos e outras tarefas gerais que tenham a ver com ciclo de vida do desenvolvimento de uma aplicação. 

### Entendendo o cli

Para a maior parte das tarefas o comando `azk` primariamente tenta determinar se a pasta corrente é uma `azk application`, para isso ele verifica a existência do arquivo `azkfile.json` na árvore de diretórios da aplicação.

Uma vez determinada a validade da `azk application` é hora de buscar pelo `azk-agent` que será o responsável de fato por executar o comando.

### Entendendo o azk-agent

O `azk-agent` pode ser entendi como o serviço responsável pela execução dos comandos do `azk`. A primeira coisa que o azk-agent determina e se na máquina atual existe a instalação de um docker, se for o caso os comandos são executados com base no docker instalado diretamente na máquina.

No caso do docker não estar instalado na máquina atual, o `azk-agent` busca pelo docker em uma máquina virtual que deve ser especificada através do hostname `azk-agent`, e por fim os comandos são executados através de uma conexão ssh.

### Entendendo o mapeamento de disco 

Quando o docker não estiver instalado na máquina e a estratégia de roda-lo sobre uma máquina virtual for utilizada é necessário um passo extra de "mapeamento de disco".

Neste caso uma pasta base para os projetos deve ser configurada no momento em que a máquina virtual for configurada (variável de ambiente AZK_APPS_PATH). Esta pasta será mapeada dentro da máquina virtual, e no momento da execução dos comandos `azk` o mapeamento da pasta para dentro do docker será feito da forma correta.

## Installation

**Compatibility note**: Em um ambiente `Linux x64`, o azk depende apenas da instalação prévia do [docker](http://docker.io). Porém em outros ambientes como `Mac OS X` ou `Linux x86` se faz necessário a instalação de uma ferramenta para execução de uma máquina virtual onde o docker será executado, no caso o [Vagrant](http://www.vagrantup.com).

### Requirements

* Linux or Mac OS X (Windows: planned)
* [Vagrant](http://www.vagrantup.com) (required for Mac OSX or Linux 32bits)
* [Docker](http://docker.io) (Linux 64bits only)
* Internet connection (provision process)
* git

### Basic GitHub Checkout

1. Check out ask into ~/.azk.

```bash
$ git clone https://github.com/azukiapp/azk.git ~/.azk
```

2. Configure azk-agent ip (Mac OSX or Linux 32bits)

Em ambientes onde o vagrant for necessário é preciso definir um ip para a máquina virtual onde o azk-agent sera executado. Por padrão este ip é `192.168.115.4`, mas ele pode ser definido da seguinte forma:

```bash
$ echo '192.168.2.4 azk-agent` | sudo tee -a /etc/hosts 
```

3. Add ~/.azk/bin to your $PATH for access to the ask command-line utility.

```bash
$ echo 'export PATH="$HOME/.azk/bin:$PATH"' >> ~/.bash_profile
```

**Ubuntu Desktop note**: Modify your ~/.bashrc instead of ~/.bash_profile.

**Zsh note**: Modify your ~/.zshrc file instead of ~/.bash_profile.

4. Add azk init to your shell to enable autocompletion.

```bash
$ echo 'eval "$(azk sh-init -)"' >> ~/.bash_profile
```

Same as in previous step, use ~/.bashrc on Ubuntu, or ~/.zshrc for Zsh.

5. Restart your shell so that PATH changes take effect. (Opening a new terminal tab will usually do it.) Now check if ask was set up:

```bash
$ type azk
#=> "azk is a function"
```

6. enjoy

```bash
$ azk help
```

## Usage/Features

```bash
$ azk init [project] [--box "azukiapp/ruby-box#stable"] # Create a initial a azkfile.json

# Run a specific command
$ azk exec -i /bin/bash           # Run bash (interactive mode)
$ azk exec /bin/bash --version    # Show the version bash installed in image-app

# Run a background services (Azkfile.json#service)
$ azk service start -n 5          # Start 5 instances of default service
$ azk service worker start -n 5   # Start 5 instances of woker service
$ azk service worker scale -n 10  # Scale to 10 instances of woker service
$ azk service stop azk_id         # Stop specific service process id
$ azk service stop                # Stop all default service processes
$ azk service restart azk_id      # Restart specific process
$ azk service restart all         # Hard Restart all default service proccesses
$ azk service redis restart       # Restart redis service
$ azk logs                        # Display all processes logs in streaming
$ azk ps                          # Display all processes status
$ azk monit                       # Monitor in real time all processes
$ azk web                         # Health computer API endpoint:
                                  # (http://[project].dev.azk.io)
```

## License

"Azuki", "Azk" and the Azuki logo are copyright (c) 2013 Azuki Serviços de Internet LTDA.

Azk source code is released under Apache 2 License.

Check LEGAL and LICENSE files for more information.

