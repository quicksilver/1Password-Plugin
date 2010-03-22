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
		NSLog(@"cannot operate on multiple web forms :(");
		return nil;
			}
	else {
		NSLog(@"%@", [dObject objectForMeta:@"form"]);
		CFPreferencesSetAppValue((CFStringRef)@"findUUID", [dObject objectForMeta:@"form"], CFSTR("ws.agile.1Password"));
		CFPreferencesAppSynchronize(CFSTR("ws.agile.1Password"));
	}
	
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"ws.agile.1Password" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifier:nil];
	
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
