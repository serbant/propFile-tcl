#/*doc*/
#<html>
#<body>
#<h1>Package propFile<h1>
#<h2>Class propFile</h2>
#<p>Provides support for Java style .properties files.</p>
#<p>For a detailed specification of these types of files please see \
#<a href="http://java.sun.com/javase/6/docs/api/java/util/ \
#Properties.htmlload(java.io.Reader)">Java properties files</a></p>
#<h3>Requires: </h3>
#<ul>
#<li><a href="http://www.tcl.tk/software/tcltk/choose.html>Tcl</a> 8.4 or \
#higher</li>
#<li>package \
#<a href="http://sourceforge.net/projects/incrtcl/"><b>iTcl</b></a> \
#3.0 or higher. Most Tcl distributions include iTcl</li>
#<li>package <b>fileutil</b>. This package is part of the libary \
#<a href="http://www.tcl.tk/software/tcllib/">tcllib</a> libary. Standard \
#Windows Tcl distirbutions include this library by default</li>
#</ul>
#<h3>Version: </h3>
#<p>0.0.1</p>
#<h3>Limitations: </h3>
#<p>If the property keys contain escaped legal characters: "\ ", "\:", "\=" \
#then the actual content of the file must use a double escape instead of the \
#simple escape. The format of the escape must be "\\ ", "\\:", "\\=". If this \
#format is not respected, the property value pair will be split on the first \
#occurence of any of these sequences: " ", "\ ", "=", "\=", ":", "\:".</p>
#<h3>Public data members:</h3>
#<p><b>propertiesFile type string, mandatory:</b><br>identifies a specific \
#properties file. It can be a fully normalized file name like \
#"/home/user/.someDir/someFile.properties", or just a stand-alone file name. \
#In the latter case the code will look under 
#<ul>
#<li>current path</li>
#<li>$HOME/.$propertiesFile/ on Unix platforms</li>
#<li>%APPDATA%/$propertiesFile/ on Windows platforms</li>
#</ul>
#for a file named
#<ul>
#<li>$propertiesFile</li>
#<li>$propertiesFile.properties</li>
#<li>$propertiesFile.config</li>
#<li>$propertiesFile.cfg</li>
#</ul></p>
#<p><b>force type boolean, optional, default False:</b><br>decides whether the \
#value of $propertiesFile will be taken literally or whether it will be \
#subject to the guessing algortihm described above.</p>
#<h3>Public methods: </h3>
#<p><b>isProps {} returns boolean:</b><br>accessor returns True if the file \
#referenced by $propertiesFile exists</p>
#<p><b>hasProps {} returns boolean</b><br>accessor returns True if the file \
#referenced bu $propertiesFile contains at least one valid property. Does not \
#guarantee that the property value or values actually exist</p>
#<p><b>getProperties {} returns associative array</b><br>returns an array with \
#all the properties found in $propertiesFile using the property name as index \
#and the property value as the element</p>
#<p><b>getProperty {string key} returns string</b><br>takes a property key as \
#argument and returns the property value</p>
#<p><b>setProperties {array propValPairs {string fileHeader defaultHead}}:</b> \
#<br>will create a .properties file under the platform specific application \
#configuration path named $propertiesFile.properties. It takes an array of \
#property values indexed by property name as a mandatory argument and an \
#optional string that will be used as the file header for said .properties \
#file</p>
#<p><b>setProperty {list propValPair}:</b><br>will create the property prop \
#with the value Val in the $propertiesFile. If the property key already exists \
#in the file its value will be replaced with the new Val value</p>
#<p><b>setSkelProperties {}:</b><br>will create a $propertiesFile.properties \
#on the system specific application configuration path. This file will contain \
#no properties, only a default file header</p>
#<h2>Licensing</h2>
#<p>
#package propFile provides facilities to manipulate Java style .properties \
#files<br><br>
#Copyright (C) 2010  Serban Teodorescu<br><br>
#This program is free software: you can redistribute it and/or modify it under \
#the terms of the GNU General Public License as published by the \
#Free Software Foundation, either version 3 of the License, or (at your \
#option) any later version.<br><br>
#This program is distributed in the hope that it will be useful, but WITHOUT \
#ANY WARRANTY; without even the implied warranty of #MERCHANTABILITY or \
#FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for \
#more details.<br><br>
#You should have received a copy of the GNU General Public License along with \
#this program.  If not, see \
#<a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses</a>.</p>
#</body>
#</html>
#/*enddoc*/

package require fileutil
package require Itcl
package provide propFile 0.0.1

itcl::class propFile {
	
    constructor                           {propertiesFile args} {}
    
    destructor                            {}
    
    # accessor methods
    public method isProps                 {} {return $m_isProps}
    public method hasProps                {} {return $m_hasProps}
    
    # public methods
    public method getProperties           {}
    public method getProperty             {key}
    public method setProperties           {arrayKeysValues {fileHeader ""}}
    public method setProperty             {listKeyValue}
    public method setSkelProperties       {}
    
    # private methods
    private method isProperties           {}
    private method hasProperties          {}
    private method defaultFileHeader      {}
	
    # public variables
    public variable propertiesFile        ""
    public variable force                 0
    
    # private variables
    private variable m_isProps            0
    private variable m_hasProps           0
    private variable m_osFilePathFragment ""
    private variable m_ext                "\.properties"
    private variable m_propFileHeader     ""
    private variable m_listProps          ""
    private variable m_arrayPropsValues   ""
    private variable m_defaultSeparator   ": "
    
    
}

itcl::configbody propFile::propertiesFile {
    if {[string length $propertiesFile] == 0} then {
	error "-propertiesFile must be specified"
    } else {
	if {[string match $tcl_platform "windows"]} then {
	    if { [regexp {[\?\:\*\"\<\>\|]} $propertiesFile] > 0} then {
		error "-propertiesFile cannot contain any of the following \
		       characters \? \: \* \" \< \>"
	    }
	}
    }
    
}

itcl::body propFile::constructor {propertiesFile args} {

    upvar #0 tcl_platform(platform) tcl_platform
    
    if {[string match $tcl_platform "unix"]} {
	upvar #0 env(HOME) envHOME
	set m_osFilePathFragment "$envHOME/\."
    }
    
    if {[string match $tcl_platform "windows"]} {  
	upvar #0 env(appdata) envAPPDATA        
	set m_osFilePathFragment "$envAPPDATA/"
    }
    
    if {[string trim [string length $propertiesFile]] == 0} {
	error "-propertiesFile cannot be empty"
    }
    
    eval configure $args
    
    set m_propFileHeader [defaultFileHeader]
    
    if { [isProperties] } {
	hasProperties
    }
    
}

itcl::body propFile::isProperties {} {
    
    if { $force } {
	if {[fileutil::test $propertiesFile efr errorPropFile]} {
	    return -code ok 1
	    set m_isProps 1
	} else {
	    error $errorPropFile
	}
    }
    
    set listLocations [list [fileutil::fullnormalize [fileutil::lexnormalize \
			    $propertiesFile]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
			    "[pwd]/$propertiesFile"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
			    "$m_osFilePathFragment$fileName/$propertiesFile"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
	  "$m_osFilePathFragment$propertiesFile/$propertiesFile\.properties"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
	      "$m_osFilePathFragment$propertiesFile/$propertiesFile\.config"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
		 "$m_osFilePathFragment$propertiesFile/$propertiesFile\.cfg"]]]
    set listErrors [list]
    
    foreach propsFile $listLocations {
	
	if {[fileutil::test $propsFile efr errorPropFile]} {
	    set propertiesFile $propsFile
	    set m_isProps 1
	    return -code ok 1
	} else {
	    lappend listErrors $errorPropFile
	}
    }
    
    set m_isProps 0
    return -code ok 0
    
}

itcl::body propFile::hasProperties {} {
    
    set props [getProperties]
    
    # are there any properties left? if not, let's bail
    if {[string length [string trim $props "# ! \t \n"]]} {
	set m_hasProperties 1
	return -code ok 1
    }
    
    set m_hasProperties 0
    
    return -code ok 0
    
}

itcl::body propFile::getProperties {} {
    
    set listProps ""
    
    if {[catch {set props [fileutil::cat $propertiesFile]} errorProperties]} {
	# TODO: need to decide on the best way to handle errors in class methods
	# for the moment
	error "problem with the properties file: $errorProperties"
	
    }
    
    # to clean up the split property values use
    regsub -all {\s\\\n[\t]*} $props { } props
    
    # to clean up comments use
    regsub -all {[#!].*?\n} $props {} props
    
    puts "props is: $props"
    
    foreach pair [split $props \n] {
	
	# if we have escaped property keys, we need to start looking for the
	# index of the separator beyond the index of the last escaped char
	# hmmm, it looks like it will work if we escape using Tcl style "\\"
	# so the starting index to look for a separator using string first
	# would the last index associated with an \\ + 1 as returned by
	# string last; let's check
	
	puts "propValue is: $pair"
	set idxStartFirst 0
	if {[string last "\\" $pair] > -1} {
	    set idxStartFirst [expr { 1 + [string last "\\" $pair] }]
	}
	set idxSeparator [expr {min([string first " " $pair $idxStartFirst], \
				    [string first "=" $pair $idxStartFirst], \
				    [string first ":" $pair $idxStartFirst])}]
	
	lappend listProps [string trim [string range $pair 0 $idxSeparator]] \
			  [string trim [string range $pair $idxSeparator end]]
    }
    
    array set m_arrayPropsValues $listProps
    
    set m_listProps [array names m_arrayPropsValues]
    
    return -code ok $m_arrayPropsValues
	
	
}

itcl::body propFile::setSkelProperties {} {
    
    if {[catch {fileutil::writeFile $propetiesFile $m_propFileHeader}\
						   errorWriteEmptyProps]} then {
	error "Can't create $propertiesFile: $errorWriteEmptyProps"
    }
    
    set m_isProps 1
    set m_hasProps 0
    
    return -code ok 1
}

itcl::body propFile::defaultFileHeader {} {
    
    append fileHeader "# file created by [uplevel #0 {info script}]\n" \
		      "# on [clock format [clock seconds] \
						-format {%A, %B %d, %y}]\n" \
		      "# at [clock format [clock seconds] \
						-format {%H:%M:%S}]\n" \
		      "# properties file\n" \
		      "# acceptable entries:\n" \
		      "# propertyKey=propertyValue\n" \
		      "# propertyKey = property Value\n" \
		      "# propertyKey : propertyValue\n" \
		      "# etc.\n" 

    return -code ok $fileHeader
}