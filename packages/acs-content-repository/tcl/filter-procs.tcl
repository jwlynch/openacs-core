###########
# Register the filter to automatically look up paths to content
# items and retrieve the appropriate item id
###########

namespace eval content {

variable item_id
variable item_url
variable template_url
variable revision_id

# Find the directory in the file system where templates are stored.
# There are a variety of ways in which this can be set. The proc
# looks for that directory in the following places in this order:
# (1) the TemplateRoot parameter of the package for which the request is 
#     made, i.e., [ad_conn package_id]
# (2) the TemplateRoot parameter of the acs-content-repository
# If it is not found in any of these places, it defaults to 
# [acs_root_dir]/templates
#
# If the value resulting from the search does not start with a '/'
# it is taken to be relative to [acs_root_dir]

ad_proc -public get_template_root {} {

  # Look for package-defined root
  set package_id [ad_conn package_id]
  set template_root \
      [ad_parameter -package_id $package_id TemplateRoot dummy ""]

  if { [empty_string_p $template_root] } {
    # Look for template root defined in the CR
    set package_id [apm_package_id_from_key "acs-content-repository"]

    set template_root [ad_parameter -package_id $package_id \
	TemplateRoot dummy "templates"]
  }

  if { [string index $template_root 0] != "/" } {
    # Relative path, prepend server_root
    set template_root "[acs_root_dir]/$template_root"
  }

  return [ns_normalizepath $template_root]

}

# return true if the request has content associated with it

ad_proc -public has_content {} {

  variable item_id

  return [info exists item_id]
} 

ad_proc -public get_item_id {} {

  variable item_id

  return $item_id
} 

ad_proc -public get_content {} {
 
  variable item_id
  variable revision_id

  if { [template::util::is_nil item_id] } {
    ns_log notice "No active item in content::get_content"
    return
  }

  # Get the live revision
  set revision_id [db_string get_revision ""]

  if { [template::util::is_nil revision_id] } {
    ns_log notice "No live revision for item $item_id"
    return
  }

  # Get the mime type, decide if we want the text
  set mime_type [db_string get_mime_type ""]
  
  if { [template::util::is_nil mime_type] } {
    ns_log notice "No such revision: $reivision_id"
    return
  }  

  if { [string equal [lindex [split $mime_type "/"] 0] "text"] } {
    set text_sql [db_map content_as_text]
  } else {
    set text_sql ""
  }
 
  # Get the content type
  set content_type [db_string get_content_type ""]

  # Get the table name
  set table_name [db_string get_table_name ""]

  upvar content content

  # Get (all) the content (note this is really dependent on file type)
  if {![db_0or1row get_content "" -column_array content]} {
    ns_log Notice "No data found for item $item_id, revision $revision_id"
    return 0
  }

}

ad_proc -public get_template_url {} {

  variable template_url

  return $template_url
}

# Set a data source in the calling frame with folder URL and label
# Useful for generating a context bar

ad_proc -public get_folder_labels { { varname "folders" } } {
 
  variable item_id
  set url ""

  # this repeats the query used to look up the item in the first place
  # but there does not seem to be a clear way around this

  # build the folder URL out as we iterate over the query
  set query [db_map get_url]
  uplevel 1 "db_multirow $varname ignore_get_url $query { 
                                                       append url $name/ 
                                                       set url ${url}index.acs
                                                        }"
}

ad_proc -public get_content_value { revision_id } {

  db_transaction {
      db_exec_plsql gcv_get_revision_id {
	  begin
	    content_revision.to_temporary_clob(:revision_id);
	  end;
      }

      # Query for values from a previous revision
      set content [db_string gcv_get_previous_content ""]

  }

  return $content
}


ad_proc -public init { urlvar rootvar {content_root ""} {template_root ""} {context "public"} {rev_id ""}} {

  upvar $urlvar url $rootvar root_path

  variable item_id
  variable revision_id
  
  # if a .tcl file exists at this url, then don't do any queries
  if { [file exists [ns_url2file "$url.tcl"]] } {
    return 0
  }

  # cache this query persistently for 1 hour
  db_0or1row get_item_info "" -column_array item_info

  # No item found, so do not handle this request
  if { ![info exists item_info] } { 
      db_1row get_template_info "" -column_array item_info
    
      if { ![info exists item_info] } { 
          ns_log Notice "No content found for url $url"
          return 0 
      }
  }

  variable item_url
  set item_url $url

  set item_id $item_info(item_id)
  set content_type $item_info(content_type)

  # Make sure that a live revision exists
  if [empty_string_p $rev_id] {
      set live_revision [db_string get_live_revision ""]

      if { [template::util::is_nil live_revision] } {
          ns_log Notice "No live revision found for content item $item_id"
          return 0
      }
      set revision_id $live_revision
  } else {
      set revision_id $rev_id
  }

  variable template_path

  # Get the template 
  db_1row get_template_url "" -column_array info

  if { [string equal $info(template_url) {}] } { 
    ns_log Notice "No template found to render content item $item_id in context '$context'"
    return 0
  }

  set url $info(template_url)
  set root_path [get_template_root]

  # Added so that published templates are regenerated if they are missing.
  # This is useful for default templates.  
  # (OpenACS - DanW, dcwickstrom@earthlink.net)

  set file ${root_path}/${url}.adp
  if ![file exists $file] {

      file mkdir [file dirname $file]
      set text [content::get_content_value $info(template_id)]
      template::util::write_file $file $text
  }

  return 1
}

# render the template and write it to the file system

ad_proc -public deploy { url_stub } {
  
  set output_path [ns_info pageroot]$url_stub

  init url_stub root_path

  set output [template::adp_parse $file_stub]

  template::util::write_file $output_path $output
}

# end of content namespace

}
