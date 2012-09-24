#!/bin/sh
# the next line restarts using wish \
exec tclsh86 "$0" ${1+"$@"}

###############################################################################
#robodoc exec - Batch convert pdf files to jpg images
#Copyright (C) 2010  Serban Teodorescu
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

set roboBinary "C:/robodoc-4.99.36/robodoc-4-99-36.exe"
set roboSrc "--src /users/serban/scripting.workspace/pdf-jpeg-converter-tcl"
set roboDoc "--doc /Users/serban/scripting.workspace/pdf-jpeg-converter-tcl/docs"
set roboSwitches "--multidoc --html --index --nopre --toc"

exec -ignorestderr -- $roboBinary $roboSrc $roboDoc $roboSwitches
