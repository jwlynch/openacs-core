ad_page_contract {
    Simple image upload, attach image to object_id passed in, if no
    object_id, use the current package_id
    @author Guenter Ernst guenter.ernst@wu-wien.ac.at, 
    @author Gustaf Neumann neumann@wu-wien.ac.at
    @author Dave Bauer (dave@solutiongrove.com)
    @creation-date 13.07.2004
    @cvs-id $Id$
} {
    {parent_id:integer}
    {selector_type "file"}
}

set user_id [ad_conn user_id]
# if user has write permission, create image upload form, 
if {[permission::permission_p -party_id $user_id -object_id $parent_id \
	 -privilege "write"]} {

    set write_p 1

    # set recent files
    set recent_files_options [list]
    db_multirow -extend {mime_icon} -unclobber recent_files recent_files \
	{
	    select ci.item_id, ci.name, cr.mime_type
	    from cr_items ci, cr_revisionsx cr
	    where ci.live_revision=cr.revision_id
	    and ci.content_type='content_revision'
            and storage_type='file'
	    and cr.creation_user=:user_id
            and cr.mime_type is not null
	    order by creation_date desc
	    limit 6
	} {
	    set mime_icon "/resources/acs-templating/mimetypes/gnome-mime-[string map {/ -} $mime_type].png"
	    set name [regsub "${item_id}_" $name ""]
	    set name "<img src=\"$mime_icon\"/> $name"
	    lappend recent_files_options [list $name $item_id]
	}

    
    set share_options [list [list "[_ acs-templating.Only_myself]" private] [list "[_ acs-templating.This_Group]" group] [list "[_ acs-templating.Anyone_on_this_system]" site] [list "[_ acs-templating.Anyone_on_the_internet]" public]]
    ad_form \
        -name upload_form \
        -mode edit \
        -export {selector_type file_types parent_id} \
        -html { enctype multipart/form-data } \
        -form {
            item_id:key
	    {f_title:text,optional {label "[_ acs-templating.Link_Text]"} {html {size 50 id f_title} } }
	    {choose_file:text(radio),optional {options $recent_files_options}}
            {upload_file:file(file) {html {size 30}} }
            {share:text(radio),optional {label "[_ acs-templating.This_file_can_be_reused_by]"} {options $share_options} {help_text "[_ acs-templating.This_file_can_be_reused_help]"}}
	    {select_btn:text(submit) {label "Select"}}
            {ok_btn:text(submit) {label "[_ acs-templating.HTMLArea_SelectUploadBtn]"}
            }
        } \
        -on_request {
            set share site
	    set f_title ""
	    set f_href ""
        } \
        -on_submit {
            # check file name
            if {$choose_file eq "" && $upload_file eq ""} {
		if {[info exists ok_btn] && $ok_btn ne ""} {
		    template::form::set_error upload_form upload_file \
			[_ acs-templating.HTMLArea_SpecifyUploadFilename]
		}
		if {[info exists select_btn]} {
		    template::form::set_error upload_form choose_file \
			[_ acs-templating.Attach_File_Choose_a_file]
		}
		set share site
		set f_title ""
		set f_href ""

            } else {

		if {$upload_file ne ""} {
		    # check quota
		    # FIXME quota is a good idea, set per-user upload quota??
		    #            set maximum_folder_size [ad_parameter "MaximumFolderSize"]
		    
		    #            if { $maximum_folder_size ne "" } {
		    #                set max [ad_parameter "MaximumFolderSize"]
		    #                if { $folder_size+[file size ${upload_file.tmpfile}] > $max } {
		    #                    template::form::set_error upload_form upload_file \
					     [_ file-storage.out_of_space]
					     #                   break
					     #               }
					     #           }	 
					     
					     set file_name [template::util::file::get_property filename $upload_file]
					     set upload_tmpfile [template::util::file::get_property tmp_filename $upload_file]
					     set mime_type [template::util::file::get_property mime_type $upload_file]
					     if {$mime_type eq ""} {
						 set mime_type [ns_guesstype $file_name] 
					     }

					     if {[string match "image/*" $mime_type]} {
						 
						 image::new \
						     -item_id $item_id \
						     -name ${item_id}_$file_name \
						     -parent_id $parent_id \
						     -title $f_title \
						     -tmp_filename $upload_tmpfile \
						     -creation_user $user_id \
						     -creation_ip [ad_conn peeraddr] \
						     -package_id [ad_conn package_id]
					     } else {
						 content::item::new \
						     -item_id $item_id \
						     -name ${item_id}_$file_name \
						     -title $f_title \
						     -parent_id $parent_id \
						     -tmp_filename $upload_tmpfile \
						     -creation_user $user_id \
						     -creation_ip [ad_conn peeraddr] \
						     -package_id [ad_conn package_id] \
						     -mime_type $mime_type
					     }
					     file delete $upload_tmpfile
					     permission::grant \
						 -object_id $item_id \
						 -party_id $user_id \
						 -privilege admin
					     
					     switch -- $share {
						 private {
						     permission::set_not_inherit -object_id $item_id
						 }
						 group {
						     # Find the closest application group
						     # either dotlrn or acs-subsite
						     
						     permission::grant \
							 -party_id [acs_magic_object "registered_users"] \
							 -object_id $item_id \
							 -privilege "read"
						 }
						 public {
						     permission::grant \
							 -party_id [acs_magic_object "the_public"] \
							 -object_id $item_id \
							 -privilege "read"
						 }
						 site -
						 default {
						     permission::grant \
							 -party_id [acs_magic_object "registered_users"] \
							 -object_id $item_id \
							 -privilege "read"
						 }
						 
					     }
					 } else {
					     set item_id $choose_file
					     set file_name [lindex [lindex $recent_files_options [util_search_list_of_lists $recent_files_options $item_id 1]] 0]
					 }

		if {$f_title eq ""} {
		    element set_value upload_form f_title $file_name
		}            
		if {$share eq "private" && [string match "image/*" $mime_type]} {
		    # need a private URL that allows viewers of this
		    # object to see the image
		    # this isn't totally secure, because of course
		    # you need to be able to see the image somehow
		    # but we only allow read on the image if you can
		    # see the parent object
		    set f_href "/image/${item_id}/private/${parent_id}/${file_name}"

		} else {
		    set f_href "/file/${item_id}/${file_name}"
		}
	    }

        }

} else {
    set write_p 0
}

set HTML_UploadTitle ""