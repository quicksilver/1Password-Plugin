//
//  OnePasswordAction.m
//  OnePassword
//
//  Created by Patrick Robertson on 15/01/2010.
//  Copyright Patrick Roberston 2010. All rights reserved.
//
//	This file is part of Quicksilver 1Password Module.
//
//	Quicksilver 1Password Module is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	Quicksilver 1Password Module is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with Quicksilver 1Password Module.  If not, see <http://www.gnu.org/licenses/>.
//


#import "OnePasswordAction.h"
#import <QSCore/QSObject_FileHandling.h>

@implementation OnePasswordAction

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
	
	// Only allow the 'View in 1Password action to appear if there's only one item (no comma trick)
	if ([dObject count] == 1)
	{
		return [NSArray arrayWithObject:@"viewInOnePwd"];
	}
	// Else don't show it
	return nil;
}

// Method to only show browsers in the 3rd pane for the 'Go & Fill With...' action
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
// only for 'Go & Fill With...' action
	if (![action isEqualToString:@"goAndFillWith"]) {
		return nil;
	}
	NSArray *validBrowsers = [NSArray arrayWithObjects:@"org.mozilla.firefox",
							  @"com.apple.Safari",@"com.google.Chrome",@"org.mozilla.camino",
							  @"com.omnigroup.omniweb",@"com.ranchero.NetNewsWire",
							  @"com.fluidapp.Fluid",@"com.devon-technologies.agent",@"de.icab.iCab",@"org.webkit.nightly.WebKit",nil];
	NSMutableArray *validIndirects = [NSMutableArray arrayWithCapacity:1];
	NSMutableSet *set = [NSMutableSet set];

	
	NSMutableArray *validBrowserPaths = [NSMutableArray arrayWithCapacity:1];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	for(NSString *browserID in validBrowsers) {
		NSString *browserPath = [ws absolutePathForAppBundleWithIdentifier:browserID];
		if (browserPath) {
			[validBrowserPaths addObject:browserPath];
		}
	}
	// Get the default app for the url
	NSURL *appURL = nil;
	LSGetApplicationForURL((CFURLRef)[NSURL URLWithString:@"http://"], kLSRolesAll, NULL, (CFURLRef *)&appURL);
	
	// Set the default app to be 1st in the returned list
	id preferred = [QSObject fileObjectWithPath:[appURL path]];
	if (!preferred) {
		preferred = [NSNull null];
	}
	
	[appURL release];
	
	[set addObjectsFromArray:validBrowserPaths];
	validIndirects = [[QSLibrarian sharedInstance] scoredArrayForString:nil inSet:[QSObject fileObjectsWithPathArray:[set allObjects]]];
	
	return [NSArray arrayWithObjects:preferred, validIndirects, nil];
}




- (QSObject *)goAndFill:(QSObject *)dObject{
	[self goAndFill:dObject with:nil];
	return nil;
}

- (QSObject *)goAndFill:(QSObject *)dObject with:(QSObject *)iObject {
	
			// for each object - do exactly the same thing as for single objects
			//	ß61 method
	//for (QSObject *goAndFillObject in [dObject splitObjects]) {
//		[self writePlistAndFill:goAndFillObject withBrowsers:iObject];
//	}
	if ([dObject count] > 1) {
		for (QSObject *goAndFillObject in [dObject objectForCache:kQSObjectComponents]) {
					[self writePlistAndFill:goAndFillObject withBrowsers:iObject];
		}
	}
	else {
		[self writePlistAndFill:dObject withBrowsers:iObject];
	}


	return nil;
}

- (QSObject *)viewInOnePwd:(QSObject *)dObject {
	
	// setup the terminal command
	NSString *command = @"defaults write ws.agile.1Password findUUID ";
	command = [command stringByAppendingString:[dObject identifier]];
	
	// load the script from a resource by fetching its URL from within our bundle
	NSString *path=[[NSBundle bundleForClass:[self class]] pathForResource:@"RevealIn1Pwd" ofType:@"scpt"];
	if (path != nil)
	{
		NSDictionary* scptErrors = [NSDictionary dictionary];
		NSAppleScript* appleScript =
		[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&scptErrors];
		if (appleScript != nil)
		{
			// create the parameters
			NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:[dObject name]];
			NSAppleEventDescriptor* secondParameter = [NSAppleEventDescriptor descriptorWithString:command];
			NSAppleEventDescriptor* thirdParameter = [NSAppleEventDescriptor descriptorWithString:[dObject primaryType]];
			
			// create and populate the list of parameters
			NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
			[parameters insertDescriptor:firstParameter atIndex:1];
			[parameters insertDescriptor:secondParameter atIndex:2];
			[parameters insertDescriptor:thirdParameter atIndex:3];
			
			
			// create the AppleEvent target
			ProcessSerialNumber psn = {0, kCurrentProcess};
			NSAppleEventDescriptor* target =
			[NSAppleEventDescriptor
			 descriptorWithDescriptorType:typeProcessSerialNumber
			 bytes:&psn
			 length:sizeof(ProcessSerialNumber)];
			
			// create an NSAppleEventDescriptor with the script's method name to call,
			// this is used for the script statement: "on show_message(user_message)"
			// Note that the routine name must be in lower case.
			NSAppleEventDescriptor* handler =
			[NSAppleEventDescriptor descriptorWithString:
			 [@"reveal_in_1pwd" lowercaseString]];
			
			// create the event for an AppleScript subroutine,
			// set the method name and the list of parameters
			NSAppleEventDescriptor* event =
			[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
													 eventID:kASSubroutineEvent
											targetDescriptor:target
													returnID:kAutoGenerateReturnID
											   transactionID:kAnyTransactionID];
			[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
			[event setParamDescriptor:parameters forKeyword:keyDirectObject];
			
			// call the event in AppleScript
			if (![appleScript executeAppleEvent:event error:&scptErrors])
			{
				NSLog(@"%@",scptErrors);
				// report any errors from 'errors'
			}
			
			[appleScript release];
		}
		else
		{
			NSLog(@"%@",scptErrors);
			// report any errors from 'errors'
		}
	}
	
	return nil;
}

-(void)writePlistAndFill:(QSObject *)dObject withBrowsers:(QSObject *)iObject {		
	// Create the path to the fill folder for the 1Pwd extension
	NSString *path = [@"~/Library/Application Support/1Password/Fill" stringByExpandingTildeInPath];
	NSFileManager *fm = [[NSFileManager alloc] init];
	if (![fm fileExistsAtPath:path]) {
		NSError *err;
		[fm createDirectoryAtPath:[path stringByAppendingPathComponent:@"Fill"] withIntermediateDirectories:YES attributes:nil error:&err];
		if (err) {
			NSLog(@"Error: %@",err);
		}
	}
	[fm release];
	
	path = [path stringByAppendingPathComponent:[dObject objectForMeta:@"locationKey"]];
	path = [path stringByAppendingPathExtension:@"plist"];		
		
	// Put the reqired data into a dict (for plist creation)
	NSDictionary *plistDict = [NSDictionary dictionaryWithObjectsAndKeys:[dObject identifier], @"form", 
							   [dObject details], @"location", 
							   [NSDate date], @"timestamp", nil];
	
	// Write the plist to the Fill folder
	if (![plistDict writeToFile:path atomically:YES]) {
		NSBeep();
		NSLog(@"Error writing .plist file (Permission error?)");
	}
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];

	// Open the URL in the default browser
	if(!iObject) {
		[ws openURL:[NSURL URLWithString:[dObject details]]];
	}
	
	else {
		for(QSObject *individual in [iObject splitObjects]){
			if([individual isApplication]) {		
				NSURL *url = [NSURL URLWithString:[dObject details]];
				NSString *ident = [[NSBundle bundleWithPath:[individual singleFilePath]] bundleIdentifier];
				[ws openURLs:[NSArray arrayWithObject:url] withAppBundleIdentifier:ident
					 options:0
additionalEventParamDescriptor:nil
		   launchIdentifiers:nil];
				
		}
	}
	}
	
}



//-(QSObject *)trashForm:(QSObject *)dObject
//{
//	NSString *keychainPath= (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
//	keychainPath = [keychainPath stringByAppendingPathComponent:@"data/default"];
//
//	//If there's multiple forms to fill
//	if ([[dObject stringValue] isEqualToString:@"combined objects"])
//	{		
//		// for each object - do exactly the same thing as for single objects
//		for (QSObject *goAndFillObject in [dObject objectForCache:kQSObjectComponents])
//		{
//			
//		}	
//		// If we only have one form to fill / one object
//	} 
//	else {
//		// single object -- same as for multiple objects
//	}
//	
//	return nil;
//}
//
//}
@end
