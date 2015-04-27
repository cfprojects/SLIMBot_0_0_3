Smart, Lightweight Instant Messaging Bot (SLIMBot)
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



********** TO INSTALL ************

[NOTE: This assumes you already have an IM account set up -- as of now
this has only been tested using a Google Talk account, but in theory it
should work on any XMPP-compatible IM.  It is not yet built to work
through SMS]

1) Please the contents of the slimbot directory somewhere accessible to
ColdFusion.  I put mine in the "gateway" directory under the CFMX root.

2) Make a copy of the slimbot_template.cfg file in the "instances"
directory -- you will then configure this to your particular instance
and name it appropriately.

3) Go the ColdFusion Administrator "Event Gateways" section on the
"Gateway Instances" -- create a new instance of gateway type XMPP, point
the CFC path to the slimbotGateway.cfc in the root slimbot folder; point
to the configuration file you created in the "instances" directory.

4) Start the instance -- assuming you have the right IM handle in your
buddy list, you can now send commands.  The simplest one to try is "echo
foo" -- if you get back "foo" it's working.





********** FOR ALPHA TESTERS ************ 

There is a "TODO" comments
section in the main slimbotGateway.cfc file.  Also check out the code in
the baseCommand.cfc in the "commands" directory.

I have set up an instance running under the Google Talk handle
cfimcli@gmail.com that you should be able to use to see it in action,
but please do not use it a lot, as it's running on a machine not ready
for production use.

Other questions:

- Do you like the way the commands are created? - Is the state mechanism
fairly clear? (see the "weather" command for a simple example) -
Configuration of instances is a big thing not represented in the current
release -- how would you want it to happen?


********** FOR COMMAND DEVELOPERS ************ 

Documentation on creating commands will come as the package matures, but for now you should be able to look through the examples that ship with the releases to get a sense of it.  

But, here's the short version:

Every command lives in the "commands" directory.  The file should be named whatever you want to call your command with a ".cfc" extension.  So, if you want your command to be "foo" your file would be "foo.cfc" in the "commands" directory inside your slimbot install root.

To make a command you extend the baseCommand (which lives in the "commands" directory, so you don't need an absolute path, just its name).

After you create a CFC that extends the baseCommand you implement the "doCommand" method, which takes one argument called "input" -- input is whatever comes after the command the end user types in, and each command can deal with it however it likes [ALPHA TESTERS: DO WE NEED A STANDARD WAY TO DEAL WITH 'FLAGS' FOR COMMANDS THE WAY, FOR INSTANCE, UNIX COMMAND LINE ARGUMENTS ARE DONE?]

The key method to know about from the baseCommand is called RESPONSE -- it has one required argument, the text that should be sent back through the gateway.  An optional second argument lets you override who that response is sent to (but, be warned, most IM services won't send messages to Buddy IDs that do not have the buddy of your instance as a buddy).  You can send as many responses as you like -- each will go out as part of the request.

The other methods worth knowing about are (for now, no explanation -- you'll need to figure them out for yourself as an alpha tester, and no promises this list will stay current until we get to a mature release):

claimActiveStatus
releaseActiveStatus
isActive
getMyName
tokenize
getOriginatorID
getCFEvent

For the alpha testing period, please see the baseCommand.cfc code to learn how these are used and what they do.  Or, just look at the examples -- the weather command, for instance, uses many of these.
