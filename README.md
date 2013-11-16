# Azk

It's a tool to developers it assists in creation, maintenance and isolation
of the environments of development. Through the installation of some components
(cli and agent), you will be able easily to create isolated environments to many
projects and stack of languages.

**Features** : provision, monitoring, builtin load balancer, automatic startup script, logging...

## Usage/Features

```bash
$ azk init [project] [--box "azukiapp/ruby#0.1.0"] # Create a Azkfile.json

# Run a specific command
$ azk exec /bin/bash              # Run bash in box
$ azk exec gem install rails      # Install rails gem in box

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
$ azk monit                       # Monitor all processes
$ azk web                         # Health computer API endpoint:
                                  # (http://[project].dev.azk.io)
```

## Development Use

### OS dependencies:

* Install [vagrant](http://www.vagrantup.com)

### Install

1. clone this repo

```bash
$ git clone https://github.com/azukiapp/azk.git
$ cd azk
```

3. adding in shell profile (ex: ~/.bash_profile)

```bash
# Azk
export      AZK_ROOT=[azk path]
export  AZK_AGENT_IP="192.168.100.1"
export AZK_APPS_PATH=~/Sites
if [ -d $AZK_ROOT/bin/azk ]; then
  export PATH=$AZK_ROOT/bin:$PATH
  eval "$(azk sh-init -)"
fi
```

```bash
$ source ~/.bash_profile
```

2. run azk-agent

```bash
$ vagrant up
```

3. adding azk-agent in /etc/hosts

```bash
$ echo "$AZK_AGENT_IP azk-agent" | sudo tee -a /etc/hosts
```
	
4. install depedences and check tests

```bash
$ make get-deps
$ make test
```
   
5. enjoy

```bash
$ azk help
```

## License

"Azuki", "Azk" and the Azuki logo are copyright (c) 2013 Azuki Serviços de Internet LTDA.

Azk source code is released under Apache 2 License.

Check LEGAL and LICENSE files for more information.

