<master>
<property name="context">@context@</property>
<property name="title">Remove relation</property>

Are you sure you want to remove the @rel.rel_type_pretty_name@
between @rel.object_id_one_name@ and @rel.object_id_two_name@?

<p>

<center>
<include src="../confirm-delete-form" action="remove-2" export_vars="@export_vars@" no_button="No, I want to cancel my request" yes_button="Yes, I really want to remove this relation">
</center>

