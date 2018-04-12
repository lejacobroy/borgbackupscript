#!/bin/sh
cp /etc/rc.local /home/pi/Backups/$(date +%Y%m%d).rc.local
crontab -l > /home/pi/Backups/$(date +%Y%m%d).crontab
dpkg --get-selections > /home/pi/Backups/$(date +%Y%m%d).Package.list

REPOSITORY=/home/pi/dataPod1/PiBackups

#Bail if borg is already running, maybe previous run didn't finish
if pidof -x borg >/dev/null; then
    echo "Backup already running"
    exit
fi

# Setting this, so you won't be asked for your repository passphrase:
export BORG_PASSPHRASE='123412699Quebec'
# or this to ask an external program to supply the passphrase:
export BORG_PASSCOMMAND='pass show backup'

# Backup all of /home and /var/www except a few
# excluded directories
borg create -v --stats                          \
    $REPOSITORY::'{hostname}-{now:%Y-%m-%d}'    \
    /home/pi                                    \
    --exclude '/home/pi/.cache'                 \
    --exclude '/home/pi/dataPod1'               \

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machine's archives also.
borg prune -v --list $REPOSITORY --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6