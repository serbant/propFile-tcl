package require fileutil
package require Itcl
package provide propFile 0.0.2

#****c* propFile.package/propFile
# NAME
#   class propFile
# SYNOPSIS
#   propFile props -propertiesFile string -force boolean
# DESCRIPTION
#   package propFile provides support for Java style properties file in Tcl
#   
#   requires Itcl
#   
#   requires fileutil
#   
#   for a detailed specification of these types of files please see 
#   http://java.sun.com/javase/6/docs/api/java/util/#Properties.htmlload(java.io.Reader)
#
#   requires:
#   - Tcl 8.3 or higher
#   - package iTcl 3.0 or higher. most Tcl distributions include iTcl
#   - package fileutil. this package is part of the tcllib libary available from
#     <http://www.tcl.tk/software/tcllib/>. standard Windows Tcl distributions 
#     include this library by default
#
#   Version: 0.0.2
# INPUT
#   args:
#   - propertiesFile type string mandatory
#   - force type boolean optional default False
# NOTES
#   If the property keys contain escaped legal characters: "\ ", "\:", "\=" 
#   then the actual content of the file must use a double escape instead of the
#   simple escape. The format of the escape must be "\\ ", "\\:", "\\=". If this
#   format is not respected, the property value pair will be split on the first 
#   occurence of any of these sequences: " ", "\ ", "=", "\=", ":", "\:".
#
#   If the properties file referenced by the propFile object exists, it will be
#   tagged with the date and time and backed up during the object intialization
#   with a date-time extension.
#
#   Every time the properties file referenced by the propFile object changes
#   during the life of the object, it will be backed up with an .orig extension
#   before the change is applied.
# AUTHOR
#   Serban Teodorescu <serbant@gmail.com>
# COPYRIGHT
#   Copyright (C) 2010  Serban Teodorescu
#
#   This program is free software: you can redistribute it and/or modify it 
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of #MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#   more details.
#
#   You should have received a copy of the GNU General Public License along with
#   this program.  If not, see <http://www.gnu.org/licenses>
#****
itcl::class propFile {
	
    constructor                           {propertiesFile args} {}
    
    destructor                            {}
    
    # accessor methods
    #****m* propFile.package/propFile/isProps 
    # NAME
    #   isProps {} returns boolean
    # DESCRIPTION
    #   accessor method returns True if the file referenced by the propFile
    #   object exists
    #****
    public method isProps                 {} {return $m_isProps}
    
    #****m* propFile.package/propFile/hasProps
    # NAME
    #   hasProps {} returns boolean
    # DESCRIPTION
    #   accessor method returns True if the file referenced by the propFile
    #   object contains at least one valid property. Does not guarantee that the
    #   property value or values actually exist
    #****
    public method hasProps                {} {return $m_hasProps}
    
    #****m* propFile.package/propFile/getProps
    # NAME
    #   getProps {} returns list
    # DESCRIPTION
    #   returns a list suitable as argument for the [array get arrayName $list] 
    #   command with all the properties found in the propFile object
    #****
    public method getProps                {} {return $m_listPropsValues}
    
    #****m* propFile.package/propFile/getPropKeys
    # NAME
    #   getPropKeys {} returns list
    # DESCRIPTION
    #   returns a list with all the property keys found in the propFile object
    #****    
    public method getPropKeys             {} {return $m_listProps}
    
    #****m* propFile.package/propFile/getPropFile
    # NAME
    #   getPropFile {} returns string
    # DESCRIPTION
    #   returns a string containing the normalized full path of the file
    #   referenced in the propFile object
    #****    
    public method getPropFile             {} {return $m_propertiesFile}
    
    # public methods
    #****m* propFile.package/propFile/getProperty 
    # NAME
    #   getProperty {string} returns string
    # DESCRIPITION
    #   takes the property key as argument and returns the property value
    #   will return -1 if the propFile object does not contain any properties
    #   will return 0 if the property does not exist but the propFile object
    #   does contain properties
    #****
    public method getProperty             {key}
    
    #****m* propFile.package/propFile/setProperties 
    # NAME
    #   setProperties {list {string ""}} returns error or 1
    # DESCRIPTION
    #   will set the property value pairs in the propFile object and save them 
    #   to the properties file referenced by the propFile object. will also 
    #   backup the original file
    # ARGUMENTS
    #  - list of property value pairs that must respect the rules associated 
    #    with the [array set ...] command, mandatory argument
    #  - optional string that will be used as the file header for said 
    #    properties file
    #****
    public method setProperties           {listKeysValues {fileHeader ""}}
    
    #****m* propFile.package/propFile/setProperty
    # NAME
    #   setProperty {list} returns error or 1
    # DESCRIPTION
    #   will create/update the property prop specified in the first list
    #   element with the value specified in the second list element
    #   will return errors if the list is empty, has only 1 element, or has
    #   more than 2 elements
    #****
    public method setProperty             {listKeyValue}
    
    #****m* propFile.package/propFile/setSkelProperties 
    # NAME
    #   setSkelProperty {{string ""}} returns error or 1
    # DESCRIPTION
    #   will create the properties file referenced by the propFile object
    #   returns 1 if successfull or error if the file can't be written
    # ARGUMENTS
    #   - string optional, default empty contains the header to be written to
    #     the file
    #****
    public method setSkelProperties       {{fileHeader ""}}
    
    #****m* propFile.package/propFile/deleteProps 
    # NAME
    #   deleteProps {} returns error or 1
    # DESCRIPTION
    #   will delete all the properties from the propFile object and replace the 
    #   properties file referenced by the propFile object with an empty file
    #   returns 1 if successfull or error if the file can't be written
    #****    
    public method deleteProps             {}
    
    # private methods
    private method isProperties           {propertiesFile {force 0}}
    private method hasProperties          {propertiesFile}
    private method getProperties          {propertiesFile}
    private method defaultFileHeader      {}
    private method writePropFile          {}
	
    # public variables
    #****v* propFile.package/propFile/propertiesFile
    # NAME
    #   propertiesFile:
    #   - type string
    #   - mandatory
    # DESCRIPTION
    #   identifies a specific properties file. It can be a fully normalized file 
    #   name like "/home/user/.someDir/someFile.properties", or just a stand-alone 
    #   file name. 
    #
    #   in the latter case the code will look under: 
    #   - current path
    #   - $HOME/.$propertiesFile/ on Unix platforms
    #   - %APPDATA%/$propertiesFile/ on Windows platforms
    #
    #   for a file named:
    #   - $propertiesFile
    #   - $propertiesFile.properties
    #   - $propertiesFile.config
    #   - $propertiesFile.cfg
    #****
    public variable propertiesFile        ""
    
    #****v* propFile.package/propFile/force 
    # NAME
    #   force:
    #   - type boolean
    #   - optional, default False
    # DESCRIPTION
    #   decides whether the value of $propertiesFile will be taken literally or 
    #   whether it will be subject to the guessing algortihm described above.
    #****
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
	fileutil::insertIntoFile $m_propertiesFile 0 \
	    "#file backed up: [clock format [clock seconds] -format \
							{%Y/%m/%d, %H:%M:%S}]\n"
	file copy -force $m_propertiesFile \
			"$m_propertiesFile\.[clock format \
					[clock seconds] -format {%Y%m%d%H%M%S}]"
	hasProperties $m_propertiesFile
    }
    
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
    
    set idxKey [lsearch -exact $m_listPropsValues [lindex $listKeyValue 0]]
    if {$idxKey != -1} {
	set idxReplace [expr { 1 + $idxKey } ]
	set m_listPropsValues [lreplace $m_listPropsValues \
			       $idxReplace $idxReplace [lindex $listKeyValue 1]]
	
    } else {
	set m_listPropsValues [concat $m_listPropsValues $listKeyValue]
	array set arrListPropsVals $m_listPropsValues
	set m_listProps [array names arrListPropsVals]
    }
    
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
    
    if {$m_isProps == 0} {set m_isProps 1}
    if {$m_hasProps == 0} {set m_hasProps 1}
    
    return -code ok 1
    
}

itcl::body propFile::deleteProps {} {
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
    
    set m_listPropsValues ""
    set m_listProps ""
    
    if {$m_isProps == 1} {set m_isProps 0}
    if {$m_hasProps == 1} {set m_hasProps 0}
    
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

