# nvram-export

A script to export nvram settings from tomato (and possibly dd-wrt).

    nvram-export [options] [output-filename]

exports nvram variables as a shell script that can be used to reconfigure a router.

options:

 - -d | --debug
   output debug information on stderr
 - -c | --config filename
   read a list of variables to emit from filename
   (defaults to /opt/etc/nvram-export.conf if it exists)
 - -h | --help
   shows help

output-filename:

 - output is written to the specified file.
 - if output-filename is not specified, or is specified as '-'
   then output is written to stdout

nvram-export
A script to export nvram settings from tomato (and possibly dd-wrt).
Copyright (C) 2017 Jon Davies

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
