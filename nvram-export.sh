#!/bin/sh

# A script to export nvram settings from tomato (and possibly dd-wrt).
# Copyright (C) 2017 Jon Davies
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# we need the nvram command - otherwise we should just give up
hash nvram 2>/dev/null || { echo >&2 "nvram-export requires nvram but it's not installed.  Aborting."; exit 1; }

unset DEBUG
etc=/opt/etc
base=${0##*/}; base=${base%.*}
config=$etc/$base.conf
backupfile=/proc/$$/fd/1

while [[ $# -gt 0 ]] ; do
	key="$1"

	case $key in
		-d|--debug)
			DEBUG=true
			;;
		-c|--config)
			config="$2"
			shift # past argument
			;;
		-h|--help)
			echo "nvram-export [options] [output-filename]"
			echo "  exports nvram variables as a shell script that can be used to reconfigure a router"
			echo ""
			echo "options:"
			echo "  -d | --debug: output debug information on stderr"
			echo "  -c | --config filename: read a list of variables to emit from filename (defaults to $config if it exists)"
			echo "  -h | --help: this help"
			echo ""
			echo "output-filename:"
			echo "  output is written to the specified file."
			echo "  if output filename is not specified, or is specified as '-', then output is written to stdout"
			echo ""
			echo "nvram-export Copyright (C) 2017 Jon Davies"
			echo "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE."
			echo "This is free software, and you are welcome to redistribute it"
			echo "under certain conditions; see LICENSE for details."
			exit 0
			;;
		*)
			# unknown option is assumed to be the output filename
			if [ "$1" != "-" ] ; then
				backupfile="$1"
			fi
		;;
	esac
	shift # past argument or value
done
echo DEBUG=$DEBUG config=$config output=$backupfile

# Edit list below if not using .conf file, it is ignored if .conf file is found
# e.g.
# items='
#  dhcpd_
#  dns_
#  wl[0-9]_security_mode
#  wl[0-9]_ssid
#  wl[0-9]_wpa_psk
# '
items=''

grepstr=$( { [ -r $config ] && cat $config || echo "$items" ; } | sed -e 's/[\t ]//g;/^$/d' | sed ':a;N;$!ba;s/\n/\\\|\^/g')

{
# emit a shell script...
echo "#!/bin/sh"
if [ -z $grepstr ]; then
	echo "# Exporting all nvram variables"
	test $DEBUG && echo "Exporting all nvram variables" >&2
else
	echo "# Exporting selected nvram variables: $grepstr"
	test $DEBUG && echo "Exporting selected nvram variables: $grepstr" >&2
fi
for item in $(nvram show 2>/dev/null | grep "^[^[:space:]]*=" | grep "$grepstr"  | awk -F= "{print \$1}" | sort -u)
do
	# does the item exist?
	if test $(nvram get $item | wc -l) -gt 0 ; then
		test $DEBUG && echo "$item" >&2
		# get the item value, escaping all the single quotes
		item_value="$(nvram get $item | sed s/\'/\\\'/g)"
		# emit an nvram set command, escaped with single quotes
		echo "nvram set ${item}='${item_value}'"
	fi
done
}>"$backupfile"
