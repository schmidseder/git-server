# git-server
Very simple docker configuration for a GIT server via SSH.

# Configuration

## 1. Client side:
```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your-name@your-domain"  

echo "AUTHORIZED_KEYS=\"`cat ~/.ssh/id_ed25519.pub`\""
````
## 2. Server side:
```
git clone https://github.com/schmidseder/git-server.git
cd git-server
cp .env.example .env
```
Copy the output (=your public key) from the echo command on the client into the .env file - something like this:
```
AUTHORIZED_KEYS="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOo/nJOBIEQGxj5CYyhHaRr0jhuvpYC1E0L6HQlMhvRp your-name@your-domain"
```
```
docker compose build
docker compose up -d
```
Create a bare repository:  
```
docker exec --user git -it git-server git init --bare /repos/demo.git
```
## 3. Client side:
configure your host in the ssh config file ~/.ssh/config:
```
Host git-server
    Hostname your-domain
    User git
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```
Clone the repository:
```
git clone git@git-server:/repos/demo.git
```