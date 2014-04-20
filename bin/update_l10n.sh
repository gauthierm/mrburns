#!/bin/bash

source /data/venvs/mrburns/bin/activate

svn up locale

REV_FILE=".locale_revision"
test ! -e $REV_FILE && touch $REV_FILE

locale_revision=$(cat $REV_FILE)
new_revision=$(svn info locale | grep "Revision:")

if [ "$locale_revision" != "$new_revision" ]; then
    echo $new_revision > $REV_FILE
    if dennis-cmd lint locale; then
        python manage.py compilemessages
        sudo supervisorctl restart mrburns
    else
        echo "There is a problem with the .po files in r${new_revision}." | mail -s "Glow l10n error" pmac@mozilla.com
    fi
fi