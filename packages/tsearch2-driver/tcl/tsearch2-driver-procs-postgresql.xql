<queryset>

  <fullquery name="tsearch2::index.index">
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>
    <querytext>
      insert into txt (object_id,fti)
      values (:object_id,
              setweight(to_tsvector(coalesce(:title,'')),'A')
              ||setweight(to_tsvector(coalesce(:keywords,'')),'B')
              ||to_tsvector(coalesce(:txt,'')))
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::search.base_query">
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>
    <querytext>
      where fti @@ to_tsquery(:query)
        and exists (select 1
                    from acs_object_party_privilege_map m
                    where m.object_id = txt.object_id
                      and m.party_id = :user_id
                      and m.privilege = 'read')
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::search.search">
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>
    <querytext>
      select txt.object_id $base_query
      order by ts_rank(fti,to_tsquery(:query)) desc
      $limit_clause $offset_clause
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::summary.summary">
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>
    <querytext>
      select ts_headline(:txt,to_tsquery(:query))
    </querytext>
  </fullquery>

  <fullquery name="tseach2::update_index.update_index">
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>
    <querytext>
       update txt set fti =
         setweight(to_tsvector(coalesce(:title,'')),'A')
           ||setweight(to_tsvector(coalesce(:keywords,'')),'B')
           ||to_tsvector(coalesce(:txt,''))
         where object_id=:object_id
    </querytext>   
  </fullquery>

  <fullquery name="tsearch2::index.index">
  <rdbms><type>postgresql</type><version>8.0</version></rdbms>
    <querytext>
      insert into txt (object_id,fti)
      values (:object_id,
              setweight(to_tsvector(coalesce(:title,'')),'A')
              ||setweight(to_tsvector(coalesce(:keywords,'')),'B')
              ||to_tsvector(coalesce(:txt,'')))
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::search.base_query">
  <rdbms><type>postgresql</type><version>8.0</version></rdbms>
    <querytext>
      where fti @@ to_tsquery(:query)
        and exists (select 1
                    from acs_object_party_privilege_map m
                    where m.object_id = txt.object_id
                      and m.party_id = :user_id
                      and m.privilege = 'read')
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::search.search">
  <rdbms><type>postgresql</type><version>8.0</version></rdbms>
    <querytext>
      select txt.object_id $base_query
      order by rank(fti,to_tsquery(:query)) desc
      $limit_clause $offset_clause
    </querytext>
  </fullquery>

  <fullquery name="tsearch2::summary.summary">
  <rdbms><type>postgresql</type><version>8.0</version></rdbms>
    <querytext>
      select headline(:txt,to_tsquery(:query))
    </querytext>
  </fullquery>

  <fullquery name="tseach2::update_index.update_index">
  <rdbms><type>postgresql</type><version>8.0</version></rdbms>
    <querytext>
       update txt set fti =
         setweight(to_tsvector('default',coalesce(:title,'')),'A')
           ||setweight(to_tsvector('default',coalesce(:keywords,'')),'B')
           ||to_tsvector('default',coalesce(:txt,''))
         where object_id=:object_id
    </querytext>   
  </fullquery>

</queryset>
