<cfscript>
	param name = "ideEventInfo" default = "";
	param name = "message" default = "";

	try {	
		//If our response was not XML, stop processing.
		if( !isXml( ideEventInfo ) ) {
			throw "The response from the wizard was not in xml format. Not sure how _that_ happens...";
		}
	
		testObj = new createTests();	
		
		//The inputs are in the same order as the interface for readability
		data = xmlParse( ideeventinfo );
		resource = data.event.ide.projectview.resource;
		input = data.event.user.input;
		
		for( i = 1; i <= arrayLen(input); i++  ) {
			switch( input[i].xmlAttributes.name ) {
				case "configPath":
					configPath = input[i].xmlAttributes.value;
					break;
				case "mxunitBaseClass":
					mxunitBaseClass = input[i].xmlAttributes.value;
					break;
				case "isScript":
					isScript = input[i].xmlAttributes.value;
					break;
				case "commentOut":
					commentOut = input[i].xmlAttributes.value;
					break;
				case "useNew":
					useNew = input[i].xmlAttributes.value;
					break;
				case "makeBaseAssertions":
					makeBaseAssertions = input[i].xmlAttributes.value;
					break;
				case "allArguments":
					allArguments = input[i].xmlAttributes.value;
					break;
				case "makePublic":
					makePublic = input[i].xmlAttributes.value;
				default:
					break;
			}
		}
		
		/*
			This was taken from Ben Nadel's blog and is for refreshing the project:
			http://www.bennadel.com/blog/1758-My-First-ColdFusion-Builder-Extension-Encrypting-And-Decrypting-CFM-CFC-Files.htm
		*/
		projectNode = xmlSearch( data, "//projectview[ position() = 1 ]/@projectname" );
	
		//Make sure we're pointing to a component we are going to generate stubs for.
		if( resource.xmlAttributes.type == "file" ) {
			cfcName = replaceNoCase( getFileFromPath( resource.xmlAttributes.path ), ".cfc", "" );
		} else {
			throw "Can't generate unit tests for a file that isn't a cfc. Nice try!";
		}
	
		//Determine the dot notation class path so we can instantiate the component.
		cfcDotNotation = testObj.getDotNotationClassPath( resource.xmlAttributes.path, data.event.ide.projectview.xmlAttributes.projectLocation );
	
		if( cfcDotNotation != resource.xmlAttributes.path ) {	
			
			obj = createObject("component",#cfcDotNotation#);
			
			if( !isObject( obj ) ) {
				throw "Couldn't instantiate the component. Something's amiss!";
			}
			
			cfcFunctionList = {};
			
			cfcFunctionList = getMetadata( obj ).functions;
			
			if( configPath == "" ) {
				message = "Path to save the MXUnit test is not defined. Please define a path and try again.";
			}
			
			if( mxunitBaseClass == "") {
				mxunitBaseClass = "mxunit.framework.TestCase";
			}
			
			//Here we generate the actual code for the unit tests
			try{
				text = testObj.generateTest(	isScript = isScript, 
												cfcFunctionList = cfcFunctionList, 
												cfcName = cfcDotNotation, 
												mxunitBaseClass = mxunitBaseClass, 
												commentOut = commentOut, 
												useNew = useNew, 
												makeBaseAssertions = makeBaseAssertions,
												allArguments = allArguments,
												makePublic = makePublic );
			}
			catch ( any e ){
				writeDump(e);
				abort;
			}

			
			//Then we write it out to a file
			success = testObj.saveUnitTests( testText =  text, filePath = configPath, cfcName = cfcName, mxunitBaseClass = mxunitBaseClass );
			
			if( !success ) {
				message = "There was an error trying to save the unit test. Please check your error logs.";
			}
			
			//Finally, we save our conifguration
			testObj.saveConfig( filePath = configPath, 
								isScript = isScript, 
								mxunitBaseClass = mxunitBaseClass, 
								commentOut = commentOut, 
								useNew = useNew,
								makeBaseAssertions = makeBaseAssertions,
								allArguments = allArguments,
								makePublic = makePublic );
			
		} else {			
			message = "Error determining the dot notation path for the component. You may need to create mappings in the administrator.";			
		}
		
	} catch( any e ) {
		message = e.message;
	}
</cfscript>

<cfheader name="Content-Type" value="text/xml">
<cfoutput>
<cfif message NEQ "">
	<response showresponse="true">
		<ide>
<cfelse>
	<response showResponse="false" status="success">
		<ide message="The MXUnit test for #cfcName# was created successfully">
			<commands> 
				<!--- Commented this out for now as a project refresh can take a considerable amount of time --->
			
		        <!---<command type="refreshproject"> 
			        <params> 
						<!--- This was taken from Ben Nadel's blog and is for refreshing the project:
						http://www.bennadel.com/blog/1758-My-First-ColdFusion-Builder-Extension-Encrypting-And-Decrypting-CFM-CFC-Files.htm
						 --->
			       		<param key="projectname" value="#projectNode[ 1 ].xmlValue#" /> 
			        </params> 
		        </command> --->
		        
		        <command type="openfile">
					<params>
						<param key="filename" value="#configPath#/#cfcName#_Test.cfc" />
					</params>
				</command>				
				
				<command type="refreshfolder">
					<params>
						<param key="foldername" value="#configPath#" />
					</params>
				</command>
				
	   		</commands> 
</cfif>
		<dialog width="800" height="600" /> 
		<body> 
			<![CDATA[ 
				#message#
			]]> 
		</body> 
	</ide>
</response>
</cfoutput>

<!---  
		ATTRIBUTIONS AND THANKS
		
		I referenced some methods from about three of Ray Camden's blog posts in the creation of this extension:
		http://www.coldfusionjedi.com/index.cfm/2010/3/26/Tips-for-folks-new-to-CFBuilder-and-the-Eclipse-Platform
		http://www.coldfusionjedi.com/index.cfm/2009/6/19/Quick-ColdFusion-Builder-Extension-Demo
		http://www.coldfusionjedi.com/index.cfm/2010/1/11/Proof-of-Concept-CFBuilder-Extension-convertToCFSCRIPT
--->