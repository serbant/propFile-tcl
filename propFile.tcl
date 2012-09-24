# 
###############################################################################
#package propFile provides facilities to manipulate Java style .properties 
#files
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


package require fileutil
package require Itcl
package provide propFile 0.0.1

itcl::class propFile {
    
    public variable propertiesFile        "" 
    public variable isEmptyPropertiesFile 1
    
    private variable m_osFilePathFragment ""
    private variable m_ext                "\.properties"
    private variable m_propFileHeader     "# properties file\n
					   # acceptable entries:\n
					   # propertyKey=propertyValue\n
					   # propertyKey = property Value\n
					   # propertyKey : propertyValue\n
					   # etc.\n"
    private variable m_listProps          [list]
    private variable m_arrayPropsValues
    private variable m_defaultSeparator   " = "
    private variable m_listSeparators     [list "\\s+" "=" ":"]
    
    constructor {args} {
	if {[string match $tcl_platform(platform) "unix"]} {
	    set m_osFilePathFragment "$env(HOME)/\."
	}
	if {[string match $tcl_platform(platform) "windows"]} {
	    set m_osFilePathFragment "$env(appdata)/"
	}
	eval configure $args
	if {[existsPropFile $propertiesFile]} {
	    hasPropertiesPropFile
	} else {
	    writeEmptyPropFile
	}
    }
    
    destructor {}
    
    public method getProperties {                {fileName $propertiesFile}                               }
    public method getProperty   {key             {fileName $propertiesFile}                               }
    public method setProperties {arrayKeysValues {fileName $propertiesFile} {fileHeader $m_propFileHeader}}
    public method setProperty   {listKeyValue    {fileName $propertiesFile}                               }
    
    private method existsPropFile        {fileName}
    private method hasPropertiesPropFile {        }
    private method writeEmptyPropFile    {        }
	
}

itcl::configbody propFile::propertiesFile {
    if {[string length $propertiesFile] eq 0} {
	error "-propertiesFile must be specified"
    } else {
	if {[string match $tcl_platform(platform) "windows"]} {
	    if {[regexp {[\?\:\*\"\<\>\|]} $propertiesFile]} {
		error "-propertiesFile cannot contain any of the following characters \? \: \* \" \< \>"
	    }
	}
    }
}

itcl::body propFile::existsPropFile {fileName} {
    
    set listLocations [list [fileutil::fullnormalize [fileutil::lexnormalize $fileName]]
			    [fileutil::fullnormalize [fileutil::lexnormalize "[pwd]/$fileName"]]
			    [fileutil::fullnormalize [fileutil::lexnormalize "$m_osFilePathFragment$fileName/$fileName"]]
			    [fileutil::fullnormalize [fileutil::lexnormalize "$m_osFilePathFragment$fileName/$fileName/\.properties"]]
			    [fileutil::fullnormalize [fileutil::lexnormalize "$m_osFilePathFragment$fileName/$fileName/\.config"]]
			    [fileutil::fullnormalize [fileutil::lexnormalize "$m_osFilePathFragment$fileName/$fileName/\.cfg"]]
		      ]
    set listErrors    [list]
    
    foreach propsFile $listLocations {
	
	if {[fileutil::test $propsFile efr errorPropFile]} {
	    set propertiesFile $propsFile
	    unset listErrors
	    return -code ok 1
	} else {
	    lappend listErrors $errorPropFile
	}
    }
    
    return -code ok 0
}

itcl::body propFile::hasPropertiesPropFile {} {
    set props [fileutil::cat $propertiesFile]
    # regsub out all the comment lines
}

itcl::body propFile::writeEmptyPropFile {} {
    fileutil::writeFile $propertiesFile
}


itcl::body propFiles::propsWrite { props } \
{
    
}