ad_page_contract {

    Changes the member state of a user

    @author Hiro Iwashima <iwashima@mit.edu>
    @creation-date 23 Aug 2000
    @cvs-id $Id$

} {
    user_id:naturalnum,notnull
    {member_state}
    {email_verified_p:boolean}
    {return_url:localurl ""}
} -properties {
    context:onevalue
    export_vars:onevalue
    action:onevalue
    return_url:onevalue
}

if {![db_0or1row get_states {}]} {
    # The user is not in there
    ad_return_complaint 1 "Invalid User: the user is not in the system"
    return
}


set action [group::get_member_state_pretty -component action -user_name $name]
set email_message [group::get_member_state_pretty -component email_message \
                       -community_name [ad_system_name] \
                       -url [ad_url] \
                       -membership "account"]

switch $email_verified_p {
    "t" {
	set action "Approve Email for $name"
	set email_message "Your email in [ad_system_name] has been approved.  Please return to [ad_url]."
    }
    "f" {
	set action "Require Email from $name"
	set email_message "Your email in [ad_system_name] needs approval. please go to [ad_url]/register/email-confirm"
    }
}

if {$action eq ""} {
    ad_return_complaint 1 "Not valid action: You have not changed the user in any way"
    return
}

if {[catch {
    acs_user::change_state -user_id $user_id -state $member_state

    switch $email_verified_p {
        "t" {
            db_exec_plsql approve_email {}
        }
        "f" {
            db_exec_plsql unapprove_email {}
        }
    }
} errmsg]} {
    ad_return_error "Database Update Failed" "Database update failed with the following error:
    <pre>$errmsg</pre>"
}

callback acs_admin::member_state_change -member_state $member_state -user_id $user_id

set admin_user_id [ad_conn user_id]
set email_from [db_string admin_email {select email from parties where party_id = :admin_user_id}]
set subject $action
set message $email_message

if {$return_url eq ""} {
    set return_url [export_vars -base /acs-admin/users/one {user_id}]
}

set context [list [list "./" "Users"] "$action"]
set export_vars [export_vars {email email_from subject message return_url}]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
