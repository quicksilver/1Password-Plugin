//
//  OnePasswordAction.m
//  OnePassword
//
//  Created by Patrick Robertson on 15/01/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "OnePasswordAction.h"


@implementation OnePasswordAction

- (QSObject *)goAndFill:(QSObject *)dObject{
	
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	//If there's multiple forms to fill
	if ([[dObject stringValue] isEqualToString:@"combined objects"])
	{		
		// for each object - do exactly the same thing as for single objects
		for (QSObject *goAndFillObject in [dObject objectForCache:kQSObjectComponents])
		{
			[self writePlistAndFill:goAndFillObject];
		}	
		// If we only have one form to fill / one object
	} 
	else {
		// single object -- same as for multiple objects
		[self writePlistAndFill:dObject];
	}
	
	return nil;
}

- (QSObject *)viewInOnePwd:(QSObject *)dObject {
	
	//If there's multiple forms to fill
	if ([[dObject stringValue] isEqualToString:@"combined objects"])
	{
		NSLog(@"Cannot operate on multiple web forms :(");
		// A nice noise to let the user know something is wrong
		NSBeep();
		return nil;
			}
	else {
	
		//NSLog(@"%@", [dObject label]);
		//NSLog(@"%@", [dObject objectForMeta:@"locationKey"]);
		NSString *command = @"defaults write ws.agile.1Password findUUID ";
		command = [command stringByAppendingString:[dObject objectForMeta:@"form"]];
		//NSLog(@"%@", command);
		
		// Set the args for the applescript - name for applescript 'keystroke' if 1Pwd is open and command for setting prefs if not
		NSArray *arguments=[NSArray arrayWithObjects:[dObject label],command,nil];
		
		// Make dict to store errors
		NSDictionary *dictErr=nil;
		// Run the applesctipt
		[[self script] executeSubroutine:@"reveal_in_1Pwd" arguments:arguments error:&dictErr];
		// Log any errors
		if (dictErr) NSLog(@"Create Error: %@",dictErr);	}

		return nil;
}

-(void)writePlistAndFill:(QSObject *)dObject
{		
	
	NSWorkspace * ws = [NSWorkspace sharedWorkspace];
	
	// get the data
	//NSDictionary *dataDict = [dObject dataDictionary];
	
	// Create the path to the fill folder for the 1Pwd extension
	NSString *path = [@"~/Library/Application Support/1Password/Fill" stringByExpandingTildeInPath];
	path = [path stringByAppendingPathComponent:[dObject objectForMeta:@"locationKey"]];
	path = [path stringByAppendingPathExtension:@"plist"];		
	
	//NSLog(@"dataDict: %@",dataDict );
	
	//			Put the reqired data into a dict (for plist creation)
	NSDictionary *plistDict = [NSDictionary dictionaryWithObjectsAndKeys:[dObject objectForMeta:@"form"], @"form", 
							   [dObject name], @"location", 
							   [NSDate date], @"timestamp", nil];
	
	// Write the plist to the Fill folder
	[plistDict writeToFile:path atomically:YES];
	
	// Open the URL
	[ws openURL:[NSURL URLWithString:[dObject name]]];
	
}

// Thanks to Alcor - from the iCal plugin
- (NSAppleScript *)script{
	NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"RevealIn1Pwd" ofType:@"scpt"];
	NSLog(@"path: %@", path);
	NSAppleScript *script=nil;
	if (path)
		script=[[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];	
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
