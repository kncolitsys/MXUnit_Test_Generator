
<cfcomponent >

	<cfscript>
	this.name = "MXUnit Test Generator Extension";
	this.sessionManagement = true;
	</cfscript>
	
	<cffunction name="onRequestStart" returnRequest="boolean" output="false">
		<cfsetting showdebugoutput="false" enablecfoutputonly="false" />
	</cffunction>
	
</cfcomponent>
