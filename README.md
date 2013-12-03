# Azk

It's a tool to developers it assists in creation, maintenance and isolation
of the environments of development. Through the installation of some components
(cli and agent), you will be able easily to create isolated environments to many
projects and stack of languages.

**Features** : provision, monitoring, builtin load balancer, automatic startup script, logging...

## Requirements

* Linux or Mac OS X
* Vagrant (required for Mac OSX or Linux 32)
* Internet connection (provision process)
* git

### OS dependencies:

* Install [vagrant](http://www.vagrantup.com)
* Install [docker](http://docker.io) (Linux only)

### Install

1. clone repo

```bash
$ git clone https://github.com/azukiapp/azk.git ~/.azk
$ cd ~/.azk
```

3. adding in shell profile (ex: ~/.bash_profile)

```bash
# Azk
export  AZK_AGENT_IP="192.168.100.1"
export AZK_APPS_PATH=~/Sites
if [ -d ~/.azk/bin/azk ]; then
  export PATH=~/.azk/bin:$PATH
  eval "$(azk sh-init -)"
fi
```

```bash
$ source ~/.bash_profile
```

2. adding azk-agent in /etc/hosts

```bash
$ echo "$AZK_AGENT_IP azk-agent" | sudo tee -a /etc/hosts
```

3. run azk-agent

```bash
$ make install
```
6. enjoy

```bash
$ azk help
```

## Usage/Features

```bash
$ azk init [project] [--box "azukiapp/ruby#0.1.0"] # Create a Azkfile.json

# Run a specific command
$ azk exec -i /bin/bash           # Run bash
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

