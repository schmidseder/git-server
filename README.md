# git-server
A very simple Docker configuration for setting up a GIT server via SSH.

## Purpose
This setup is intended for users who want to host their own Git server to manage repositories over SSH.

---  

**Note:** Replace all placeholders such as __your-name__, __your-domain__ and others with your actual values. Additionally, depending on your environment, you might need to prepend `sudo` to Docker commands for them to work correctly. 

## Configuration

### 1. Client Side:
Generate a new SSH key (if you don’t already have one):
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your-name@your-domain"
```

Print out the public key for later use:
```bash
echo "AUTHORIZED_KEYS=\"`cat ~/.ssh/id_ed25519.pub`\""
```

---

### 2. Server Side:
Clone the repository and configure environment variables:
```bash
git clone https://github.com/schmidseder/git-server.git
cd git-server
cp .env.example .env
```

Copy the **output** (your public SSH key) from the earlier `echo` command on the client side into the `.env` file. For example:
```
AUTHORIZED_KEYS="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOo/nJOBIEQGxj5CYyhHaRr0jhuvpYC1E0L6HQlMhvRp your-name@your-domain"
```

Then, start the container:
```bash
docker compose build
docker compose up -d
```

Create a bare repository on the server:
```bash
docker exec --user git -it git-server git init --bare /repos/demo.git
```

---

### 3. Client Side:
Set up SSH access in the file `~/.ssh/config`:
```bash
Host git-server
    Hostname your-domain
    User git
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Clone the repository:
```bash
git clone git@git-server:/repos/demo.git
```

Alternatively (without SSH configuration in the `~/.ssh/config` file):
```bash
git clone ssh://git@your-domain:2222/repos/demo.git
```

---

## License
[MIT License](LICENSE)
```