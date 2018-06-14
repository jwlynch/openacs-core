<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="subsite::default::create_app_group.add_constraint">      
      <querytext>
      
		    BEGIN
			:1 := rel_constraint.new(
			constraint_name => :constraint_name,
			rel_segment => :segment_id,
			rel_side => 'two',
			required_rel_segment => rel_segment.get(:supersite_group_id, 'membership_rel'),
			creation_user => :user_id,
			creation_ip => :creation_ip
			);
		    END;
		
      </querytext>
</fullquery>

 
<fullquery name="subsite::auto_mount_application.select_package_object_names">      
      <querytext>
      
	    select t.pretty_name as package_name, acs_object.name(s.object_id) as object_name
	      from site_nodes s, apm_package_types t
	     where s.node_id = :node_id
	       and t.package_key = :package_key
	
      </querytext>
</fullquery>

 
<fullquery name="subsite::util::object_type_path_list.select_object_type_path">      
      <querytext>
      
	select object_type
	from acs_object_types
	start with object_type = :object_type
	connect by object_type = prior supertype
    
      </querytext>
</fullquery>

    <partialquery name="subsite::get_url.orderby">
        <querytext>
        and rownum < 2
        order by decode(host, :search_vhost, 1, 0) desc
        </querytext>
    </partialquery>
 
    <partialquery name="subsite::get_url.simple_search">
        <querytext>
        and rownum < 2
        </querytext>
    </partialquery>
 
</queryset>
