
# this is a gtkwave script

if { ![namespace exists gtkwave] } {
  puts "This script must be read by gtkwave."
  exit 1
}

##
# list all the displayed signal without each vector index:
#
set theDisplayedSignalList [list]
foreach theDisplayedSignal [gtkwave::getDisplayedSignals] {
  set theOpenIndex  [string first "\[" $theDisplayedSignal]
  set theCloseIndex [string first "\]" $theDisplayedSignal]
  set theColonIndex [string first ":"  $theDisplayedSignal]
  #
  if { $theOpenIndex  == -1 ||
       $theCloseIndex == -1 } {
    lappend theDisplayedSignalList $theDisplayedSignal 0
  } elseif { $theOpenIndex  != -1 &&
             $theCloseIndex != -1 &&
             $theColonIndex > $theOpenIndex && $theColonIndex < $theCloseIndex
         } {
    # define the size:
    set up [string range $theDisplayedSignal $theOpenIndex+1  $theColonIndex-1]
    set dw [string range $theDisplayedSignal $theColonIndex+1 $theCloseIndex-1]
    if { $up > $dw } {
      set theSize [expr { $up - $dw }]
    } else {
      set theSize [expr { $dw - $up }]
    }
    lappend theDisplayedSignalList $theDisplayedSignal [expr { $theSize + 1}]
  }
}

##
# prints all signal values:
#
set theText ""
set theMinTime [gtkwave::getMinTime]
set theMaxTime [gtkwave::getMaxTime]
#
foreach { theSignal theSize } $theDisplayedSignalList {
  set theSignalName [lindex [split $theSignal "."] end]
  regsub {\[.*\]} $theSignalName {} theSignalName

  set theSignalChangeList [list]
  foreach { theTime theValue } [gtkwave::signalChangeList $theSignal] {
    if { $theTime < $theMinTime || $theTime > $theMaxTime } {
      continue
    }
    lappend theSignalChangeList $theTime $theValue
  }

  set theAffect "$theSignalName <= "
  for { set i 0 } { $i < [llength $theSignalChangeList] } { incr i 2 } {
    set theTime  [lindex $theSignalChangeList $i]
    set theValue [lindex $theSignalChangeList $i+1]
    # format the value in binary:
    if { $theValue == "0xx" } {
      set theValue ""
      for { set j 0 } { $j < ${theSize} } { incr j } {
        append theValue "X"
      }
    } else {
      set theValue [format "%0${theSize}b" $theValue] ;# in binary
    }
    #
    if { ${theSize} < 2 } {
      set theValue "'${theValue}'"
    } else {
      set theValue "\"${theValue}\""
    }

    if { $i == 0 } {
      append theText $theAffect
    } else {
      for { set j 0 } { $j < [string length $theAffect] } { incr j } {
        append theText " "
      }
    }

    append theText "${theValue} after $theTime [gtkwave::getTimeDimension]s"

    if { [expr {$i + 2}] >= [llength $theSignalChangeList] } {
      append theText ";\n\n"
    } else {
      append theText ",\n"
    }
  }

}

##
# creation of an output file:
#
set theFile [gtkwave::getDumpFileName]
set theFile [file normalize $theFile]
set theFile [file rootname  $theFile].txt
#
puts "Creation of file: $theFile"
set    theBuffer [open ${theFile} w]
puts  $theBuffer $theText
close $theBuffer

