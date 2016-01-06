#Devnode
###A Tool for scaffolding and managing Dev Environments

This tool very much represents a project that "scratches a personal itch", and as such is very opinionated about the tools you use for building development environments.

##Background
In order to describe what Devnode does, I will first describe the components involved a typical development environment of mine:
* Each project that I work on is isolated within its own virtual machine. These VMs are created using Vagrant.
* Each VM has Docker installed
* Each project typically comprises of multiple docker containers running within a single VM.
* Commonly the docker containers will support SSH connections.
* The multi-container Docker application is defined within a single `fig` file
* I run a private Docker registry within a VM, to store and distribute Docker images to my other VMs

##The itch
As the above illustrates setting up a new development environment involves a combination of tools and repetitive tasks. My vision for Devnode is to provide a tool that masks the complexity and provides a simple interface for building and managing development environments (dev-nodes).

##A work in progress
This project is very much a work in progress, but I'm looking to build it in a fashion that will ensure that it provides value to me from day one. This may involve starting with features that make large assumptions about my environment; my motivation being that I don't want to become preoccupied with configuration features up front. But as time progresses I will aim to add configuration options, making the tool less opinionated about its environment.

##How it works
Devnode is built using Elixir and structured as an umbrella project; a single repository comprising multiple OTP applications. One of these applications is `devnode_client` which is built as an escript and acts as a single command line interface to the OTP system as a whole.

##Starting the system
Currently Devnode requires you to manually start the `dnmonitor` node. This can be done with the following command:

```bash
elixir --detached --name dnmonitor@127.0.0.1 -S mix run --no-halt

```

##Scaffolding the Docker registry
Behind the scenes Devnode runs a private Docker registry, in a separate VM. The purpose of this registry is to store and make available Docker images to the user's development environments (nodes). The registry is scaffolded using the `build-registry` command. Typically this command will only be run when the user first installs Devnode. However the registry can be re-built by passing the `--force` option to the `build-registry` command.
```bash
devnode_client build-registry -f

```

##Scaffolding a Devlopment environment
A new development environment is scaffolded using the `build` command. This command requires the user to assign a `name` to their node. The `build` command is interactive, prompting the user to specify the type of environment they would like to scaffold. The choice of available environments is based on the images that are available in the private Docker registry. Once the environment is selected the node is auto assigned an IP address and the project is scaffold.
```bash
devnode_client build -n=project_x

```

##Runtime config
Certain commands require configuration, this is done through the use of a `devnoderc` file that should be located within the current/working directory. This runtime config file contains settings such as the location on disc of the Docker registry. A template for the `devnoderc` file can be generated using the following command:
```bash
devnode_client generate runtime-config

```

##Listing Development environments
To view the credentials of all nodes that have been built the user can run the `list` command:
```bash
devnode_client list

```
