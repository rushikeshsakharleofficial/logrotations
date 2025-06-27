# 🌀 Simple Log Rotation Script – Explained for Everyone

## 🧠 What is this script for?

Imagine you have many log files — like digital diaries that your apps write into every day.

These log files:

- grow over time,
- can fill up your disk space,
- become hard to manage manually.

This **script helps clean them up automatically**. It will:

✅ Make a copy of each log file  
✅ Add a date to the filename  
✅ Compress it to save space  
✅ Store it in a neat "archive" folder  
✅ (Optional) Delete really old backups if you ask it to

---

## 🛠️ What do I need?

You need a Linux system with some common tools installed:

- `find`, `awk`, `gzip`, `cp`, `mv`, `date`, `mkdir`, `basename`

The script checks for these automatically. If something is missing, it will let you know.

---

## 📝 What does it actually do? Step by step

Let’s say your log file is:

```
/var/log/apps/server.log
```

Here’s what happens:

1. It makes a **copy** of that file:

```
server.log.20250627
```

2. It **compresses** the copy into a `.gz` file:

```
server.log.20250627.gz
```

3. It **empties** the original log file so your app can continue writing into a fresh one.

4. It **moves** the compressed file to a backup folder like:

```
/var/log/apps/old_logs/20250627/server.log.20250627.gz
```

5. If you use the `-r` option, it **deletes older backup files** that are more than X days old.

---

## 🖥️ How do I use it?

### Basic command

```bash
./global-logrotate.sh -D
```

This will rotate `.log` files from `/var/log/apps` using today’s date.

### Full options explained in plain language:
+---------------------+--------------------------------------------------------------------------+
| Option              | What it does                                                             |
|---------------------|--------------------------------------------------------------------------|
| `-H`                | Use **date + time** like `20250627T12:30:00` in file name                |
| `-D`                | Use **just the date** like `20250627` in file name                       |
| `-p /your/folder`   | Use a **custom folder** instead of `/var/log/apps`                       |
| `-f "*.txt"`        | Rotate `.txt` files instead of `.log` files                              |
| `-r 7`              | Delete rotated files that are older than **7 days**                      |
| `-n`                | **Dry-run** mode — only show what would happen, don’t make any changes   |
+---------------------+--------------------------------------------------------------------------+
---

## 💡 Examples

### 1. Rotate today's `.log` files

```bash
./global-logrotate.sh -D
```

### 2. Rotate `.txt` files in a different folder

```bash
./global-logrotate.sh -p /tmp/logs -f "*.txt" -D
```

### 3. Rotate logs and remove backups older than 5 days

```bash
./global-logrotate.sh -r 5 -D
```

### 4. Try it out safely (no changes will be made)

```bash
./global-logrotate.sh -n -D
```

---

## 📂 Where do my old logs go?

They are stored in a folder like:

```
/var/log/apps/old_logs/20250627/
```

Each file is renamed to include the date and compressed to save space.

---

## 🧽 Why should I use this?

Without log rotation:

- Your disk may fill up.
- Your server may slow down.
- You may lose track of old vs new logs.
- Manually managing logs becomes a hassle.

This script keeps things clean, automatic, and organized.

---

## ✅ Final Notes

- Safe to test: use `-n` for dry-run mode.
- It never deletes anything unless you use `-r`.
- You can run it manually or schedule it daily with `cron`.

---

## 💬 Need help?

If you're unsure how to run it or where your logs are, just show this README to your IT team — they'll help.

---

## 🪪 License

This script is free to use and modify. MIT License.
