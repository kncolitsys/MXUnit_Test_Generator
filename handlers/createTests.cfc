component displayname="createTests" hint="This is the main component for the MXUnit Test Generator" {

	string function generateTest(	required boolean isScript,
								 	required array cfcFunctionList, 
									required string cfcName, 
									required string mxunitBaseClass, 
									required boolean commentOut,
									required boolean useNew,
									required boolean makeBaseAssertions,
									required boolean allArguments,
									required boolean makePublic )
	{
		var lb = chr( 13 ) & chr( 10 );
		var iterator = "";
		var element = "";
		var c = "";
		var i = "";
		var elementFlag = false;
		
		if( isScript ) {
			
			//Create the component and the setUp() method
			var results = 	"component displayName=""" & arguments.cfcName & " Unit Tests"" hint=""This is the unit test class for the "
							& arguments.cfcName & " CFC"" extends=""" & arguments.mxunitBaseClass & """ {" & lb & lb
							& tab(1) & "void function setUp(){" & lb;
							
			if( arguments.useNew ) {
				results = results & tab(2) & "variables.component = new " & arguments.cfcName & "();" & lb;
			} else {
				results = results & tab(2) & "variables.component = createObject( ""component"", """ & arguments.cfcName & """ );" & lb;
			}			
							
			results = results & tab(1) & "}" & lb & lb;
			
			//Then, create a test for each method in the component
			for( c = 1; c <= arrayLen( arguments.cfcFunctionList ); c = c+1 ) {
				element = arguments.cfcFunctionList[c];
				if( arguments.commentOut ) {
					results = results & tab(1) & "/*" & lb;
				}
				
				var first = structKeyExists( element, 'access' ) && element.access != 'private';
				var second = !structKeyExists( element, 'access' );
				var third = arguments.makePublic;
				
				if( ( structKeyExists( element, "access" ) && element.access != "private" ) || !structKeyExists( element, "access" ) || arguments.makePublic ) {					
				
					results = 	results & tab(1) & "void function test_" & element.name & "(){" & lb;
				
					if( arguments.makePublic && ( structKeyExists( element, "access" ) && element.access == "private" ) ) {
						results = 	results & tab(2) & "makePublic( variables.component, """ & element.name & """, ""_" & element.name & """ );" & lb
									& tab(2) & "var result = variables.component._" & element.name & "( ";
					} else if ( ( structKeyExists( element, "access" ) && element.access != "private" ) || !structKeyExists( element, "access" ) ) {
						results = results & tab(2) & "var result = variables.component." & element.name & "( ";	
					}
				
					//Loop through the parameters and include any required ones
					for( i = 1; i <= arrayLen( element.parameters ); i = i+1 ) {
						if( structKeyExists( element.parameters[i], "required" ) ) {
							if( element.parameters[i].required || arguments.allArguments ) {
								if( i > 1 && elementFlag ) {
									results = results & ", ";
								}
								if( element.parameters[i].name != "") { 
									elementFlag = true;
									results = results & element.parameters[i].name & " = """"";
								}
							}
						}
					}
					elementFlag = false;
					
					results = 	results & " );" & lb;
					
					//Determine if we should make base assertions
					if( arguments.makeBaseAssertions && structKeyExists(element, "returnType" ) ) {
						switch( element.returnType ) {
							case "any":
								break;
							case "array":
								results = results & tab(2) & "assert( isArray( result ) );" & lb;
								break;
							case "binary":
								results = results & tab(2) & "assert( isBinary( result ) );" & lb;
								break;
							case "boolean":
								results = results & tab(2) & "assert( isBoolean( result ) );" & lb;
								break;
							case "date":
								results = results & tab(2) & "assert( isDate( result ) );" & lb;
								break;
							case "guid":
								results = results & tab(2) & "assert( isValid( ""guid"", result ) );" & lb;
								break;
							case "numeric":
								results = 	results & tab(2) & "assert( isNumeric( result ) );" & lb
											& tab(2) & "assert( isValid( ""regex"", result, ""^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$"" ) ); //NOTE: This allows for positive and negative integers as well as decimals. No commas." & lb; 
								break;
							case "query":
								results = results & tab(2) & "assert( isQuery( result ) );" & lb;
								break;
							case "string":
								results = results & tab(2) & "assert( isValid( ""string"", result ) );" & lb;
								break;
							case "struct":
								results = results & tab(2) & "assert( isStruct( result ) );" & lb;
								break;
							case "uuid":
								results = results & tab(2) & "assert( isValid( ""uuid"", result ) );" & lb;
								break;
							case "xml":
								results = results & tab(2) & "assert( isXml( result ) );" & lb;
								break;
							case "void":
								break;
							default:
								results = results & tab(2) & "assert( isObject( result ) );" & lb;
								break;
						}
					}
					
					results = results & tab(1) & "}";
					
					if( arguments.commentOut ) {
						results = results & lb & tab(1) & "*/";
					}
					
					results = results & lb & lb;
				
				}
							
			}
			
			//Create the tearDown function
			results = 	results & tab(1) & "void function tearDown(){" & lb & lb
						& tab(1) & "}" & lb & lb
						& "}";
										
		} else {
		
			//Create the component and the setUp() method
			var results = 	"<cfcomponent displayName=""" & arguments.cfcName & " Unit Tests"" hint=""This is the unit test class for the "
							& arguments.cfcName & " CFC"" extends=""" & arguments.mxunitBaseClass & """ >" & lb & lb
							& tab(1) & "<cffunction name=""setUp"">" & lb;
							
			if( arguments.useNew ) {
				results = results & tab(2) & "<cfset variables.component = new " & arguments.cfcName & "()/>" & lb;
			} else {
				results = results & tab(2) & "<cfset variables.component = createObject( ""component"","" " & arguments.cfcName & """ )/>" & lb;
			}							
							
			results = results & tab(1) & "</cffunction>" & lb & lb;
			
			//Then, create a test for each method in the component
			for( c=1; c <= arrayLen( arguments.cfcFunctionList ); c = c+1) {
				element = arguments.cfcFunctionList[c];
				
				if( arguments.commentOut ) {
					results = results & tab(1) & "<!---" & lb;
				}
				
				if( ( structKeyExists( element, "access" ) && element.access != "private" ) || !structKeyExists( element, "access" ) || arguments.makePublic ) {					
				
					results = results & tab(1) & "<cffunction name=""test_" & element.name & """>" & lb;
				
					if( arguments.makePublic && ( structKeyExists( element, "access" ) && element.access == "private" ) ) {
						results = 	results & tab(2) & "<cfset makePublic( variables.component, """ & element.name & """, ""_" & element.name & """ ) >" & lb
									& tab(2) & "<cfset var result = variables.component._" & element.name & "( ";
					} else if ( ( structKeyExists( element, "access" ) && element.access != "private" ) || !structKeyExists( element, "access" ) ) {
						results = results & tab(2) & "<cfset var result = variables.component." & element.name & "( ";
					}
					
					//Loop through the parameters and include any required ones
					for( i = 1; i <= arrayLen( element.parameters ); i = i+1 ) {
						if( structKeyExists( element.parameters[i], "required" ) ) {
							if( element.parameters[i].required || arguments.allArguments ) {
								if( i > 1 && elementFlag ) {
									results = results & ", ";
								}
								if( element.parameters[i].name != "") {
									elementFlag = true; 
									results = results & element.parameters[i].name & " = """"";
								}
							}
						}
					}
					elementFlag = false;
					
					results = results & " )/>" & lb;
					
					//Determine if we should make base assertions
					if( arguments.makeBaseAssertions && structKeyExists(element, "returnType" ) ) {
						switch( element.returnType ) {
							case "any":
								break;
							case "array":
								results = results & tab(2) & "<cfset assert( isArray( result ) ) >" & lb;
								break;
							case "binary":
								results = results & tab(2) & "<cfset assert( isBinary( result ) ) >" & lb;
								break;
							case "boolean":
								results = results & tab(2) & "<cfset assert( isBoolean( result ) ) >" & lb;
								break;
							case "date":
								results = results & tab(2) & "<cfset assert( isDate( result ) ) >" & lb;
								break;
							case "guid":
								results = results & tab(2) & "<cfset assert( isValid( ""guid"", result ) )>" & lb;
								break;
							case "numeric":
								results = 	results & tab(2) & "<cfset assert( isNumeric( result ) ) >" & lb
											& tab(2) & "<cfset assert( isValid( ""regex"", result, ""^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$"" ) )> <!---NOTE: This allows for positive and negative integers as well as decimals. No commas.--->" & lb; 
								break;
							case "query":
								results = results & tab(2) & "<cfset assert( isQuery( result ) ) >" & lb;
								break;
							case "string":
								results = results & tab(2) & "<cfset assert( isValid( ""string"", result ) ) >" & lb;
								break;
							case "struct":
								results = results & tab(2) & "<cfset assert( isStruct( result ) ) >" & lb;
								break;
							case "uuid":
								results = results & tab(2) & "<cfset assert( isValid( ""uuid"", result ) ) >" & lb;
								break;
							case "xml":
								results = results & tab(2) & "<cfset assert( isXml( result ) ) >" & lb;
								break;
							case "void":
								break;
							default:
								results = results & tab(2) & "<cfset assert( isObject( result ) ) >" & lb;
								break;
						}
					}
					
					results = results & tab(1) & "</cffunction>";
						
					if( arguments.commentOut ) {
						results = results & lb & tab(1) & "--->";
					}	
					
					results = results & lb & lb;
				
				}
				
			}
			
			//Create the tearDown function
			results = 	results & tab(1) & "<cffunction name=""tearDown"">" & lb & lb
						& tab(1) & "</cffunction>" & lb & lb
						& "</cfcomponent>";
				
		}
		
		return results;					
	}
	
	boolean function saveConfig(	required string mxunitBaseClass, 
									required string filePath, 
									required boolean isScript,
									required boolean commentOut,
									required boolean useNew,
									required boolean makeBaseAssertions,
									required boolean allArguments,
									required boolean makePublic )
	{
		//Here we save all our config information so the user doesn't have to worry about their config moving forward.
		var testDirectory = arguments.filePath;
		var configPath = getDirectoryFromPath( getCurrentTemplatePath() );
		
		config =  "	<document>
						<testDirectory>" & testDirectory & "</testDirectory>
						<baseClass>" & arguments.mxunitBaseClass & "</baseClass>
						<isScript>" & arguments.isScript & "</isScript>
						<commentOut>" & arguments.commentOut & "</commentOut>
						<useNew>" & arguments.useNew & "</useNew>
						<makeBaseAssertions>" & arguments.makeBaseAssertions & "</makeBaseAssertions>
						<allArguments>" & arguments.allArguments & "</allArguments>
						<makePublic>" & arguments.makePublic & "</makePublic>
					</document>";
		
		try{
			fileWrite( configPath & "config_settings.xml", config );
			
		} catch( any e ) {
			writeLog( type="Error", file="exception", text="[#e.type#] #e.message#" );
			return false;
		}
		
		return true;
	}
	
	boolean function saveUnitTests( required string testText, required string filePath, required string cfcName, required string mxunitBaseClass ) {
		
		//First, create the directory if it doesn't exist
		if( !directoryExists( arguments.filepath ) ) {
			try {
				directoryCreate( arguments.filePath );
			}
			catch( any e ){
				writeLog( type="Error", file="exception", text="[#e.type#] #e.message#" );
				return false;
			}
		}
		
		//Then, save the unit test
		var fullPath = arguments.filePath & "/" & cfcName & "_Test.cfc";
		try {
			fileWrite( fullPath, arguments.testText );
		}
		catch( any e ){
			writeLog( type="Error", file="exception", text="[#e.type#] #e.message#" );
			return false;
		}
		
		return true;
	}
	
	
	/*
		This was given to me by Steve Erat http://www.talkingtree.com/blog/ 
		and is used with permission from CF Commons http://www.cfcommons.org/
	*/
	string function getDotNotationClassPath( required string absolutePath ) {
		
		var pathForward = replace( arguments.absolutePath, '/', '\', 'all' );
		var pathBackward = replace( arguments.absolutePath, '\', '/', 'all' );
		var root = replace( expandPath("/"), '\', '/', 'all' );
		var factory = "";
		var runtime = "";
		var mappingPrefix = "";
		var bRootMatched = true;
		var bMappingMatched = false;
		
		// check to see if the system root path exists within the absolute path
		if ( !findNoCase( root, pathBackward ) ) {
		      bRootMatched = false;
		      
		      // root path not matched, so iterate over CF mappings to attempt to match cfc file path to a mapping path
		      factory = createObject( "java", "coldfusion.server.ServiceFactory" );
		      runtime = factory.getRuntimeService();
		      for ( key in runtime.mappings ) {
			  		if ( findNoCase(runtime.mappings[key], pathForward ) || findNoCase( runtime.mappings[key], pathBackward ) ) {
		                  root = runtime.mappings[key];
		                  // mappingPrefix used as the first node in the dot path. 
		                  // e.g. /mxunit might map to C:\mxunit2.0.2 so use just "mxunit" in dot notation not "mxunit2.0.2"
		                  mappingPrefix = listlast( key, "/" );
		                  bMappingMatched = true;
		                  break;
		            }
		      }
		}
		
		// short circuit: if cannot match absolutePath to a root path or to CF mapping, 
		// then give up and return the orignal absolute path
		if ( !bRootMatched && !bMappingMatched )
		      return arguments.absolutePath;
		root = replace( root, '\', '/', 'all' );
		if( left( root,1 ) == '/'){
			root = right( root, len( root )-1 );
		}
		
		var path = replaceNoCase( pathBackward, root, "", "one" );
		if( right( path, 1 ) == '/' ) {
			path = left( path, len( path )-1) ;
		}   
		path = mappingPrefix & path;
		path = replace( path, ".cfc", "", "one" );
		// handle Windows and Unix paths
		path = replace( path, "\", ".", "all" );
		path = replace( path, "/", ".", "all" );
		
		// success: Resolved the absolutePath to a dot notation class path
		return path;
	}	
	
	private function tab(required times){
		var tabs = "";
		var i = "";
		for(i=1;i LTE arguments.times;i=i+1){
			tabs = tabs & chr(9);
		}
		return tabs;
	}
	
}
