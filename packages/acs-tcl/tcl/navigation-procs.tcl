ad_library {
    Provides procedures to spit out the navigational parts of the site.

    @cvs-id $Id$
    @author philg@mit.edu
    @creation-date 11/5/98 (adapted originally from the Cognet server)     
}

#    edited February 28, 1999 by philg to include support for a 
#    Yahoo-style navigation system (showing users where they are in a
#    hierarchy)

ad_proc -public ad_context_bar_html {
    -separator
    context
} { 
    Generate the an html fragment for a context bar.
    This is the function that takes a list in the format
    <pre>
    [list [list url1 text1] [list url2 text2] ... "terminal text"] 
    <pre>
    and generates the html fragment.  In general the higher level 
    proc ad_context_bar should be
    used, and then only in the sitewide master rather than on 
    individual pages.

    @param separator The text placed between each link
    @param context list as with ad_context_bar 
    
    @return html fragment

    @see ad_context_bar
} { 
    
    # Get the separator from subsite parameter
    if { ![info exists separator] } {
        set subsite_id [ad_conn subsite_id]
        set separator [parameter::get -package_id $subsite_id -parameter ContextBarSeparator -default ":"]
    }

    set out {}
    foreach element [lrange $context 0 [llength $context]-2] {
        lassign $element href label
        append out [subst {<a href="[ns_quotehtml $href]">[ns_quotehtml $label]</a> $separator }]
    }
    append out [ns_quotehtml [lindex $context end]]

    return $out
}

ad_proc ad_context_node_list {
    {-from_node ""}
    node_id
} {
    Starting with the given node_id, return a list of
    [list url instance_name] items for parent nodes.

    @option from_node The top-most node_id for which we'll show context bar. This can be used with 
    the node_id of the nearest subsite to get the context-bar only up to the nearest subsite.

    @author Peter Marklund
} {
    set context [list]

    while { $node_id ne "" } {        
        array set node [site_node::get -node_id $node_id]

        # JCD: Provide something for the name if the instance name is
        # absent.  name is the tail bit of the url which seems like a
        # reasonable thing to display.
        if {$node(instance_name) eq ""
            && [info exists node(name)]} { 
            set node(instance_name) $node(name)
        }

        # Don't collect link for nodes without an object underneath
        # (e.g. empty site folders), as they would just be dead links
        if {$node(object_id) ne ""} {
            set context [list [list $node(url) [ns_quotehtml $node(instance_name)]] {*}$context]
        }

        # We have the break here, so that 'from_node' itself is included
        if {$node_id eq $from_node} {
            break
        }

        set node_id $node(parent_id)
    }

    return $context
}

ad_proc -public ad_context_bar_multirow { 
    {-from_node ""}
    -node_id
    {-multirow "context"}
    context
} {
    Returns a Yahoo-style hierarchical navbar. Includes "Administration"
    if applicable, and the subsite if not global. 'args' can be either
    one or more lists, or a simple string.

    @param node_id If provided work up from this node, otherwise the current node
    @param from_node If provided do not generate links to the given node and above.
    @param separator The text placed between each link (passed to ad_context_bar_html if provided)
    @return an html fragment generated by ad_context_bar_html
    
    @see ad_context_bar_html
} {
    if {![parameter::get -package_id [ad_conn subsite_id] -parameter ShowContextBarP -default 1]} {
	return ""
    }
    
    if { ![info exists node_id] || $node_id eq "" } {
        set node_id [ad_conn node_id]
    }

    set temp_node_id [util_current_location_node_id]
    if { $temp_node_id eq "" } {
        # not a site host_node 
        set node_id_url ""
        set node_id_url_end 0
    } else {
        set from_node $temp_node_id
        set node_id_url [site_node::get_url -node_id ${temp_node_id} -notrailing]    
        set node_id_url_end [string length $node_id_url]
    }

    template::multirow create $multirow url label

    foreach elm [ad_context_node_list -from_node $from_node $node_id] {
	lassign $elm elm_0 elm_1
        if { $node_id_url_end > 0 && [string match -nocase $node_id_url [string range $elm_0 0 ${node_id_url_end}-1] ] } {
            set elm_0 [string range $elm_0 $node_id_url_end end]
        }
        template::multirow append $multirow $elm_0 $elm_1
    }
    
    if { [string match "admin/*" [ad_conn extra_url]] } {
        template::multirow append $multirow "[ad_conn package_url]admin/" "[_ acs-tcl.Administration]"
    }
    
    if { [llength $context] == 0 } { 
        # fix last element to just be literal string
        template::multirow set $multirow [template::multirow size $multirow] url {}
    } else {
        foreach elm [lrange $context 0 end-1] {
            template::multirow append $multirow [lindex $elm 0] [lindex $elm 1]
        }
        template::multirow append $multirow {} [lindex $context end]
    }
}

ad_proc -public ad_context_bar { 
    {-from_node ""}
    -node_id
    -separator
    args
} {
    Returns a Yahoo-style hierarchical navbar. Includes "Administration"
    if applicable, and the subsite if not global. 'args' can be either
    one or more lists, or a simple string.

    @param node_id If provided work up from this node, otherwise the current node
    @param from_node If provided do not generate links to the given node and above.
    @param separator The text placed between each link (passed to ad_context_bar_html if provided)
    @return an html fragment generated by ad_context_bar_html
    
    @see ad_context_bar_html
} {
    if {![parameter::get -package_id [ad_conn subsite_id] -parameter ShowContextBarP -default 1]} {
	return ""
    }

    if { ![info exists node_id] || $node_id eq "" } {
        set node_id [ad_conn node_id]
    }

    set context [ad_context_node_list -from_node $from_node $node_id]

    if { [string match "admin/*" [ad_conn extra_url]] } {
        lappend context [list "[ad_conn package_url]admin/" \
                             [_ acs-tcl.Administration]]
    }

    if {[llength $args] == 0} { 
        # fix last element to just be literal string
        lset context end [lindex $context end 1]
    } else {
	if {![string match "\{*" $args]} {
	    # args is not a list, transform it into one.
	    set args [list $args]
	}	
    }
    lappend context {*}$args
    if { [info exists separator] } {
        return [ad_context_bar_html -separator $separator $context]
    } else {
        return [ad_context_bar_html $context]
    }
}





ad_proc -public ad_navbar args {
    produces navigation bar. notice that navigation bar is different
    than context bar, which displays packages in the site map. Navbar will
    only generate HTML for those links passed to it.

    @param args list of url desc ([list [list url desc] [list url desc]])

    @return html fragment

    @see ad_context_bar_html
} {
    set counter 0
    foreach arg $args {
        lappend link_list [subst {<a href="[ns_quotehtml [lindex $element 0]]">[ns_quotehtml [lindex $element 1]]</a>}]
	incr counter
    }
    if { $counter } {
	return "\[[join $link_list " | "]\]"
    } else {
	return ""
    }
}

ad_proc -public ad_choice_bar { items links values {default ""} } {
    Displays a list of choices (Yahoo style), with the currently selected one highlighted.

    @see ad_navbar 
} {

    set count 0
    set return_list [list]

    foreach value $values {
	if { $default eq $value  } {
	    lappend return_list "<strong>[lindex $items $count]</strong>"
	} else {
	    lappend return_list [subst {<a href="[ns_quotehtml [lindex $links $count]]">[ns_quotehtml [lindex $items $count]]</a>}]
	}

	incr count
    }

    if { [llength $return_list] > 0 } {
        return "\[[join $return_list " | "]\]"
    } else {
	return ""
    }
    
}

ad_proc -public util_current_location_node_id { } {
    returns node_id of util_current_location. Useful for hostnode mapped sites using ad_context_bar
} {
    util::split_location [util_current_location] .proto location_hostname .port

    if { [string match -nocase "www.*" $location_hostname] } {
        set location_hostname [string range $location_hostname 4 end]
    } 
    db_0or1row -cache_key util-${location_hostname}-node-id get_node_id_from_hostname {
        select node_id from host_node_map where host = :location_hostname
    }
    if { ![info exists node_id ] } {
        set node_id ""
    }
    return $node_id
}

# directories that should not receive links to move up one level

proc ad_no_uplevel_patterns {} {
    set regexp_patterns [list]
    lappend regexp_patterns "*/pvt/home.tcl"
    # Tcl files in the root directory
    lappend regexp_patterns "^/\[^/\]*\.tcl\$"
    lappend regexp_patterns "/admin*"
}


# determines if java_script should be enabled
    
proc java_script_capabilities {} {
    set user_agent ""
    set version 0
    set internet_explorer_p 0
    set netscape_p 0
	
    # get the version
    set user_agent [ns_set get [ad_conn headers] User-Agent]
    regexp -nocase "mozilla/(\[^\.\ \]*)" $user_agent match version

    # IE browsers have MSIE and Mozilla in their user-agent header
    set internet_explorer_p [regexp -nocase "msie" $user_agent match]

    # Netscape browser just have Mozilla in their user-agent header
    if {$internet_explorer_p == 0} {
	set netscape_p [regexp -nocase "mozilla" $user_agent match]
    }
   
    set java_script_p 0
 
    if { ($netscape_p && ($version >= 3)) || ($internet_explorer_p && ($version >= 4)) } {
	set java_script_p 1
    }

    return $java_script_p
}

# netscape3 browser has a different output

proc netscape3_browser {} {
    set user_agent ""
    set version 0
    set internet_explorer_p 0
    set netscape_p 0
    
    # get the version
    set user_agent [ns_set get [ad_conn headers] User-Agent]
    regexp -nocase "mozilla/(\[^\.\ \]*)" $user_agent match version
    
    # IE browsers have MSIE and Mozilla in their user-agent header
    set internet_explorer_p [regexp -nocase "msie" $user_agent match]
    
    # Netscape browser just have Mozilla in their user-agent header
    if {$internet_explorer_p == 0} {
	set netscape_p [regexp -nocase "mozilla" $user_agent match]
    }
 
    set netscape3_p 0
 
    if { ($netscape_p && ($version == 3))} {
	set netscape3_p 1
    }

    return $netscape3_p
}



# creates the generic javascript/nonjavascript
# select box for the submenu

proc menu_submenu_select_list {items urls {highlight_url "" }} {
    set return_string ""
    set counter 0

    set selectid id[clock clicks -microseconds]
    append return_string [subst {<form name="submenu" action="/redir">
        <select name="url" id="$selectid">}]

    template::add_event_listener \
        -id $selectid -event change \
        -script {go_to_url(this.options[this.selectedIndex].value);}

    foreach item $items {
	set url_stub [ad_conn url]

	# if the url matches the url you would redirect to, as determined
	# either by highlight_url, or if highlight_url is not set,
	# the current url then select it
	if {$highlight_url ne "" && $highlight_url == [lindex $urls $counter]} {
 	    append return_string [subst {<option value="[lindex $urls $counter]" selected>$item}]
	} elseif {$highlight_url eq "" && [string match "*$url_stub*" [lindex $urls $counter]]} {
	    append return_string [subst {<option value="[lindex $urls $counter]" selected>$item}]
	} else {
	    append return_string [subst {<option value="[lindex $urls $counter]">$item}]
	}
	incr counter
    }
    
    append return_string "</select><br>
    <noscript><input type='submit' value='GO'>
    </noscript>
    </form>\n"
}


# --
# apisano 2016-12-01: this proc is obsolete and currently broken, as
# ad_naked_html_patterns is not defined anywhere on the
# system. Therefore, I am commenting it out.
# --
# this incorporates HTML designed by Ben (not adida, some other guy)
# proc ad_menu_header {{section ""} {uplink ""}} {
    
#     set section [string tolower $section]

#     # if it is an excluded directory, just return
#     set url_stub [ad_conn url]
#     set full_filename "$::acs::pageroot$url_stub"
   

#     foreach naked_pattern [ad_naked_html_patterns] {
# 	if { [string match $naked_pattern $url_stub] } {
# 	    # want the global admins with no menu, but not the domain admin
# 	    return ""
#         }
#     }

#     # title is the title for the title bar
#     # section is the highlight for the menu

   
#     set menu_items [menu_items] 
#     set java_script_p [java_script_capabilities]
    
#     # Ben has a different table structure for netscape 3
#     set netscape3_p [netscape3_browser]
#     set return_string ""

#     if { $java_script_p } {
#     	append return_string " 
# 	<script type='text/javascript' nonce='$::__csp_nonce'>
# 	//<!--
	
# 	go = new Image();
# 	go.src = \"/graphics/go.gif\";
# 	go_h = new Image();
# 	go_h.src = \"/graphics/go_h.gif\";
	
# 	up_one_level = new Image();
# 	up_one_level.src = \"/graphics/36_up_one_level.gif\";
# 	up_one_level_h = new Image();
# 	up_one_level_h.src = \"/graphics/36_up_one_level_h.gif\";
	
# 	back_to_top = new Image();
# 	back_to_top.src = \"/graphics/24_back_to_top.gif\";
# 	back_to_top_h = new Image();
# 	back_to_top_h.src = \"/graphics/24_back_to_top_h.gif\";

# 	help = new Image();
# 	help.src = \"/graphics/help.gif\";
# 	help_h = new Image();
# 	help_h.src = \"/graphics/help_h.gif\";

# 	rules = new Image();
# 	rules.src = \"/graphics/rules.gif\";
# 	rules_h = new Image();
# 	rules_h.src = \"/graphics/rules_h.gif\";"
	
# 	foreach item $menu_items {
# 	    if {  $item == [menu_highlight $section] } { 
# 		#this means the item was selected, so there are different gifs
# 		append return_string "
# 		  $item = new Image();
# 		  $item.src =  \"/graphics/[set item]_a.gif\";
# 		  [set item]_h = new Image();
# 		  [set item]_h.src =  \"/graphics/[set item]_ah.gif\";"
# 	    } else {
# 		append return_string "
# 		$item = new Image();
# 		$item.src =  \"/graphics/[set item].gif\";
# 		[set item]_h = new Image();
# 		[set item]_h.src =  \"/graphics/[set item]_h.gif\";"
# 	    }
	    
# 	}
 
# 	# JavaScript enabled
# 	append return_string "
	
# 	function hiLite(imgObjName) \{
# 	    document \[imgObjName\].src = eval(imgObjName + \"_h\" + \".src\")
# 	\}

# 	function unhiLite(imgObjName) \{
# 	    document \[imgObjName\].src = eval(imgObjName + \".src\")
# 	\}

# 	function go_to_url(url) \{
# 		if (url \!= \"\") \{
# 			self.location=url;
# 		\}
# 		return;
# 	\}
# 	// -->
# 	</SCRIPT>"  
#     } else {
	
# 	append return_string "

# 	<script type='text/javascript' nonce='$::__csp_nonce'>
# 	//<!--
	
# 	function hiLite(imgObjName) \{
# 	\}
		
# 	function unhiLite(imgObjName) \{
# 	\}

# 	function go_to_url(url) \{
# 	\}
# 	// -->
# 	</SCRIPT>"
#     }		

#     # We divide up the screen into 4 areas top to bottom:
#     #  + The top table which is the cognet logo and search stuff.
#     #  + The next table down is the CogNet name and area name.
#     #  + The next area is either 1 large table with 2 sub-tables, or two tables (NS 3.0).
#     #      The left table is the navigation table and the right one is the content.
#     #  + Finally, the bottom table holds the bottom navigation bar.
    

#     append return_string "[ad_body_tag]"
   
    
#     if {$netscape3_p} {
# 	append return_string "<IMG src=\"/graphics/top_left_brand.gif\" width=124 height=87 border=0 align=left alt=\"Cognet\"> 
# <TABLE border=0 cellpadding=3 cellspacing=0>"
#     }  else {
# 	append return_string "
# <TABLE border=0 cellpadding=0 cellspacing=0 height=87 width=\"100%\" cols=100>
#     <TR><TD width=124 align=center><IMG src=\"/graphics/top_left_brand.gif\" width=124 height=87 border=0 alt=\"Cognet\"></TD>
#         <TD colspan=99><TABLE border=0 cellpadding=3 cellspacing=0 width=\"100%\">"
#     }

#     append return_string "
#         <TR><TD height=16></TD></TR>
#         <TR valign=bottom><TD bgcolor=\"[table_background_1]\" align=left><FONT FACE=\"Arial, Helvetica, sans-serif\" size=5>Search</FONT></TD></TR>
#         <TR bgcolor=\"[table_background_1]\"><TD align=left valign=center><FORM  action=\"/search-direct\" method=GET name=SearchDirect>
#                 <SELECT name=section>
#                      [ad_generic_optionlist [pretty_search_sections] [search_sections] [menu_search_highlight $section]]     
#                 </SELECT>&nbsp;&nbsp;
#                 <INPUT type=text value=\"\" name=query_string>&nbsp;&nbsp;"

#     if {$netscape3_p} {
# 	append return_string "<INPUT TYPE=submit VALUE=go>&nbsp;&nbsp;
#              </FORM></TD></TR>
#          </TABLE>"
#     } else {
# 	append return_string "<A href=\"JavaScript: document.SearchDirect.submit();\" onMouseOver=\"hiLite('go')\" onMouseOut=\"unhiLite('go')\" alt=\"search\"><img name=\"go\" src=\"/graphics/go.gif\" border=0 width=32 height=24 align=top alt=\"go\"></A>
# 	</FORM></TD></TR>
#          </TABLE></TD>
#    </TR>
# </TABLE>"
#     }

#     append return_string "
# <TABLE bgcolor=\"#000066\" border=0 cellpadding=0 cellspacing=0 height=36 width=\"100%\">
#     <TR><TD align=left><A HREF=\"/\"><IMG src=\"/graphics/cognet.gif\" width=200 height=36 align=left border=0></A><IMG SRC=\"[menu_title_gif $section]\" ALIGN=TOP WIDTH=\"222\" HEIGHT=\"36\" BORDER=\"0\" HSPACE=\"6\" alt=\"$section\"></TD>"

#     set uplevel_string  "<TD align=right><A href=\"[menu_uplevel $section $uplink]\" onMouseOver=\"hiLite(\'up_one_level\')\" onMouseOut=\"unhiLite(\'up_one_level\')\"><img name=\"up_one_level\" src=\"/graphics/36_up_one_level.gif\" border=0 width=120 height=36 \" alt=\"Up\"></A></TD></TR>"

#     foreach url_pattern [ad_no_uplevel_patterns] {
# 	if { [regexp $url_pattern $url_stub match] } {
# 	    set uplevel_string ""
# 	}
#     }
    
#     append return_string $uplevel_string 
#     append return_string "</TABLE>"

#     if  {$netscape3_p} {
# 	append return_string "<TABLE border=0 cellpadding=0 cellspacing=0 width=200 align=left>"
#     } else {
# 	append return_string "<TABLE border=0 cellpadding=0 cellspacing=0 width=\"100%\" cols=100>
#    <TR valign=top><TD width=200 bgcolor=\"[table_background_1]\">
#        <TABLE border=0 cellpadding=0 cellspacing=0 width=200>"
#     }

# #  Navigation Table

#     foreach item $menu_items {
# 	if {  $item == [menu_highlight $section] } { 
# 	    append return_string "<TR><TD valign=bottom height=25 width=200 bgcolor=\"#FFFFFF\"><A href=\"[menu_url $item]\" onMouseOver=\"hiLite('[set item]')\" onMouseOut=\"unhiLite('[set item]')\"><img name=\"[set item]\" src=\"/graphics/[set item]_a.gif\" border=0 width=200 height=25 alt=\"$item\"></A></TD></TR>"
# 	} else {
# 	    append return_string "<TR><TD valign=bottom height=25 width=200 bgcolor=\"#FFFFFF\"><A href=\"[menu_url $item]\" onMouseOver=\"hiLite('[set item]')\" onMouseOut=\"unhiLite('[set item]')\"><img name=\"[set item]\" src=\"/graphics/[set item].gif\" border=0 width=200 height=25 alt=\"$item\"></A></TD></TR>"
# 	}
#     }

#     append return_string "
#        <TR bgcolor=\"[table_background_1]\" valign=top align=left><TD width=200>
#            <TABLE border=0 cellpadding=4 cellspacing=0 width=200>
#     <!-- NAVIGATION BAR CONTENT GOES AFTER THIS START COMMENT USING TABLE Row and Data open and close tags -->
# 	        [menu_subsection $section]
#                 <!-- NAVIGATION BAR CONTENT GOES BEFORE THIS END COMMENT -->
#            </TABLE></TD></TR>
#    </TABLE>"
    
#    if {$netscape3_p} {
#        append return_string "<TABLE border=0 cellpadding=4 cellspacing=12>"
#    } else {
#        append return_string "
#        </TD><TD valign=top align=left colspan=99><TABLE border=0 cellpadding=4 cellspacing=12 width=\"100%\">"
#    }
#    append return_string "<TR><TD>"
# }

# --
# apisano 2017-02-08: this proc is obsolete and currently broken, as
# ad_naked_html_patterns is not defined anywhere on the
# system. Therefore, I am commenting it out.
# --
# proc ad_menu_footer {{section ""}} {
   
#     # if it is an excluded directory, just return
#     set url_stub [ad_conn url]
#     set full_filename "$::acs::pageroot$url_stub"
   
#     foreach naked_pattern [ad_naked_html_patterns] {
# 	if { [string match $naked_pattern $url_stub] } {
# 	    return ""
# 	}
#     }

#     set netscape3_p 0
	
#     if {[netscape3_browser]} {
# 	set netscape3_p 1
#     }

#     append return_string "</TD></TR></TABLE>"
    
#     # close up the table
#     if {$netscape3_p != 1} {
# 	append return_string "</TD></TR>
#        </TABLE>"
#     }

#     # bottom bar

#     append return_string "
#     <TABLE border=0 cellpadding=0 cellspacing=0 height=24 width=\"100%\">
#        <TR bgcolor=\"#000066\"><TD align=left valign=bottom><A href=#top onMouseOver=\"hiLite('back_to_top')\" onMouseOut=\"unhiLite('back_to_top')\"><img name=\"back_to_top\" src=\"/graphics/24_back_to_top.gif\" border=0 width=200 height=24 alt=\"top\"></A></TD>
#          <TD align=right valign=bottom><A href=\"[parameter::get -parameter GlobalURLStub -default /global]/rules\" onMouseOver=\"hiLite('rules')\" onMouseOut=\"unhiLite('rules')\"><img name=\"rules\" src=\"/graphics/rules.gif\" border=0 width=96 height=24 valign=bottom alt=\"rules\"></A><A href=\"[ad_help_link $section]\" onMouseOver=\"hiLite('help')\" onMouseOut=\"unhiLite('help')\"><img name=\"help\" src=\"/graphics/help.gif\" border=0 width=30 height=24 align=bottom alt=\"help\"></A></TD></TR>
#     </TABLE>"
#     return $return_string
# }


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
