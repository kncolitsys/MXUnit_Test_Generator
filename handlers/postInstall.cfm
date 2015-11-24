<!---<cfparam name="ideEventInfo" />

<cfif not isXML(ideEventInfo)>
	<cfexit />
</cfif>

<cfset data = xmlParse(ideeventinfo)/>
<cfset testDirectory = data.event.user.page.input.xmlAttributes.value />
<cfset configPath = #getDirectoryFromPath(getCurrentTemplatePath())# />

<cfoutput>
<cfsavecontent variable="config">
	<testDirectory>#testDirectory#</testDirectory>
</cfsavecontent>
</cfoutput>

<cftry>
	<cffile action="write" file="#configPath#config_settings.xml" output="#config#"/>	
<cfcatch type="any" >
	<cfset message = cfcatch.Detail />
	<cflog text="#message#" file="exception" type="error"  />
</cfcatch>
</cftry>--->