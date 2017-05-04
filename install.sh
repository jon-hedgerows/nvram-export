#!/bin/sh
TARGET=/opt/bin/nvram-export

# emulate install -m 755
cp nvram-export.sh $TARGET
chmod u=rwx,go=rx $TARGET
