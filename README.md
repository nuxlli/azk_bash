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

Para a maior parte das tarefas o comando `azk` primariamente tenta determinar se a pasta corrente é uma `azk app`, para isso ele verifica a existência do arquivo `azkfile.json` na árvore de diretórios da aplicação.

Uma vez determinada a validade da `azk app` é hora de buscar pelo `azk-agent` que será o responsável por executar o comando em um ambiente isolado da máquina principipal.

### Entendendo o azk-agent

O `azk-agent` pode ser entendi como o serviço responsável pela execução dos comandos do `azk` em um ambiente isolado através do uso do sistema de containers. No fundo o azk-agent é uma máquina virtual rodando o [coreos](http://coreos.com) sobre o virtualbox (vmware esta programando).

### Entendendo o mapeamento de disco 

Como o azk-agent roda sobre uma máquina virtual é preciso fazer um compartilhamento de disco da maquina host com a máquina virtual do azk-agent.

Para evitar que para cada `azk app` seja feito um novo compartilhamento e montagem, o azk usa uma estratégia onde na sua instalação é definido uma pasta base onde todos as aplicações que você deseja desenvolver com azk devem estar, dai em diante ele cuida do processo de `resolver` o endereço desta pasta dentro da máquina virtual.

Para customizar essa pasta basta definir a variável de ambiente `AZK_APPS_PATH` antes de executar o processo de instalação do azk.

## Installation

Todo o processo de provisionamento e configuração do ambiente para execução das aplicações se dá dentro de uma máquina virtual. Atualmente essa máquina virtual é administrada pelo aplicativo [Vagrant](http://www.vagrantup.com), que é requisito para uso do azk.

### Requirements

* Linux or Mac OS X (Windows: planned)
* [Vagrant](http://www.vagrantup.com)
* Internet connection (provision process)
* git

### Basic GitHub Checkout

1. Check out ask into ~/.azk.

```bash
$ git clone https://github.com/azukiapp/azk.git ~/.azk
```

2. Configure azk-agent ip

Para que o azk tenha acesso ao `azk-agent` é necessário definir um ip para máquina virtual, este ip sera usado para estabelecer uma rede privada entre a máquina onde o azk esta instalado o a máquina virtual onde o `azk-agent` é executado.

```bash
$ echo '192.168.115.4 azk-agent` | sudo tee -a /etc/hosts 
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

