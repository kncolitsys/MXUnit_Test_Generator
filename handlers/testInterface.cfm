<cfscript>
	path = getDirectoryFromPath( getCurrentTemplatePath() );
	fullPath = path & "config_settings.xml";
	
	if( fileExists( fullPath ) ) {
		
		configFile = fileRead( fullPath );
		data = xmlParse( configFile );
		
		if( !isNull( data.document.testDirectory ) ) {
			configPath = data.document.testDirectory.xmlText;
		}
		
		if( !isNull( data.document.baseClass ) ) {
			baseClass = data.document.baseClass.xmlText;
		}
		
		if( !isNull( data.document.isScript ) ) {
			isScript = data.document.isScript.xmlText;
		}
		
		if( !isNull( data.document.commentOut ) ) {
			commentOut = data.document.commentOut.xmlText;
		}
		
		if( !isNull( data.document.useNew ) ) {
			useNew = data.document.useNew.xmlText;
		}
		
		if( !isNull( data.document.makeBaseAssertions ) ) {
			makeBaseAssertions = data.document.makeBaseAssertions.xmlText;
		}
		
		if( !isNull( data.document.allArguments ) ) {
			allArguments = data.document.allArguments.xmlText;
		}
		
		if( !isNull( data.document.makePublic ) ) {
			makePublic = data.document.makePublic.xmlText;
		}
		
	}
	
	param name="configPath" default="";
	param name="baseClass" default="mxunit.framework.TestCase";
	param name="isScript" default="false";
	param name="commentOut" default="false";
	param name="useNew" default="false";
	param name="makeBaseAssertions" default="false";
	param name="allArguments" default="false";
	param name="makePublic" default="false";
	
</cfscript>

<cfsavecontent variable="response">
	<cfoutput> 
	<response> 
		<ide handlerfile="createTests.cfm"> 
			<dialog width="800" height="600"> 
				<cfif configPath NEQ "">
					<input name="configPath" type="projectdir" default="#configPath#" tooltip="This is the directory the unit test will be saved into" label="Directory where the unit test will be saved" required="true"/>
				<cfelse>
					<input name="configPath" type="projectdir" default="{$projectlocation}/unitTests" tooltip="This is the directory the unit test will be saved into" label="Directory where the unit test will be saved" required="true"/>
				</cfif>
				<input name="mxunitBaseClass" label="Component that contains your MXUnit Base Class" type="string" default="#baseClass#" required="true" />				
				<input name="isScript" label="Generate as cfscript" tooltip="Determines if the unit test is in cfscript" type="boolean" checked="#isScript EQ "false" ? "false" : "true"#" />				
				<input name="commentOut" label="Comment out tests by default" tooltip="Comment outs tests by default" type="boolean" checked="#commentOut EQ "false" ? "false" : "true"#" />
				<input name="useNew" label="Use 'new' instead of 'createObject'" tooltip="Use the 'new' keyword to instantiate your obect instead of 'createObject'" type="boolean" checked="#useNew EQ "false" ? "false" : "true"#" />
				<input name="makeBaseAssertions" label="Make basic assertions based upon return types" tooltip="Make basic assertions based upon the return type of the method" type="boolean" checked="#makeBaseAssertions EQ "false" ? "false" : "true"#" />
				<input name="allArguments" label="Include all arguments to the method invocation, not just the required ones" tooltip="Include all arguments to the methods, not just the required ones" type="boolean" checked="#allArguments EQ "false" ? "false" : "true"#" />
				<input name="makePublic" label="Make private methods public" tooltip="Make private methods public" type="boolean" checked="#makePublic EQ "false" ? "false" : "true"#" />
			</dialog> 
		</ide> 
	</response> 
	</cfoutput>
</cfsavecontent>

<cfheader name="Content-Type" value="text/xml">
<cfoutput>#response#</cfoutput>