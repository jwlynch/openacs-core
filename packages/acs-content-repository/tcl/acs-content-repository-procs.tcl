# tcl/acs-content-repository-procs.tcl patch
#
# a patch to the cr for handling the deleting revision's files
# when the revision has been deleted from the database
#
# Walter McGinnis (wtem@olywa.net), 2001-09-23
# based on original photo-album package code by Tom Baginski

ad_proc -private cr_delete_scheduled_files {} {
    Tries to delete all the files in cr_files_to_delete.  
    Makes sure file isn't being used by another revision prior to deleting it.
    Should be scheduled daily.
    This proc is extremely simple, and does not have any concurrancy checks to make sure another 
    version of the proc is running/deleting a file.
    Will add some concurancy checks to a future revision.  
    Right now go with short and sweet, count on scheduling to prevent conflicts
} {
     db_transaction {
	# subselect makes sure there isn't a parent revision still lying around
	db_foreach fetch_paths {

        select distinct crftd.path storage_area_key
          from cr_files_to_delete crftd
           and not exists (select 1 
                             from cr_revisions r 
                            where r.content = crftd.path) 
         } {
             # try to remove file from filesystem
             set file "[cr_fs_path $storage_area_key]/${path}"
             ns_log Debug "cr_delete_scheduled_files: deleting $file"
             ns_unlink  -nocomplain "$file"
	}
	# now that all scheduled files deleted, clear table
	db_dml delete_files "delete from cr_files_to_delete"
    }
}

