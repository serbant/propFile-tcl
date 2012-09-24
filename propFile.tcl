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
    public method getProps                {} {return $m_listPropsValues}
    public method getPropKeys             {} {return $m_listProps}
    public method getPropFile             {} {return $m_propertiesFile}
    
    # public methods
    public method getProperty             {key}
    public method setProperties           {listKeysValues {fileHeader ""}}
    public method setProperty             {listKeyValue}
    public method setSkelProperties       {{fileHeader ""}}
    
    # private methods
    private method isProperties           {propertiesFile {force 0}}
    private method hasProperties          {propertiesFile}
    private method getProperties          {propertiesFile}
    private method defaultFileHeader      {}
    private method writePropFile          {}
	
    # public variables
    public variable propertiesFile        ""
    public variable force                 0
    
    # private variables
    private variable m_propertiesFile     ""
    private variable m_isProps            0
    private variable m_hasProps           0
    private variable m_osFilePathFragment ""
    private variable m_ext                "\.properties"
    private variable m_propFileHeader     ""
    private variable m_listProps          ""
    private variable m_listPropsValues    ""
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
    
    if {[string length [string trim $propertiesFile]] == 0} {
	error "-propertiesFile cannot be empty"
    }
    
    eval configure $args
    
    set m_propFileHeader [defaultFileHeader]
    
    if { [isProperties $propertiesFile $force] } {
	file copy -force $m_propertiesFile \
			"$m_propertiesFile\.[clock format \
					[clock seconds] -format {%y%m%d%H%M%S}]"
	hasProperties $m_propertiesFile
    }
    # remove next line when done debugging
    # puts "===>\nchecking variables at the end of the constructor:\n \
	  propertiesFile: $m_propertiesFile\n \
	  m_isProps: $m_isProps\n \
	  m_hasProps: $m_hasProps\n \
	  m_listProps: [split $m_listProps]\n \
	  m_listPropsValues: [split $m_listPropsValues]\n<==="
    
}

itcl::body propFile::isProperties {propertiesFile {force 0}} {
    
    if { $force } {
	set m_propertiesFile $propertiesFile
	
	if {[fileutil::test $propertiesFile efr errorPropFile]} {
	    set m_isProps 1
	    return -code ok 1
	    
	} else {
	    set m_isProps 0
	    return -code ok 0
	}
    }
    
    set listLocations [list [fileutil::fullnormalize [fileutil::lexnormalize \
			    $propertiesFile]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
			    "[pwd]/$propertiesFile"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
		      "$m_osFilePathFragment$propertiesFile/$propertiesFile"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
	  "$m_osFilePathFragment$propertiesFile/$propertiesFile\.properties"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
	      "$m_osFilePathFragment$propertiesFile/$propertiesFile\.config"]] \
			    [fileutil::fullnormalize [fileutil::lexnormalize \
		 "$m_osFilePathFragment$propertiesFile/$propertiesFile\.cfg"]]]
    
    foreach propsFile $listLocations {
	if {[fileutil::test $propsFile efr errorPropFile]} {
	    set m_propertiesFile $propsFile
	    set m_isProps 1
	    return -code ok 1
	}
    }
    
    set m_propertiesFile \
		    "$m_osFilePathFragment$propertiesFile/$propertiesFile$m_ext"
    set m_isProps 0
    return -code ok 0
    
}

itcl::body propFile::hasProperties {propertiesFile} {
    
    set props [getProperties $propertiesFile]
    
    # are there any properties left? if not, let's bail
    if {[string length [string trim $props "# ! \t \n"]]} {
	set m_hasProps 1
	return -code ok 1
    }
    
    set m_hasProps 0
    
    return -code ok 0
    
}

itcl::body propFile::getProperty {key} {
    
    if !{$m_hasProps} {
	return -code ok -1; #"no properties in file $m_propertiesFile"
    }
    
    if {[lsearch -exact $m_listProps $key] == -1} {
	return -code ok 0; #"no property $key in file $m_propertiesFile"
    }
    
    array set arrPropsVals $m_listPropsValues
    return -code ok $arrPropsVals($key)
}

itcl::body propFile::getProperties {propertiesFile} {
    
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
    
    foreach pair [split $props \n] {
	
	# - if we have escaped property keys, we need to start looking for the
	# index of the separator beyond the index of the last escaped char
	# - it will work if we escape using Tcl style "\\"
	# - the starting index to look for a separator using string first
	# would the last index associated with an \\ + 1 as returned by
	# string last
	
	if {[string length [string trim $pair "\t \= \:"]] == 0} {continue}
	
	set idxStartFirst 0
	set pair [string trim $pair]
	set pair [string map {"\\ " "" "\\=" "" "\\:" "" "\\" ""} $pair]
		
	set listIdx [lsort -integer -increasing \
			   [list [string first " " $pair $idxStartFirst] \
				 [string first "\t" $pair $idxStartFirst] \
				 [string first "=" $pair $idxStartFirst] \
				 [string first ":" $pair $idxStartFirst]]]
	
	if {[lindex $listIdx 0] == -1} {
	    if {[lindex $listIdx 1] == -1} {
		if {[lindex $listIdx 2] == -1} {
		    if {[lindex $listIdx 3] == -1} {
			set idxSeparator -1
			lappend listProps [string trim $pair] ""
			#puts "listProps is: $listProps"
			continue
		    } else {
			set idxSeparator [lindex $listIdx 3]
		    }
		} else {
		    set idxSeparator [lindex $listIdx 2]
		}
	    } else {
		set idxSeparator [lindex $listIdx 1]
	    }
	} else {
	    set idxSeparator [lindex $listIdx 0]
	}
	lappend listProps \
		 [string trim [string range $pair 0 $idxSeparator] "\= \: \t"] \
		 [string trim [string range $pair $idxSeparator end] "\= \: \t"]
	
    }
    
    set m_listPropsValues $listProps
    array set arrPropsValues $m_listPropsValues
    set m_listProps [array names arrPropsValues]
    
    return -code ok $m_listPropsValues
	    
}

itcl::body propFile::setSkelProperties {{fileHeader ""}} {
    
    if {$m_isProps} {error "properties file exists already: $m_propertiesFile"}
    
    if {[string length $fileHeader]} {
	set fileHeader "#$fileHeader"
	regsub -all {\n} $fileHeader "\n#" fileHeader
	set fileHeader "$fileHeader\n"
    } else {
	set fileHeader $m_propFileHeader
    }
    
    if {[catch {fileutil::writeFile $m_propertiesFile $fileHeader} \
						   errorWriteEmptyProps]} then {
	error "Can't create $m_propertiesFile: $errorWriteEmptyProps"
    }
    
    set m_isProps 1
    set m_hasProps 0
    
    return -code ok 1
}

itcl::body propFile::setProperties {listKeysValues {fileHeader ""}} {
    
    if {[string length $fileHeader]} {
	set fileHeader "#$fileHeader"
	regsub -all {\n} $fileHeader "\n#" fileHeader
	set fileHeader "$fileHeader\n"
	set m_propFileHeader $fileHeader
    }    
    
    if {[catch {array set arrKeysValues $listKeysValues} errorProps]} {
	error "List of property value pairs is not properly formatted: \
	  $errorProps.\nUse the rules associated with array set arrayname list"
    }
    
    #set m_isProps 1
    set m_hasProps 1
    set m_listProps [array names arrKeysValues]
    set m_listPropsValues $listKeysValues
    
    writePropFile
    
    return -code ok 1
    
}

itcl::body propFile::setProperty {listKeyValue} {
    if {[llength $listKeyValue] == 0} {
	error "empty property value pair"
    }
    
    if {[llength $listKeyValue] > 2} {
	error "input list can't have more than 2 entries: $listKeyValue"
    }
    
    if {[llength $listKeyValue] == 1} {
	lappend listKeyValue ""
    }
    
    puts "in setProperty, trying to set $listKeyValue"
    set idxKey [lsearch -exact $m_listPropsValues [lindex $listKeyValue 0]]
    if {$idxKey != -1} {
	puts "property exists"
	set idxReplace [expr { 1 + $idxKey } ]
	set m_listPropsValues [lreplace $m_listPropsValues \
			       $idxReplace $idxReplace [lindex $listKeyValue 1]]
	set m_hasProps 1
	return -code ok 1
    }
    
    set m_listPropsValues [concat $m_listPropsValues $listKeyValue]
    array set arrListPropsVals $m_listPropsValues
    set m_listProps [array names arrListPropsVals]
    
    writePropFile
    
    return -code ok 1
}

itcl::body propFile::writePropFile {} {
    if {$m_hasProps && $m_isProps} {
	if {[catch {file copy -force $m_propertiesFile \
		 "$m_propertiesFile\.orig"} errorBackup]} {
	    error "Can't backup the original properties in $m_propertiesFile: \
	    $errorBackup"
	}
    }
    
    if {[catch {fileutil::writeFile $m_propertiesFile $m_propFileHeader} \
	 errorWriteEmptyProps]} then {
	error "Can't create $m_propertiesFile: $errorWriteEmptyProps"
    }
    
    if {[catch {array set arrKeysValues $m_listPropsValues} errorProps]} {
	error "List of property value pairs is not properly formatted: \
	$errorProps.\nUse the rules associated with array set arrayname list"
    }    
    
    foreach key $m_listProps {
	fileutil::appendToFile $m_propertiesFile \
	"$key$m_defaultSeparator$arrKeysValues($key)\n"
    }    
    
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