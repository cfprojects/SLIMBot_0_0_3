<!--- 
SLIMBot
Copyright 2007, Nathan Dintenfass 
[nathan AT dintenfass DOT com]
http://nathan.dintenfass.com
http://www.venturegeek.com

Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at 
http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License.
 --->

<cfcomponent hint="The base SLIMBot command -- extend this component when building a command" displayname="baseCommand">
	<!--- ALWAYS REIMPLEMENT THIS IN YOUR COMMAND --->
	<cffunction name="doCommand" access="public" output="false" hint="The main method used to perform a command -- REIMPLEMENT THIS IN YOUR COMMAND">
		<cfargument name="input" required="yes" hint="The ARGUMENTS that come after the command">
		<cfreturn>
	</cffunction>
	
		
	<!--- 
	BELOW ARE THE METHODS USED AS THE INTERNAL API OF A COMMAND BY DEVELOPERS OF COMMANDS
	 --->
	
	<!--- the method used to create a response  ---> 
	 <cffunction name="response" output="false" access="private" hint="The method used by developers of commands to create a response -- by default it sends to whoever is making the request, but that can be overridden">
	 	<cfargument name="message" required="true" hint="The text-based message that is the response">
		<cfargument name="buddyID" required="false" default="#getOriginatorID()#" hint="The person to send the message to -- defaults to whoever originated the instance of this command -- use this carefully!">
	 	<cfscript>
			//this is a bit of a shortcut, but it works for now
			arrayAppend(instance.responseQueue,duplicate(arguments));
		</cfscript>
	 </cffunction>
	
	<!--- the method to claim statefulness for a given command -- used for 'interactive' commands across messages --->
	<cffunction name="claimActiveStatus" access="private" output="false" hint="The method used internally to claim the active command status">
		<!--- it seems dirty to be calling out to the session scope here without a facade, but it would make the API much messier if you needed to pass the gateway or some other facade into every instance of a command, so in this case we are consciously breaking encapsulation to maintain a more facile API for the developer of commands under the assumption this is a fairly tight framework anyway --->
		<cfset session.activeCommand = getMyName()>
	</cffunction>
	
	<!--- a method for releasing the activeCommand -- in theory, this shouldn't be necessary given the special "quit" command, but for the sake of thoroughness it's necessary to put it in here in case someone finds a reason --->
	<cffunction name="releaseActiveStatus" access="private" output="false" hint="The method used internally to release active command status">
		<!--- once again, this is a conscious breaking of encapsulation by calling out to the session scope explicitly to make the API for command developers nicer under the assumption the framework stays cohesive --->
		<cfset session.activeCommand = "">
	</cffunction>
	
	<!--- a way to know if the current command is the active command -- once again, breaking encapsulation on purpose --->
	<cffunction name="isActive" access="private" output="false" hint="A method to know if the current command is the active command">
		<cfreturn session.activeCommand EQ getMyName()>
	</cffunction>
	
	<!--- a way to get the name of the currently running command --->
	<cffunction name="getMyName" access="private" output="false">
		<cfscript>
			var thisCommandName = listLast(getCurrentTemplatePath(),"/\");
			return left(thisCommandName,len(thisCommandName) - 4);
		</cfscript>		
	</cffunction>	
		
	<!--- a method to make the input into an array --->
	<cffunction name="tokenize" access="private" output="false" hint="Used to turn the input into an array -- uses the space as the default delimiter">
		<cfargument name="input" required="yes">
		<cfargument name="delimiter" required="false" default=" ">
		<cfreturn listToArray(arguments.input,arguments.delimiter)>
	</cffunction>
	
	<!--- get the originatorID --->
	<cffunction name="getOriginatorID" access="private" output="false" hint="Gives the ID of the Originator - the person who made the request for this instance of the command">
		<cfreturn instance.originatorID>
	</cffunction>
	
	<!--- get the CFEvent --->
	<cffunction name="getCFEvent" access="private" output="false" hint="Returns the raw CFEVENT passed by the gateway to the main listener">
		<cfreturn instance.rawEvent>
	</cffunction>
	
	<!--- get the GatewayID --->
	<cffunction name="getGatewayID" access="private" output="false" hint="Returns the GatewayID of the instance calling this command">
		<cfreturn getCFEvent().gatewayID>
	</cffunction>
	
	<!--- get the Gateway Helper --->
	<cffunction name="getHelper" access="private" output="false" hint="Get the GatewayHelper for the current gateway instance">
		<cfreturn getGatewayHelper(getGatewayID())>
	</cffunction>

	<!--- a method used for logging anything that will be specific to this instance --->	
	<cffunction name="writeLog" access="private" output="false">
		<cfargument name="text" required="true" hint="The text to log">
		<cfargument name="type" required="false" default="Information">
		<cfset instance.logger.writeLog(arguments.text,arguments.type)>
	</cffunction>	
	
	<!--- 
	BELOW ARE METHODS GENERALLY USED ONLY INTERNAL TO THE SLIMBot FRAMEWORK
	 --->
	 
	 <!--- initialize this command -- sets up the response queue, etc. --->	
	<cffunction name="init" access="public" output="false">
		<cfargument name="originatorID" required="true" hint="The ID used by the gateway for the originator of the message -- used as the default for all results">
		<cfargument name="rawEvent" required="true" hint="The raw 'CFEVENT' passed by the gateway to the listener">
		<cfargument name="logger" required="true" hint="The logging component to use for logging inside this command instance">
		<cfscript>
			//set up the response queue and other things related to this instance
			variables.instance = structNew();
			instance.responseQueue = arrayNew(1);
			instance.originatorID = arguments.originatorID;
			instance.rawEvent = arguments.rawEvent;
			instance.logger = arguments.logger;
			return this;
		</cfscript>
	</cffunction>
	
	<!--- get the response queue --->
	<cffunction name="getResponseQueue" access="public" output="false" hint="The method used internal to the SLIMBot framework to get the queue of responses to process for a given request">
		<cfreturn instance.responseQueue>
	</cffunction>
	
</cfcomponent>