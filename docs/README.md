# 🛡️ RestorePoint

**RestorePoint** is a complete backup & recovery system for Linux, offering:

- 🔁 Local and remote (Google Drive) backups using BorgBackup
- 🔐 Optional encryption using Age
- ☁️ Rclone integration for seamless cloud sync
- 📊 Full system monitoring via Prometheus and Grafana
- 🧠 Interactive scripts with clean logs
- ⏱️ Cron automation for daily and weekly tasks

---

## 📁 Project Structure

```
RestorePoint/
├── backups/             # Encrypted + local borg repo
├── config/              # Rclone, Prometheus, and Age keys
├── data/                # Files to back up
├── docker/              # Grafana/Prometheus configs
├── docs/                # README & recovery guide
├── logs/                # All log files
├── scripts/             # Core logic: backup, restore, save
├── docker-compose.yml   # Monitoring stack (if Docker is used)
├── Makefile             # Shortcut commands
└── requirements.txt     # (Optional Python dependencies)
```

---

## ⚙️ Prerequisites

Make sure your system has:

```bash
sudo apt update && sudo apt install -y \
  borgbackup \
  age \
  rclone \
  curl \
  make \
  docker.io docker-compose
```

> If Docker doesn't work in your environment, you can install Prometheus & Grafana natively.

---

## 🚀 Quickstart

### 1. Clone the Project
```bash
git clone https://github.com/YOUR_USERNAME/RestorePoint.git
cd RestorePoint
```

### 2. Setup Age Encryption Keys
```bash
age-keygen -o config/age/private.key
cat config/age/private.key | grep "public key" | awk '{print $NF}' > config/age/public.key
```

### 3. Setup Rclone with Google Drive
```bash
rclone config
# Create a remote called "Gdrive" with Google Drive access
```

Then copy your rclone config:
```bash
cp ~/.config/rclone/rclone.conf config/rclone/rclone.conf
```

### 4. Initialize Borg Repository
```bash
borg init --encryption=repokey backups/local/borg-repo
```

---

## 📦 Usage

### 🔁 Create a Backup
```bash
make backup
```
Choose between local only or encrypted + upload to Google Drive.

### ♻️ Restore a Backup
```bash
make restore
```
Choose between local Borg archive or encrypted remote.

### 💾 Save Configs/State
```bash
make save
```
Backs up all config files (rclone, age, prometheus) and uploads them.

### 📊 Launch Monitoring Dashboard
```bash
make monitor
```
Opens Grafana (if Docker or native installed).

### 📂 View Logs
```bash
make logs
```

---

## 🔁 Automate Backups with Cron

```bash
crontab -e
```

Add:
```cron
0 2 * * * bash /home/youruser/RestorePoint/scripts/backup.sh >> /home/youruser/RestorePoint/logs/cron-backup.log 2>&1
0 3 * * 1 bash /home/youruser/RestorePoint/scripts/saving.sh >> /home/youruser/RestorePoint/logs/cron-save.log 2>&1
```

---

## 📈 Monitoring

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000  
  - Username: `admin`  
  - Password: `admin`

Import Dashboard ID `1860` for full system metrics.

---

## 🧪 Tested On
- Ubuntu 20.04 / 22.04
- Debian 11+
- VirtualBox + WSL2

---

## 🔐 Security Notes
- Age keys are stored locally. Do **not** commit `private.key` to Git.
- `.gitignore` is pre-configured to skip sensitive files.
- For production, consider remote backup key rotation & secrets management.

---

## 🙌 Credits
Built with ❤️ using:
- [BorgBackup](https://borgbackup.readthedocs.io/)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Rclone](https://rclone.org/)
- [Grafana](https://grafana.com/)
- [Prometheus](https://prometheus.io/)

---

## 📜 License
MIT — Use it. Improve it. Share it.

---

## ✨ Maintained by
**YOU** — the legend who just built a full backup platform 💪
