
<property name="context">{/doc/acs-core-docs {ACS Core Documentation}} {Object Model Design}</property>
<property name="doc(title)">Object Model Design</property>
<master>
<include src="/packages/acs-core-docs/lib/navheader"
		    leftLink="object-system-requirements" leftLabel="Prev"
		    title="
Chapter 15. Kernel Documentation"
		    rightLink="permissions-requirements" rightLabel="Next">
		<div class="sect1">
<div class="titlepage"><div><div><h2 class="title" style="clear: both">
<a name="object-system-design" id="object-system-design"></a>Object Model
Design</h2></div></div></div><div class="authorblurb">
<p>By Pete Su, Michael Yoon, Richard Li, Rafael Schloming</p>
OpenACS docs are written by the named authors, and may be edited by
OpenACS documentation staff.</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-essentials" id="object-system-design-essentials"></a>Essentials</h3></div></div></div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-data-model" id="objects-design-data-model"></a>Data Model</h4></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-metadata-create.sql&amp;package_key=acs-kernel" target="_top">acs-metadata-create.sql</a></p></li><li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-objects-create.sql&amp;package_key=acs-kernel" target="_top">acs-objects-create.sql</a></p></li><li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-relationships-create.sql&amp;package_key=acs-kernel" target="_top">acs-relationships-create.sql</a></p></li>
</ul></div>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-tcl-files" id="objects-design-tcl-files"></a>Tcl Files</h4></div></div></div><p><span class="emphasis"><em>Not yet linked.</em></span></p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-requirements" id="objects-design-requirements"></a>Requirements</h4></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p><a class="link" href="object-system-requirements" title="Object Model Requirements">Object Model Requirements</a></p></li><li class="listitem"><p><a class="link" href="groups-requirements" title="Groups Requirements">Groups Requirements</a></p></li><li class="listitem"><p><a class="link" href="permissions-requirements" title="Permissions Requirements">Permissions Requirements</a></p></li>
</ul></div>
</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-introduction" id="object-system-design-introduction"></a>Introduction</h3></div></div></div><p>Before OpenACS 4, software developers writing OpenACS
applications or modules would develop each data model separately.
However, many applications built on OpenACS share certain
characteristics or require certain common services. Examples of
such services include:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>User comments</p></li><li class="listitem"><p>Storage of user-defined or extensible sets of attributes</p></li><li class="listitem"><p>Access control</p></li><li class="listitem"><p>General auditing and bookkeeping (e.g. creation date, IP
addresses, and so forth)</p></li><li class="listitem"><p>Presentation tools (e.g. how to display a field in a form or on
a page)</p></li>
</ul></div><p>All of these services involve relating additional
service-related information to application data objects. Examples
of application objects include:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>forum messages</p></li><li class="listitem"><p>A user home page</p></li><li class="listitem"><p>A ticket in the ticket tracker</p></li>
</ul></div><p>In the past, developers had to use ad-hoc and inconsistent
schemes to interface to various "general" services.
OpenACS 4 defines a central data model that keeps track of the
application objects that we wish to manage, and serves as a primary
store of <span class="emphasis"><em>metadata</em></span>. By
<span class="emphasis"><em>metadata</em></span>, we mean data
stored on behalf of an application <span class="emphasis"><em>outside</em></span> of the application&#39;s data
model in order to enable certain central services. The OpenACS 4
Object Model (or object system) manages several different kinds of
data and metadata to allow us to provide general services to
applications:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem">
<p><a class="xref" href="object-system-design" title="Object Identification">Object Identification</a></p><p>Every application object is given a unique identifier in the
system. This identifier can be used to find all data related to a
particular object.</p>
</li><li class="listitem">
<p><a class="xref" href="object-system-design" title="Object Context and Access Control">Object Context and Access
Control</a></p><p>Every object is created in a particular security context, so the
system can provide centralized access control.</p>
</li><li class="listitem">
<p><a class="xref" href="object-system-design" title="Object Types and Attributes">Object Types and Attributes</a></p><p>Objects are instances of developer-defined object types. Object
types allow developers to customize the data that is stored with
each object.</p>
</li><li class="listitem">
<p><a class="xref" href="object-system-design" title="Relation Types">Relation Types</a></p><p>Relation types provide a general mechanism for mapping instances
of one object type (e.g. users) to instances of another object type
(e.g. groups).</p>
</li>
</ul></div><p>The next section will explore these facilities in the context of
the the particular programming idioms that we wish to
generalize.</p><p><span class="strong"><strong>Related Links</strong></span></p><p>This design document should be read along with the design
documents for <a class="link" href="groups-design" title="Groups Design">the new groups system</a>, <a class="link" href="subsites-design" title="Subsites Design Document">subsites</a> and <a class="link" href="permissions-design" title="Permissions Design">the
permissions system</a>
</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-history" id="object-system-design-history"></a>History</h3></div></div></div><p>The motivation for most of the facilities in the OpenACS 4
Object Model can be understood in the context of the 3.x code base
and the kinds of programming idioms that evolved there. These are
listed and discussed below.</p><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-object-ident" id="objects-design-object-ident"></a>Object Identification</h4></div></div></div><p>Object identification is a central mechanism in OpenACS 4. Every
application object in OpenACS 4 has a unique ID which is mapped to
a row in a central table called <code class="computeroutput">acs_objects</code>. Developers that wish to use
OpenACS 4 services need only take a few simple steps to make sure
that their application objects appear in this table. The fact that
every object has a known unique identifier means that the core can
deal with all objects in a generic way. In other words, we use
object identifiers to enable centralized services in a global and
uniform manner.</p><p><span class="emphasis"><em>Implicit Object Identifiers in
OpenACS 3.x</em></span></p><p>The motivation for implementing general object identifiers comes
from several observations of data models in OpenACS 3.x. Many
modules use a <code class="computeroutput">(user_id, group_id,
scope)</code> column-triple for the purpose of recording ownership
information on objects, for access control. User/groups also uses
<code class="computeroutput">(user_id, group_id)</code> pairs in
its <code class="computeroutput">user_group_map</code> table as a
way to identify data associated with a single membership
relation.</p><p>Also, in OpenACS 3.x many utility modules exist that do nothing
more than attach some extra attributes to existing application
data. For example, general comments maintains a table that maps
application "page" data (static or dynamic pages on the
website) to one or more user comments on that page. It does so by
constructing a unique identifier for each page, usually a
combination of the table in which the data is stored, and the value
of the primary key value for the particular page. This idiom is
referred to as the "(on_which_table + on_what_id)" method
for identifying application data. In particular, general comments
stores its map from pages to comments using a "(on_which_table
+ on_what_id)" key plus the ID of the comment itself.</p><p>All of these composite key constructions are implicit object
identifiers - they build a unique ID out of other pieces of the
data model. The problem is that their definition and use is ad-hoc
and inconsistent, making the construction of generic
application-independent services unnecessarily difficult.</p><p><span class="emphasis"><em>Object Identifiers in OpenACS
4</em></span></p><p>The OpenACS 4 Object Model defines a single mechanism that
applications use to attach unique identifiers to application data.
This identifier is the primary key of the <code class="computeroutput">acs_objects</code> table. This table forms the
core of what we need to provide generic services like access
control, general attribute storage, general presentation and forms
tools, and generalized administrative interfaces. In addition, the
object system provides an API that makes it easy to create new
objects when creating application data. All an application must do
to take advantage of general services in OpenACS 4 is to use the
new API to make sure every object the system is to manage is
associated with a row in <code class="computeroutput">acs_objects</code>. More importantly, if they do
this, new services like general comments can be created without
requiring existing applications to "hook into" them via
new metadata.</p><p>
<span class="strong"><strong>Note:</strong></span> Object
identifiers are a good example of metadata in the new system. Each
row in <code class="computeroutput">acs_objects</code> stores
information <span class="emphasis"><em>about</em></span> the
application object, but not the application object itself. This
becomes more clear if you skip ahead and look at the SQL schema
code that defines this table.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-obj-context" id="objects-design-obj-context"></a>Object Context and Access
Control</h4></div></div></div><p>Until the implementation of the general permissions system,
every OpenACS application had to manage access control to its data
separately. Later on, a notion of "scoping" was
introduced into the core data model.</p><p>"Scope" is a term best explained by example. Consider
some hypothetical rows in the <code class="computeroutput">address_book</code> table:</p><div class="informaltable"><table class="informaltable" cellspacing="0" border="1">
<colgroup>
<col><col><col><col><col>
</colgroup><tbody>
<tr>
<td><span class="strong"><strong>...</strong></span></td><td><span class="strong"><strong><code class="computeroutput">scope</code></strong></span></td><td><span class="strong"><strong><code class="computeroutput">user_id</code></strong></span></td><td><span class="strong"><strong><code class="computeroutput">group_id</code></strong></span></td><td><span class="strong"><strong>...</strong></span></td>
</tr><tr>
<td>...</td><td><code class="computeroutput">user</code></td><td><code class="computeroutput">123</code></td><td></td><td>...</td>
</tr><tr>
<td>...</td><td><code class="computeroutput">group</code></td><td></td><td><code class="computeroutput">456</code></td><td>...</td>
</tr><tr>
<td>...</td><td><code class="computeroutput">public</code></td><td></td><td></td><td>...</td>
</tr>
</tbody>
</table></div><p>The first row represents an entry in User 123's personal
address book, the second row represents an entry in User Group
456's shared address book, and the third row represents an
entry in the site&#39;s public address book.</p><p>In this way, the scoping columns identify the security context
in which a given object belongs, where each context is <span class="emphasis"><em>either</em></span> a person <span class="emphasis"><em>or</em></span> a group of people <span class="emphasis"><em>or</em></span> the general public (itself a group of
people).</p><p>In OpenACS 4, rather than breaking the world into a limited set
of scopes, every object lives in a single <span class="emphasis"><em>context</em></span>. A context is just an abstract
name for the default security domain to which the object belongs.
Each context has a unique identifier, and all the contexts in a
system form a tree. Often this tree will reflect an observed
hierarchy in a site, e.g. a forum message would probably list a
forum topic as its context, and a forum topic might list a subsite
as its context. Thus, contexts make it easier to break the site up
into security domains according to its natural structure. An
object&#39;s context is stored in the <code class="computeroutput">context_id</code> column of the <code class="computeroutput">acs_objects</code> table.</p><p>We use an object&#39;s context to provide a default answer to
questions regarding access control. Whenever we ask a question of
the form "can user X perform action Y on object Z", the
OpenACS security model will defer to an object&#39;s context if
there is no information about user X&#39;s permission to perform
action Y on object Z.</p><p>The context system forms the basis for the rest of the OpenACS
access control system, which is described in in two separate
documents: one for the <a class="link" href="permissions-design" title="Permissions Design">permissions
system</a> and another for the <a class="link" href="groups-design" title="Groups Design">party groups</a> system.
The context system is also used to implement <a class="link" href="subsites-design" title="Subsites Design Document">subsites</a>.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-obj-types" id="objects-design-obj-types"></a>Object Types</h4></div></div></div><p>As mentioned above, many OpenACS modules provide extensible data
models, and need to use application specific mechanisms to keep
track of user defined attributes and to map application data to
these attributes. In the past, modules either used user/groups or
their own ad hoc data model to provide this functionality.</p><p><span class="emphasis"><em>User/Groups in OpenACS
3.x</em></span></p><p>The user/group system allowed developers to define <span class="emphasis"><em>group types</em></span> along with attributes to be
stored with each instance of a group type. Each group type could
define a helper table that stored attributes on each instance of
the group type. This table was called the "<code class="computeroutput">_info</code>" table because the name was
generated by appending <code class="computeroutput">_info</code> to
the name of the group type.</p><p>The user/groups data model also provided the <code class="computeroutput">user_group_type_member_fields</code> and
<code class="computeroutput">user_group_member_fields</code> tables
to define attributes for members of groups of a specific type and
for members of a specific group, respectively. The <code class="computeroutput">user_group_member_field_map</code> table stored
values for both categories of attributes in its <code class="computeroutput">field_value</code> column. These tables allowed
developers and users to define custom sets of attributes to store
on groups and group members without changing the data model at the
code level.</p><p>Many applications in OpenACS 3.x and earlier used the group type
mechanism in ways that were only tangentially related to groups of
users, just to obtain access to this group types mechanism. Thus
the motivation for generalizing the group types mechanism in
OpenACS 4.</p><p><span class="emphasis"><em>Object Types and
Subtypes</em></span></p><p>In OpenACS 4 <span class="emphasis"><em>object types</em></span>
generalize the OpenACS 3.x notion of group types. Each object type
can define one or more attributes to be attached to instances of
the type. This allows developers to define new types without being
artificially tied to a particular module (i.e. user/groups).</p><p>In addition, the OpenACS 4 object model provides mechanism for
defining <span class="emphasis"><em>subtypes</em></span> of
existing types. A subtype of a parent type inherits all the
attributes defined in the parent type, and can define some of its
own. The motivation for subtypes comes from the need for OpenACS to
be more extensible. In OpenACS 3.x, many applications extended the
core data models by directly adding more columns, in order to
provide convenient access to new information. This resulted in core
data tables that were too "fat", containing a hodge podge
of unrelated information that should have been normalized away. The
canonical example of this is the explosion of the <code class="computeroutput">users</code> table in OpenACS 3.x. In addition to
being sloppy technically, these fat tables have a couple of other
problems:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>They degrade performance.</p></li><li class="listitem"><p>Denormalization can make it hard to maintain consistency
constraints on the data.</p></li>
</ul></div><p>Object subtypes provide a way to factor the data model while
still keeping track of the fact that each member of a subtype (i.e.
for each row in the subtype&#39;s table), is also a member of the
parent type (i.e. there is a corresponding row in the parent type
table). Therefore, applications an use this mechanism without
worrying about this bookkeeping themselves, and we avoid having
applications pollute the core data model with their specific
information.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-attributes" id="objects-design-attributes"></a>Object Attributes, Skinny
Tables</h4></div></div></div><p>As we described above, the OpenACS 3.x user/groups system stored
object attributes in two ways. The first was to use columns in the
helper table. The second consisted of two tables, one describing
attributes and one storing values, to provide a flexible means for
attaching attributes to metadata objects. This style of attribute
storage is used in several other parts of OpenACS 3.x, and we will
refer to it as "skinny tables". For example:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>In the Ecommerce data model, the <code class="computeroutput">ec_custom_product_fields</code> table defines
attributes for catalog products, and the <code class="computeroutput">ec_custom_product_field_values</code> table stores
values for those attributes.</p></li><li class="listitem"><p>In the Photo DB data model, the <code class="computeroutput">ph_custom_photo_fields</code> table defines
attributes for the photographs owned by a specific user, and tables
named according to the convention "<code class="computeroutput">ph_user_&lt;user_id&gt;_custom_info</code>"
are used to store values for those attributes.</p></li>
</ul></div><p>In addition, there are some instances where we are not using
this model but <span class="emphasis"><em>should</em></span>, e.g.
the <code class="computeroutput">users_preferences</code> table,
which stores preferences for registered users in columns such as
<code class="computeroutput">prefer_text_only_p</code> and
<code class="computeroutput">dont_spam_me_p</code>. The
"standard" way for an OpenACS 3.x-based application to
add to the list of user preferences is to add a column to the
<code class="computeroutput">users_preferences</code> table
(exactly the kind of data model change that has historically
complicated the process of upgrading to a more recent OpenACS
version).</p><p>The Objet Model generalizes the scheme used in the old OpenACS
3.x user/groups system. It defines a table called <code class="computeroutput">acs_attributes</code> that record what attributes
belong to which object types, and how the attributes are stored. As
before, attributes can either be stored in helper tables, or in a
single central skinny table. The developer makes this choice on a
case by case basis. For the most part, attribute data is stored in
helper tables so that they can take full advantage of relational
data modeling and because they will generally be more efficient.
Occasionally, a data model will use skinny tables because doing so
allows developers and users to dynamically update the set of
attributes stored on an object without updating the data model at
the code level. The bottom line: Helper tables are more functional
and more efficient, skinny tables are more flexible but
limited.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-relation-types" id="objects-design-relation-types"></a>Relation Types</h4></div></div></div><p>Many OpenACS 3.x modules use <span class="emphasis"><em>mapping
tables</em></span> to model relationships between application
objects. Again, the 3.x user/groups system provides the canonical
example of this design style. In that system, there was a single
table called <code class="computeroutput">user_group_map</code>
that kept track of which users belonged to what groups. In
addition, as we discussed in the previous section, the system used
the <code class="computeroutput">user_group_member_fields</code>
and <code class="computeroutput">user_group_member_fields_map</code> tables to
allow developers to attach custom attributes to group members. In
fact, these attributes were not really attached to the users, but
to the fact that a user was a member of a particular group - a
subtle but important distinction.</p><p>In OpenACS 4, <span class="emphasis"><em>relation
types</em></span> generalize this mechanism. Relation types allow
developers to define general mappings from objects of a given type
T, to other objects of a given type R. Each relation type is a
subtype of <code class="computeroutput">acs_object</code>, extended
with extra attributes that store constraints on the relation, and
the types of objects the relation actually maps. In turn, each
instance of a relation type is an object that represents a single
fact of the form "the object t of type T is related to the
object r of type R." That is, each instance of a relation type
is essentially just a pair of objects.</p><p>Relation types generalize mapping tables. For example, the 3.x
user/groups data model can be largely duplicated using a single
relation type describing the "group membership" relation.
Group types would then be subtypes of this membership relation
type. Group type attributes would be attached to the relation type
itself. Group member attributes would be attached to instances of
the membership relation. Finally, the mapping table would be
replaced by a central skinny table that the relation type system
defines.</p><p>Relation types should be used when you want to be able to attach
data to the "fact" that object X and object Y are related
to each other. On the face of it, they seem like a redundant
mechanism however, since one could easily create a mapping table to
do the same thing. The advantage of registering this table as a
relation type is that in principle the OpenACS 4 object system
could use the meta data in the types table to do useful things in a
generic way on all relation types. But this mechanism doesn&#39;t
really exist yet.</p><p>Relation types are a somewhat abstract idea. To get a better
feel for them, you should just skip to the <a class="link" href="object-system-design">data
model</a>.</p>
</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-summary" id="object-system-design-summary"></a>Summary and Design
Considerations</h3></div></div></div><p>The OpenACS 4 Object Model is designed to generalize and unify
the following mechanisms that are repeatedly implemented in
OpenACS-based systems to manage generic and application specific
metadata:</p><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-why-not-objdb" id="objects-design-why-not-objdb"></a>Why not Object Databases?</h4></div></div></div><p>The presence of a framework for subtyping and inheritance always
brings up the question of why we don&#39;t just use an object
database. The main reason is that all of the major object database
vendors ship products that are effectively tied to some set of
object oriented programming languages. Their idea is to provide
tight language-level integration to lower the "impedance
mismatch" between the database and the language. Therefore,
database objects and types are generally directly modeled on
language level objects and types. Of course, this makes it nearly
impossible to interact with the database from a language that does
not have this tight coupling, and it limits the data models that we
can write to ideas that are expressible in the host language. In
particular, we lose many of the best features of the relational
database model. This is a disaster from an ease of use
standpoint.</p><p>The "Object relational" systems provide an interesting
alternative. Here, some notion of subtyping is embedded into an
existing SQL or SQL-like database engine. Examples of systems like
this include the new Informix, PostgreSQL 7, and Oracle has
something like this too. The main problem with these systems: each
one implements their own non-portable extensions to SQL to
implement subtyping. Thus, making OpenACS data models portable
would become even more difficult. In addition, each of these object
systems have strange limitations that make using inheritance
difficult in practice. Finally, object databases are not as widely
used as traditional relational systems. They have not been tested
as extensively and their scalability to very large databases is not
proven (though some will disagree with this statement).</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-oracle" id="objects-design-oracle"></a>Oracle</h4></div></div></div><p>The conclusion: the best design is to add a limited notion of
subtyping to our existing relational data model. By doing this, we
retain all the power of the relational data model while gaining the
object oriented features we need most.</p><p>In the context of OpenACS 4, this means using the object model
to make our data models more flexible, so that new modules can
easily gain access to generic features. However, while the API
itself doesn&#39;t enforce the idea that applications only use the
object model for metadata, it is also the case that the data model
is not designed to scale to large type hierarchies. In the more
limited domain of the metadata model, this is acceptable since the
type hierarchy is fairly small. But the object system data model is
not designed to support, for example, a huge type tree like the
Java runtime libraries might define.</p><p>This last point cannot be over-stressed: <span class="strong"><strong>the object model is not meant to be used for large
scale application data storage</strong></span>. It is meant to
represent and store metadata, not application data.</p>
</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-datamodel" id="object-system-design-datamodel"></a>Data Model</h3></div></div></div><p>Like most data models, the OpenACS Core data model has two
levels:</p><div class="orderedlist"><ol class="orderedlist" type="1">
<li class="listitem"><p>The <span class="emphasis"><em>knowledge level</em></span> (i.e.
the metadata model)</p></li><li class="listitem"><p>The <span class="emphasis"><em>operational level</em></span>
(i.e. the concrete data model)</p></li>
</ol></div><p>You can browse the data models themselves from here:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-metadata-create.sql&amp;package_key=acs-kernel" target="_top">acs-metadata-create.sql</a></p></li><li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-objects-create.sql&amp;package_key=acs-kernel" target="_top">acs-objects-create.sql</a></p></li><li class="listitem"><p><a class="ulink" href="/doc/sql/display-sql?url=acs-relationships-create.sql&amp;package_key=acs-kernel" target="_top">acs-relationships-create.sql</a></p></li>
</ul></div><p>(Note that we have subdivided the operational level into the
latter two files.)</p><p>The operational level depends on the knowledge level, so we
discuss the knowledge level first. In the text below, we include
abbreviated versions of the SQL definitions of many tables.
Generally, these match the actual definitions in the existing data
model but they are meant to reflect design information, not
implementation. Some less relevant columns may be left out, and
things like constraint names are not included.</p><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-knowledge-level" id="objects-design-knowledge-level"></a>Knowledge-Level Model</h4></div></div></div><p>The knowledge level data model for OpenACS objects centers
around three tables that keep track of object types, attributes,
and relation types. The first table is <code class="computeroutput">acs_object_types</code>, shown here in an
abbreviated form:</p><pre class="programlisting"><code class="computeroutput">create table acs_object_types (
        object_type          varchar(1000) not null primary key,
        supertype            references acs_object_types (object_type),
        abstract_p           char(1) default 'f' not null
        pretty_name          varchar(1000) not null unique,
        pretty_plural        varchar(1000) not null unique,
        table_name           varchar(30) not null unique,
        id_column            varchar(30) not null,
        name_method          varchar(30),
        type_extension_table varchar(30)
);
</code></pre><p>This table contains one row for every object type in the system.
The key things to note about this table are:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>For every type, we store metadata for how to display this type
in certain contexts (<code class="computeroutput">pretty_name</code> and <code class="computeroutput">pretty_plural</code>).</p></li><li class="listitem"><p>If the type is a subtype, then its parent type is stored in the
column <code class="computeroutput">supertype</code>.</p></li><li class="listitem"><p>We support a notion of "abstract" types that contain
no instances (as of 9/2000 this is not actually used). These types
exist only to be subtyped. An example might be a type representing
"shapes" that contains common characteristics of all
shapes, but which is only used to create subtypes that represent
real, concrete shapes like circles, squares, and so on.</p></li><li class="listitem"><p>Every type defines a table in which one can find one row for
every instance of this type (<code class="computeroutput">table_name</code>, <code class="computeroutput">id_column</code>).</p></li><li class="listitem"><p>
<code class="computeroutput">type_extension_table</code> is for
naming a table that stores extra generic attributes.</p></li>
</ul></div><p>The second table we use to describe types is <code class="computeroutput">acs_attributes</code>. Each row in this table
represents a single attribute on a specific object type (e.g. the
"password" attribute of the "user" type).
Again, here is an abbreviated version of what this table looks
like. The actual table used in the implementation is somewhat
different and is discussed in a separate document.</p><pre class="programlisting"><code class="computeroutput">create table acs_attributes (
        attribute_id    integer not null primary key
        object_type     not null references acs_object_types (object_type),
        attribute_name  varchar(100) not null,
        pretty_name     varchar(100) not null,
        pretty_plural   varchar(100),
        sort_order      integer not null,
        datatype        not null,
        default_value   varchar(4000),
        storage         varchar(13) default 'type_specific'
                        check (storage in ('type_specific',
                                           'generic')),
        min_n_values    integer default 1 not null,
        max_n_values    integer default 1 not null,
        static_p        varchar(1)
);
</code></pre><p>The following points are important about this table:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Every attribute has a unique identifier.</p></li><li class="listitem"><p>Every attribute is associated with an object type.</p></li><li class="listitem"><p>We store various things about each attribute for presentation
(<code class="computeroutput">pretty_name</code>, <code class="computeroutput">sort_order</code>).</p></li><li class="listitem"><p>The <code class="computeroutput">data_type</code> column stores
type information on this attribute. This is not the SQL type of the
attribute; it is just a human readable name for the type of data we
think the attribute holds (e.g. "String", or
"Money"). This might be used later to generate a user
interface.</p></li><li class="listitem"><p>The <code class="computeroutput">sort_order</code> column stores
information about how to sort the attribute values.</p></li><li class="listitem"><p>Attributes can either be stored explicitly in a table
("type specific storage") or in a skinny table
("generic storage"). In most cases, an attribute maps
directly to a column in the table identified by the <code class="computeroutput">table_name</code> of the corresponding object
type, although, as mentioned above, we sometimes store attribute
values as key-value pairs in a "skinny" table. However,
when you ask the question "What are the attributes of this
type of object?", you don&#39;t really care about how the
values for each attribute are stored (in a column or as key-value
pairs); you expect to receive the complete list of all
attributes.</p></li><li class="listitem"><p>The <code class="computeroutput">max_n_values</code> and
<code class="computeroutput">min_n_values</code> columns encode
information about the number of values an attribute may hold.
Attributes can be defined to hold 0 or more total values.</p></li><li class="listitem"><p>The <code class="computeroutput">static_p</code> flag indicates
whether this attribute value is shard by all instances of a type,
as with static member fields in C++. Static attribute are like
group level attributes in OpenACS 3.x.</p></li>
</ul></div><p>The final part of the knowledge level model keeps track of
relationship types. We said above that object relationships are
used to generalize the 3.x notion of <span class="emphasis"><em>group member fields</em></span>. These were fields
that a developer could store on each member of a group, but which
were contextualized to the membership relation. That is, they were
really "attached" to the fact that a user was a member of
a particular group, and not really attached to the user. This is a
subtle but important distinction, because it allowed the 3.x system
to store multiple sets of attributes on a given user, one set for
each group membership relation in which they participated.</p><p>In OpenACS 4, this sort of data can be stored as a relationship
type, in <a name="object-system-design-relsmodel" id="object-system-design-relsmodel"></a><code class="computeroutput">acs_rel_types</code>. The key parts of this table
look like this:</p><pre class="programlisting"><code class="computeroutput">create table acs_rel_types (
        rel_type        varchar(1000) not null
                        references acs_object_types(object_type),
        object_type_one not null
                        references acs_object_types (object_type),
        role_one        references acs_rel_roles (role),
        object_type_two not null
                        references acs_object_types (object_type),
        role_two        references acs_rel_roles (role)
        min_n_rels_one  integer default 0 not null,
        max_n_rels_one  integer,
        min_n_rels_two  integer default 0 not null,
        max_n_rels_two  integer
);
</code></pre><p>Things to note about this table:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>The main part of this table records the fact that the relation
is between instances of <code class="computeroutput">object_type_one</code> and instances of
<code class="computeroutput">object_type_two</code>. Therefore,
each instance of this relation type will be a pair of objects of
the appropriate types.</p></li><li class="listitem"><p>The <code class="computeroutput">role</code> columns store human
readable names for the roles played by each object in the relation
(e.g. "employee" and "employer"). Each role
must appear in the <code class="computeroutput">acs_rel_roles</code>.</p></li><li class="listitem"><p>The <code class="computeroutput">min_n_rels_one</code> column,
and its three friends allow the programmer to specify constraints
on how many objects any given object can be related to on either
side of the relation.</p></li>
</ul></div><p>This table is easier to understand if you also know how the
<a class="link" href="object-system-design">
<code class="computeroutput">
acs_rels</code> table</a> works.</p><p>To summarize, the <code class="computeroutput">acs_object_types</code> and <code class="computeroutput">acs_attributes</code> tables store metadata that
describes every object type and attribute in the system. These
tables generalize the group types data model in OpenACS 3.x. The
<code class="computeroutput">acs_rel_types</code> table stores
information about relation types.</p><p>This part of the data model is somewhat analogous to the data
dictionary in Oracle. The information stored here is primarily
metadata that describes the data stored in the <a class="link" href="object-system-design" title="Operational-level Data Model">operational level</a> of the data
model, which is discussed next.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-op-level" id="objects-design-op-level"></a>Operational-level Data Model</h4></div></div></div><p>The operational level data model centers around the <code class="computeroutput">acs_objects</code> table. This table contains a
single row for every instance of the type <code class="computeroutput">acs_object</code>. The table contains the
object&#39;s unique identifier, a reference to its type, security
information, and generic auditing information. Here is what the
table looks like:</p><pre class="programlisting"><code class="computeroutput">create table acs_objects (
        object_id               integer not null,
        object_type             not null
                                references acs_object_types (object_type),
        context_id              references acs_objects(object_id),
        security_inherit_p      char(1) default 't' not null,
                                check (security_inherit_p in ('t', 'f')),
        creation_user           integer,
        creation_date           date default sysdate not null,
        creation_ip             varchar(50),
        last_modified           date default sysdate not null,
        modifying_user          integer,
        modifying_ip            varchar(50)
);
</code></pre><p>As we said in Section III, security contexts are hierarchical
and also modeled as objects. There is another table called
<code class="computeroutput">acs_object_context_index</code> that
stores the context hierarchy.</p><p>Other tables in the core data model store additional information
related to objects. The table <code class="computeroutput">acs_attribute_values</code> and <code class="computeroutput">acs_static_attr_values</code> are used to store
attribute values that are not stored in a helper table associated
with the object&#39;s type. The former is used for instance
attributes while the latter is used for class-wide
"static" values. These tables have the same basic form,
so we&#39;ll only show the first:</p><pre class="programlisting"><code class="computeroutput">create table acs_attribute_values (
        object_id       not null
                        references acs_objects (object_id) on delete cascade,
        attribute_id    not null
                        references acs_attributes (attribute_id),
        attr_value      varchar(4000),
        primary key     (object_id, attribute_id)
);
</code></pre><p>Finally, the table <code class="computeroutput">acs_rels</code><a name="object-system-design-acs-rels" id="object-system-design-acs-rels"></a>is used to store object pairs
that are instances of a relation type.</p><pre class="programlisting"><code class="computeroutput">create table acs_rels (
        rel_id          not null
                        references acs_objects (object_id)
                        primary key
        rel_type        not null
                        references acs_rel_types (rel_type),
        object_id_one   not null
                        references acs_objects (object_id),
        object_id_two   not null
                        references acs_objects (object_id),
        unique (rel_type, object_id_one, object_id_two)
);
</code></pre><p>This table is somewhat subtle:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>
<code class="computeroutput">rel_id</code> is the ID of an
<span class="emphasis"><em>instance</em></span> of some relation
type. We do this so we can store all the mapping tables in this one
table.</p></li><li class="listitem"><p>
<code class="computeroutput">rel_type</code> is the ID of the
relation type to which this object belongs.</p></li><li class="listitem"><p>The next two object IDs are the IDs of the objects being
mapped.</p></li>
</ul></div><p>All this table does is store one row for every pair of objects
that we&#39;d like to attach with a relation. Any additional
attributes that we&#39;d like to attach to this pair of objects is
specified in the attributes of the relation type, and could be
stored in any number of places. As in the 3.x user/groups system,
these places include helper tables or generic skinny tables.</p><p>This table, along with <code class="computeroutput">acs_attributes</code> and <code class="computeroutput">acs_attribute_values</code> generalize the old
user/group tables <code class="computeroutput">user_group_map</code>, <code class="computeroutput">user_group_member_fields_map</code> and
<code class="computeroutput">user_group_member_fields</code>.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-discussion" id="objects-design-discussion"></a>Summary and Discussion</h4></div></div></div><p>The core tables in the OpenACS 4 data model store information
about instances of object types and relation types. The
<code class="computeroutput">acs_object</code> table provides the
central location that contains a single row for every object in the
system. Services can use this table along with the metadata in
stored in the knowledge level data model to create, manage, query
and manipulate objects in a uniform manner. The <code class="computeroutput">acs_rels</code> table has an analogous role in
storing information on relations.</p><p>These are all the tables that we&#39;ll discuss in this
document. The rest of the Kernel data model is described in the
documents for <a class="link" href="subsites-design" title="Subsites Design Document">subsites</a>, the <a class="link" href="permissions-design" title="Permissions Design">permissions</a> system and for the <a class="link" href="groups-design" title="Groups Design">groups</a>
system.</p><p>Some examples of how these tables are used in the system can be
found in the discussion of the API, which comes next.</p>
</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-api" id="object-system-design-api"></a>API</h3></div></div></div><p>Now we&#39;ll examine each piece of the API in detail. Bear in
mind that the Object Model API is defined primarily through PL/SQL
packages.</p><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-object-types" id="objects-design-object-types"></a>Object Types and Attributes</h4></div></div></div><p>The object system provides an API for creating new object types
and then attaching attributes to them. The procedures <code class="computeroutput">create_type</code> and <code class="computeroutput">drop_type</code> are used to create and delete
type definitions.</p><p>The two calls show up in the package <code class="computeroutput">acs_object_type</code>.</p><pre class="programlisting"><code class="computeroutput">  procedure create_type (
    object_type         in acs_object_types.object_type%TYPE,
    pretty_name         in acs_object_types.pretty_name%TYPE,
    pretty_plural       in acs_object_types.pretty_plural%TYPE,
    supertype           in acs_object_types.supertype%TYPE
                           default 'acs_object',
    table_name          in acs_object_types.table_name%TYPE default null,
    id_column           in acs_object_types.id_column%TYPE default 'XXX',
    abstract_p          in acs_object_types.abstract_p%TYPE default 'f',
    type_extension_table in acs_object_types.type_extension_table%TYPE
                            default null,
    name_method         in acs_object_types.name_method%TYPE default null
  );

  -- delete an object type definition
  procedure drop_type (
    object_type         in acs_object_types.object_type%TYPE,
    cascade_p           in char default 'f'
  );
</code></pre><p>Here the <code class="computeroutput">cascade_p</code> argument
indicates whether dropping a type should also remove all its
subtypes from the system.</p><p>We define a similar interface for defining attributes in the
package <code class="computeroutput">acs_attribute</code>:</p><pre class="programlisting"><code class="computeroutput">  function create_attribute (
    object_type         in acs_attributes.object_type%TYPE,
    attribute_name      in acs_attributes.attribute_name%TYPE,
    datatype            in acs_attributes.datatype%TYPE,
    pretty_name         in acs_attributes.pretty_name%TYPE,
    pretty_plural       in acs_attributes.pretty_plural%TYPE default null,
    table_name          in acs_attributes.table_name%TYPE default null,
    column_name         in acs_attributes.column_name%TYPE default null,
    default_value       in acs_attributes.default_value%TYPE default null,
    min_n_values        in acs_attributes.min_n_values%TYPE default 1,
    max_n_values        in acs_attributes.max_n_values%TYPE default 1,
    sort_order          in acs_attributes.sort_order%TYPE default null,
    storage             in acs_attributes.storage%TYPE default 'type_specific',
    static_p            in acs_attributes.static_p%TYPE default 'f'
  ) return acs_attributes.attribute_id%TYPE;

  procedure drop_attribute (
    object_type in varchar,
    attribute_name in varchar
  );

</code></pre><p>In addition, the following two calls are available for attaching
extra annotations onto attributes:</p><pre class="programlisting"><code class="computeroutput">  procedure add_description (
    object_type         in acs_attribute_descriptions.object_type%TYPE,
    attribute_name      in acs_attribute_descriptions.attribute_name%TYPE,
    description_key     in acs_attribute_descriptions.description_key%TYPE,
    description         in acs_attribute_descriptions.description%TYPE
  );

  procedure drop_description (
    object_type         in acs_attribute_descriptions.object_type%TYPE,
    attribute_name      in acs_attribute_descriptions.attribute_name%TYPE,
    description_key     in acs_attribute_descriptions.description_key%TYPE
  );
</code></pre><p>At this point, what you must do to hook into the object system
from your own data model becomes clear:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Create a table that will store the instances of the new
type.</p></li><li class="listitem"><p>Call <code class="computeroutput">acs_object_type.create_type()</code> to fill in
the metadata table on this new type. If you want your objects to
appear in the <code class="computeroutput">acs_objects</code>
table, then your new type must be a subtype of <code class="computeroutput">acs_object</code>.</p></li><li class="listitem"><p>Call <code class="computeroutput">acs_attribute.create_attribute()</code> to fill in
information on the attributes that this type defines.</p></li>
</ul></div><p>So, suppose we are writing a new version of the ticket tracker
for 4.0. We probably define a table to store tickets in, and each
ticket might have an ID and a description. If we want each ticket
to be an object, then <code class="computeroutput">ticket_id</code>
must reference the <code class="computeroutput">object_id</code>
column in <code class="computeroutput">acs_objects</code>:</p><pre class="programlisting"><code class="computeroutput">create table tickets ( 
    ticket_id references acs_objects (object_id),
    description varchar(512), 
    ... 
) ;
</code></pre><p>In addition to defining the table, we need this extra PL/SQL
code to hook into the object type tables:</p><pre class="programlisting"><code class="computeroutput">declare
 attr_id acs_attributes.attribute_id%TYPE;
begin
 acs_object_type.create_type (
   supertype =&gt; 'acs_object',
   object_type =&gt; 'ticket',
   pretty_name =&gt; 'Ticket',
   pretty_plural =&gt; 'Tickets',
   table_name =&gt; 'tickets',
   id_column =&gt; 'ticket_id',
   name_method =&gt; 'acs_object.default_name'
 );

 attr_id := acs_attribute.create_attribute (
   object_type =&gt; 'ticket',
   attribute_name =&gt; 'description',
   datatype =&gt; 'string',
   pretty_name =&gt; 'Description',
   pretty_plural =&gt; 'Descriptions'
 );

 ... more attributes ...

commit;
end;
</code></pre><p>Thus, with a small amount of extra code, the new ticket tracker
will now automatically be hooked into every generic object service
that exists. Better still, this code need not be changed as new
services are added. As an aside, the most important service that
requires you to subtype <code class="computeroutput">acs_object</code> is <a class="link" href="permissions-design" title="Permissions Design">permissions</a>.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-objects" id="objects-design-objects"></a>Objects</h4></div></div></div><p>The next important piece of the API is defined in the
<code class="computeroutput">acs_object</code> package, and is
concerned with creating and managing objects. This part of the API
is designed to take care of the mundane bookkeeping needed to
create objects and query their attributes. Realistically however,
limitations in PL/SQL and Oracle will make it hard to build generic
procedures for doing large scale queries in the object system, so
developers who need to do this will probably have to be fairly
familiar with the data model at a lower level.</p><p>The function <code class="computeroutput">acs_object.new()</code> makes a new object for
you. The function <code class="computeroutput">acs_object.del()</code> deletes an object. As
before, this is an abbreviated interface with all the long type
specs removed. See the data model or developer&#39;s guide for the
full interface.</p><pre class="programlisting"><code class="computeroutput"> function new (
  object_id     in acs_objects.object_id%TYPE default null,
  object_type   in acs_objects.object_type%TYPE
                           default 'acs_object',
  creation_date in acs_objects.creation_date%TYPE
                           default sysdate,
  creation_user in acs_objects.creation_user%TYPE
                           default null,
  creation_ip   in acs_objects.creation_ip%TYPE default null,
  context_id    in acs_objects.context_id%TYPE default null
 ) return acs_objects.object_id%TYPE;

 procedure delete (
  object_id     in acs_objects.object_id%TYPE
 );
</code></pre><p>Next, we define some generic functions to manipulate attributes.
Again, these interfaces are useful to an extent, but for large
scale queries, it&#39;s likely that developers would have to query
the data model directly, and then encapsulate their queries in
procedures.</p><p>For names, the <code class="computeroutput">default_name</code>
function is used if you don&#39;t want to define your own name
function.</p><pre class="programlisting"><code class="computeroutput"> function name (
  object_id     in acs_objects.object_id%TYPE
 ) return varchar;

 function default_name (
  object_id     in acs_objects.object_id%TYPE
 ) return varchar;

</code></pre><p>The following functions tell you where attributes are stored,
and fetch single attributes for you.</p><pre class="programlisting"><code class="computeroutput"> procedure get_attribute_storage ( 
   object_id_in      in  acs_objects.object_id%TYPE,
   attribute_name_in in  acs_attributes.attribute_name%TYPE,
   v_column          out varchar2,
   v_table_name      out varchar2,
   v_key_sql         out varchar2
 );

 function get_attribute (
   object_id_in      in  acs_objects.object_id%TYPE,
   attribute_name_in in  acs_attributes.attribute_name%TYPE
 ) return varchar2;

 procedure set_attribute (
   object_id_in      in  acs_objects.object_id%TYPE,
   attribute_name_in in  acs_attributes.attribute_name%TYPE,
   value_in          in  varchar2
 );
</code></pre><p>The main use of the <code class="computeroutput">acs_object</code> package is to create application
objects and make them available for services via the <code class="computeroutput">acs_objects</code> table. To do this, you just
have to make sure you call <code class="computeroutput">acs_object.new()</code> on objects that you wish
to appear in the <code class="computeroutput">acs_objects</code>
table. In addition, all such objects must be instances of some
subtype of <code class="computeroutput">acs_object</code>.</p><p>Continuing the ticket example, we might define the following
sort of procedure for creating a new ticket:</p><pre class="programlisting"><code class="computeroutput"> function new_ticket (
  package_id        in tickets.ticket_id%TYPE 
            default null,
  description       in tickets.description%TYPE default '',
     ...
  ) return tickets.ticket_id%TYPE 
  is 
   v_ticket_id tickets
  begin
   v_ticket_id := acs_object.new(
      object_id =&gt; ticket_id,
      object_type =&gt; 'ticket',
        ...
     );
    insert into tickets
    (ticket_id, description)
    values
    (v_ticket_id, description);
    return v_ticket_id;
  end new_ticket;
</code></pre><p>This function will typically be defined in the context of a
PL/SQL package, but we&#39;ve left it stand-alone here for
simplicity.</p><p>To summarize: in order to take advantage of OpenACS 4 services,
a new application need only do three things:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Define a data model to describe application objects. This can
just be a normal SQL table.</p></li><li class="listitem"><p>Create an object type, using code like in the example from the
previous section.</p></li><li class="listitem"><p>Make sure application objects are created using <code class="computeroutput">acs_object.new()</code> in addition to whatever
SQL code is needed to insert a new row into the application data
model.</p></li>
</ul></div><p>One of the design goals of OpenACS 4 was to provide a
straightforward and consistent mechanism to provide applications
with general services. What we have seen here is that three simple
steps and minimal changes in the application data model are
sufficient to make sure that application objects are represented in
the <code class="computeroutput">acs_objects</code> table.
Subsequently, all of the general services in OpenACS 4 (i.e.
permissions, general comments, and so on) are written to work with
any object that appears in <code class="computeroutput">acs_objects</code>. Therefore, in general these
three steps are sufficient to make OpenACS 4 services available to
your application.</p>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-relat-types" id="objects-design-relat-types"></a>Relation Types</h4></div></div></div><p>The relations system defines two packages: <code class="computeroutput">acs_rel_type</code> for creating and managing
relation types, and <code class="computeroutput">acs_rel</code> for
relating objects.</p><p>These two procedures just insert and remove roles from the
<code class="computeroutput">acs_rel_roles</code> table. This table
stores the legal relationship "roles" that can be used
when creating relation types. Examples of roles are, say,
"member", or "employer".</p><pre class="programlisting"><code class="computeroutput"> procedure create_role (
    role        in acs_rel_roles.role%TYPE
  );

  procedure drop_role (
    role        in acs_rel_roles.role%TYPE
  );
</code></pre><p>The main functions in the <code class="computeroutput">acs_rel_type</code> package are used to create and
drop relation types.</p><pre class="programlisting"><code class="computeroutput">  procedure create_type (
    rel_type            in acs_rel_types.rel_type%TYPE,
    pretty_name         in acs_object_types.pretty_name%TYPE,
    pretty_plural       in acs_object_types.pretty_plural%TYPE,
    supertype           in acs_object_types.supertype%TYPE
                           default 'relationship',
    table_name          in acs_object_types.table_name%TYPE,
    id_column           in acs_object_types.id_column%TYPE,
    abstract_p          in acs_object_types.abstract_p%TYPE default 'f',
    type_extension_table in acs_object_types.type_extension_table%TYPE
                            default null,
    name_method         in acs_object_types.name_method%TYPE default null,
    object_type_one     in acs_rel_types.object_type_one%TYPE,
    role_one            in acs_rel_types.role_one%TYPE default null,
    min_n_rels_one      in acs_rel_types.min_n_rels_one%TYPE,
    max_n_rels_one      in acs_rel_types.max_n_rels_one%TYPE,
    object_type_two     in acs_rel_types.object_type_two%TYPE,
    role_two            in acs_rel_types.role_two%TYPE default null,
    min_n_rels_two      in acs_rel_types.min_n_rels_two%TYPE,
    max_n_rels_two      in acs_rel_types.max_n_rels_two%TYPE
  );

  procedure drop_type (
    rel_type            in acs_rel_types.rel_type%TYPE,
    cascade_p           in char default 'f'
  );
</code></pre><p>Finally, the <code class="computeroutput">acs_rel</code> package
provides an API that you use to create and destroy instances of a
relation type:</p><pre class="programlisting"><code class="computeroutput">  function new (
    rel_id              in acs_rels.rel_id%TYPE default null,
    rel_type            in acs_rels.rel_type%TYPE default 'relationship',
    object_id_one       in acs_rels.object_id_one%TYPE,
    object_id_two       in acs_rels.object_id_two%TYPE,
    context_id          in acs_objects.context_id%TYPE default null,
    creation_user       in acs_objects.creation_user%TYPE default null,
    creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return acs_rels.rel_id%TYPE;

  procedure delete (
    rel_id      in acs_rels.rel_id%TYPE
  );
</code></pre><p>A good example of how to use relation types appears in the
OpenACS 4 data model for <span class="emphasis"><em>groups</em></span>. As in 3.x, group membership is
modeled using a mapping table, but now we create this mapping using
relation types instead of explicitly creating a table. First, we
create a helper table to store state on each membership fact:</p><pre class="programlisting"><code class="computeroutput">create table membership_rels (
        rel_id          constraint membership_rel_rel_id_fk
                        references acs_rels (rel_id)
                        constraint membership_rel_rel_id_pk
                        primary key,
        -- null means waiting for admin approval
        member_state    varchar(20) constraint membership_rel_mem_ck
                        check (member_state in ('approved', 'banned',
                                                'rejected', 'deleted'))
);
</code></pre><p>Then, we create a new object type to describe groups.</p><pre class="programlisting"><code class="computeroutput"> acs_object_type.create_type (
   object_type =&gt; 'group',
   pretty_name =&gt; 'Group',
   pretty_plural =&gt; 'Groups',
   table_name =&gt; 'groups',
   id_column =&gt; 'group_id',
   type_extension_table =&gt; 'group_types',
   name_method =&gt; 'acs_group.name'
 );
</code></pre><p>In this example, we&#39;ve made groups a subtype of <code class="computeroutput">acs_object</code> to make the code simpler. The
actual data model is somewhat different. Also, we&#39;ve assumed
that there is a helper table called <code class="computeroutput">groups</code> to store information on groups, and
that there is a helper table called <code class="computeroutput">group_types</code> that has been defined to store
extra attributes on groups.</p><p>Now, assuming we have another object type called <code class="computeroutput">person</code> to represent objects that can be
group members, we define the following relationship type for group
membership:</p><pre class="programlisting"><code class="computeroutput"> acs_rel_type.create_role ('member');

 acs_rel_type.create_type (
   rel_type =&gt; 'membership_rel',
   pretty_name =&gt; 'Membership Relation',
   pretty_plural =&gt; 'Membership Relationships',
   table_name =&gt; 'membership_rels',
   id_column =&gt; 'rel_id',
   object_type_one =&gt; 'group',
   min_n_rels_one =&gt; 0, max_n_rels_one =&gt; null,
   object_type_two =&gt; 'person', role_two =&gt; 'member',
   min_n_rels_two =&gt; 0, max_n_rels_two =&gt; null
 );
</code></pre><p>Now we can define the following procedure to add a new member to
a group. All this function does is create a new instance of the
membership relation type and then insert the membership state into
the helper table that we define above. In the actual
implementation, this function is implemented in the <code class="computeroutput">membership_rel</code> package. Here we just define
an independent function:</p><pre class="programlisting"><code class="computeroutput">function member_add (
    rel_id              in membership_rels.rel_id%TYPE default null,
    rel_type            in acs_rels.rel_type%TYPE default 'membership_rel',
    group               in acs_rels.object_id_one%TYPE,
    member              in acs_rels.object_id_two%TYPE,
    member_state        in membership_rels.member_state%TYPE default null,
    creation_user       in acs_objects.creation_user%TYPE default null,
    creation_ip         in acs_objects.creation_ip%TYPE default null
  ) return membership_rels.rel_id%TYPE
  is
    v_rel_id integer;
  begin
      v_rel_id := acs_rel.new (
      rel_id =&gt; rel_id,
      rel_type =&gt; rel_type,
      object_id_one =&gt; group,
      object_id_two =&gt; person,
      context_id =&gt; object_id_one,
      creation_user =&gt; creation_user,
      creation_ip =&gt; creation_ip
    );

    insert into membership_rels
     (rel_id, member_state)
    value
     (v_rel_id, new.member_state);
  end;
</code></pre><p>Another simple function can be defined to remove a member from a
group:</p><pre class="programlisting"><code class="computeroutput">  procedure member_delete (
    rel_id  in membership_rels.rel_id%TYPE
  )
  is
  begin
    delete from membership_rels
    where rel_id = membership_rel.delete.rel_id;

    acs_rel.del(rel_id);
  end;
</code></pre>
</div><div class="sect3">
<div class="titlepage"><div><div><h4 class="title">
<a name="objects-design-discuss" id="objects-design-discuss"></a>Summary and Discussion</h4></div></div></div><p>The Object Model&#39;s API and data model provides a small set
of simple procedures that allow applications to create object
types, object instances, and object relations. Most of the data
model is straightforward; the relation type mechanism is a bit more
complex, but in return it provides functionality on par with the
old user/groups system in a more general way.</p>
</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-future" id="object-system-design-future"></a>Future Improvements/Areas of
Likely Change</h3></div></div></div><p>Nothing here yet.</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-authors" id="object-system-design-authors"></a>Authors</h3></div></div></div><p>Pete Su generated this document from material culled from other
documents by Michael Yoon, Richard Li and Rafael Schloming. But,
any remaining lies are his and his alone.</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="object-system-design-revision-hist" id="object-system-design-revision-hist"></a>Revision History</h3></div></div></div><div class="informaltable"><table class="informaltable" cellspacing="0" border="1">
<colgroup>
<col><col><col><col>
</colgroup><tbody>
<tr>
<td><span class="strong"><strong>Document Revision
#</strong></span></td><td><span class="strong"><strong>Action Taken,
Notes</strong></span></td><td><span class="strong"><strong>When?</strong></span></td><td><span class="strong"><strong>By Whom?</strong></span></td>
</tr><tr>
<td>0.1</td><td>Creation</td><td>9/09/2000</td><td>Pete Su</td>
</tr><tr>
<td>0.2</td><td>Edited for ACS 4 Beta</td><td>9/30/2000</td><td>Kai Wu</td>
</tr><tr>
<td>0.3</td><td>Edited for ACS 4.0.1, fixed some mistakes, removed use of term
"OM"</td><td>11/07/2000</td><td>Pete Su</td>
</tr>
</tbody>
</table></div>
</div>
</div>
<include src="/packages/acs-core-docs/lib/navfooter"
		    leftLink="object-system-requirements" leftLabel="Prev" leftTitle="Object Model Requirements"
		    rightLink="permissions-requirements" rightLabel="Next" rightTitle="Permissions Requirements"
		    homeLink="index" homeLabel="Home" 
		    upLink="kernel-doc" upLabel="Up"> 
		