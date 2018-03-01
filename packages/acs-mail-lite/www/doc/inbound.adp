<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>

  <p>
    Scheduled procs collect the email. 
    Current methods include:

 <a href="/api-doc/proc-view?proc=acs_mail_lite::imap_check_incoming&amp;source_p=1">acs_mail_lite::imap_check_incoming</a> 
 for IMAP and 
 <a href="/api-doc/proc-view?proc=acs_mail_lite::maildir_check_incoming&amp;source_p=1">acs_mail_lite::maildir_check_incoming</a> 
   for MailDir.
</p><p>
    Both schedules procs can be run simultaneously without intefering with
    each other.
    In both cases, email is added to the same queue for processing via callbacks.
  </p>
  <p>These procs provide an overview of inbound email processing in general.</p>
    <p>
     Legacy <a href="incoming-email">Incoming E-mail up to oacs-5-9 for package developers</a>
</p>  <h3>Overview</h3>
  <p>
    A scheduled procedure begins by checking for new incoming email.
    The interval is set by package parameter <code>IncomingScanRate</code>.
  </p><p>
    ACS Mail Lite detects if an
    email is responding to email sent from OpenACS (via ACS Mail Lite).
    It verifies 
    <code>message_id</code> or <code>originator</code> hashkey via
    <code>acs_mail_lite::unique_id_parse</code> and identifies
     bounced or reply emails.
    </p><p>
    Then, the message-id is cross-referenced 
    for any parameters passed to the email, such as package_id or party_id. 
  </p><p>
    The email is 
    <a href="/api-doc/proc-view?version_id=774&proc=acs_mail_lite::inbound_prioritize">prioritized</a>
    and 
    <a href="/api-doc/proc-view?version_id=774&proc=acs_mail_lite::inbound_queue_insert">placed in a queue</a>, where it is pulled from the queue in sequence.
</p><p>
    When pulled, an email is processed by callbacks.
    
    A package can be associated with replies to outbound email generated by the same package.
    This enables each package to deal with incoming email in its own way.
    For example, a social networking site could log an event 
    in a special table about subscribers.
    The package-key is determined from the package_id that sent the email.
  </p><p>
    For bounced email, 
    the procedure logs a bounced mail event for the user associated 
    with the bounced email address.
  </p><p>
    A separate process checks if an email account
    needs to inactivate notifications due to chronic bounce errors:
  </p>
  <ul>
    <li>If a user's last mail bounced more than
      <code>MaxDaysToBounce</code> days ago without any further
      bounced mail then the bounce-record counter gets reset (deleted).
      ACS Mail Lite assumes the user's email account is working again 
      and no longer refuses emails.
      <code>MaxDaysToBounce</code> is a package parameter.</li>
    <li>If more than <code>MaxBounceCount</code> emails are returned
      for a particular user then
      the account associated with the email stops receiving email
      notifications channeled through ACS Mail Lite.
      The email_bouncing_p flag is set to '<code>t</code>'.</li>
    <li>To notify users that they will not receive any more email and to
      tell them how to re-enable the email account in the system,
      a notification email is sent every
      <code>NotificationInterval</code> days up to
      <code>MaxNotificationCount</code> times.
      It contains a link to re-enable email notifications.</li>
  </ul>