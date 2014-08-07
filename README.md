apex-utils-bulk
===============

The purpose of this class is to give a set of util methods to help the developers when they have to write a method that must deal with a bunch of Objects or SObjects. Almost every Apex method must be list-oriented because it is going to be executed from a Trigger or a Web Service. This creates some situations where the developer must group records, transform Lists of records to Maps, suffer governor limits, etc.

<h3>Features</h3>
<ul>
	<li>It uses the Singleton pattern.</li>
	<li>It allows reusing a group.</li>
	<li>It allows having multiple groups at the same time.</li>
	<li>You can group by a List or a Map.</li>
	<li>In a trigger context, you can compare the old and new values in a cool way :)</li>
	<li>You can convert a List of SObjects to a Map or a grouped Map based on a field of your choice.</li>
</ul>

See the full reference <a href="http://www.valnavjo.com/blog/?p=9" target="_blank">here</a>.

Be Apex my friend!
