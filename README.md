# opencode-sandbox

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)

A lightweight, open-source sandbox to run **opencode** securely inside Docker for linux users.

---

## 📌 Overview

`opencode-sandbox` provides an isolated environment for running opencode in a controlled and reproducible way. By leveraging Docker, all execution happens inside a sandbox, minimizing risks to your host system.

The project runs opencode inside a Docker container with a mapped home directory.

---

## 🚀 Quick Start

```bash
# get this repo
git https://github.com/arezi/opencode-sandbox.git

# build image local
docker build -t opencode-sandbox .

# run it simple to try it out
docker run --rm -it opencode-sandbox
```


Or run with save state (opencode configs) in your real project.

```bash
cd <my directory project>

docker run --rm -it 
  -v ~/.opencode_sandbox_home:/opencode \
  -v "$(pwd):$(pwd)" --workdir "$(pwd)" \
  opencode-sandbox
```

The `docker run --rm ` is not a good option to a real use. However is available the `opencode-sandbox.sh` script which manager the container instance and allow config environments.

It can be associated with an alias in the `.profile` file.

```bash
alias opencode="bash <this local repo>/opencode-sandbox.sh"
```

Now you can run `opencode` (or another alias name) in your project directory.


---

## 🎯 Motivation

While solutions like Docker Sandboxes exist, they typically require **Docker Desktop**.

This is a problem for many Linux users who:

- Prefer native Docker Engine
- Avoid heavy GUI-based tooling
- Want full control over their environment

`opencode-sandbox` is designed to be:

- 🪶 Lightweight
- 🐧 Linux-first
- 🔧 CLI-native
- 🔒 Security-focused

No Docker Desktop required — just plain Docker.

---

## 🔐 Why Sandbox AI Tools?

AI tools may:

- Execute generated code
- Install dependencies
- Modify files

Without isolation, this can lead to:

- ❌ File corruption or deletion
- ❌ Execution of unsafe code
- ❌ Polluted development environments

Using Docker sandboxing ensures:

- ✅ Host system protection
- ✅ Isolated execution
- ✅ Reproducible environments


---

### Bash Mode

After you have created the alias for the script you can call some special parameters like `bash` to start bash terminal in your container.

```bash
opencode bash
```

It can be useful for:

- Installing tools (node, python) with `asdf` or `sudo apt install`
- Setup your git (or copy your host .gitconfig to .opencode_sandbox_home/)
- Manual run a server, or debugging
- Manual setup


---

## 🔧 Installing tools

You can prompt to opencode to "install with asdf the nodejs 22".

Or inside container:

```bash
## example: install nodejs
asdf plugin add nodejs       # add nodejs plugin
asdf list all nodejs 24      # list all sub-versions of nodejs 24 
asdf install nodejs 24.14.1  # install a specific version
asdf set nodejs 24.14.1      # set specific version to the current project
asdf set -u nodejs 24.14.1   # set specific version as a default to user
```

You can install Node.js, Python, Java, mvn, or more than 800 [plugins](https://github.com/asdf-vm/asdf-plugins?tab=readme-ov-file#plugin-list)

```bash
asdf plugin list all         # list all plugins
```

---

## 💾 Persistent Home

The default directory for persistent home is `~/.opencode_sandbox_home`

Stores:

- opencode config and Sessions
- Installed tools
- Configurations

Reset environment, just delete it. `rm -r ~/.opencode_sandbox_home`

You can configure a specific home directory for your alias with `OPENCODE_SANDBOX_HOME` variable. ex:
```bash
alias opencode="OPENCODE_SANDBOX_HOME=/your/custom/opencode_sandbox_home  bash <this local repo>/opencode-sandbox.sh"
```

---

## Allowed Directory projects

By default, one Docker instance is created per project directory. However, you can use the same Docker instance for a workspace with multiple projects (ex: `~/MyProjects`). So you can configure it in your alias.

```bash
alias opencode="OPENCODE_SANDBOX_ALLOWED_DIR=~/MyProjects  bash <this local repo>/opencode-sandbox.sh"
```

This also will prevent you from running opencode unintentionally in other directories.


---

## Variables 

Variables to script.
- `OPENCODE_SANDBOX_HOME` - home persistense directory 
- `OPENCODE_SANDBOX_ALLOWED_DIR` - your projects workspace/directory
- `OPENCODE_SANDBOX_IMAGE_DOCKER` - custom image to docker
- `OPENCODE_SANDBOX_CONTAINER_NAME` - set a container name (by default is 'opencode' with a hash of your workspace directory)


---

## Limitations

Currently, some features are not supported:
- `/voice` command

---

## 🤝 Contributing

PRs and issues are welcome!

---

## 📄 License

MIT License
