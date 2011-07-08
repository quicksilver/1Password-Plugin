//
//  OnePasswordSource.m
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

#import "OnePasswordSource.h"
#import <YAJL/YAJL.h>

#import <QSCore/QSObject.h>
#define kItemType @"type"

@implementation OnePasswordSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	
	// Check to see if keychain has been modified since last scan
	NSString *keychainPath= [(NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password") autorelease];
	if (!keychainPath) {
		keychainPath = @"~/Library/Application Support/1Password/1Password.agilekeychain";
	}
	NSError *error = nil;
	NSDate *modDate=[[[NSFileManager defaultManager] attributesOfItemAtPath:[keychainPath stringByStandardizingPath] error:&error]fileModificationDate];
	
	if (error) {
		NSLog(@"Error: %@", error);
		return NO;
	}
	
	// return the difference between the keychain mod date and the last index time
	return ([modDate compare:indexDate]==NSOrderedAscending);
}


- (BOOL)loadChildrenForObject:(QSObject *)object {
	// For the children to 1Pwd, just load what's in objectsForEntry
	if([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		NSArray *items = [self objectsForEntry:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"LoadingChildren"]];
		if (!items) {
			return NO;
		}
		[object setChildren:items];
		return YES;
	}
	return NO;
}

// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry{
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects=[[NSMutableArray alloc] init];
	
	// Find the path to the agile keychain file **has to be agilekeychain format
	NSString *keychainPath= [(NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password") autorelease];
	
	// If path not set in prefs
	if (keychainPath == nil) {
		keychainPath = @"~/Library/Application Support/1Password/1Password.agilekeychain";
	}
	
	// Expand the tilde !important!
	keychainPath = [keychainPath stringByExpandingTildeInPath];
	
	// If we can't find the Agile Keychain
	if (![fm fileExistsAtPath:keychainPath]) {
		[fm release];
		// Tell the user and exit so as not to cause crashes
		NSLog(@"Could not determine keychain location. Please report this to the developer");
		return 0;
	}
	
	// Get into the data folder of it
	keychainPath = [keychainPath stringByAppendingPathComponent:@"data/default/"];
	
	// get all the files in the directory
	NSError *dataError = nil;
	NSArray *dataFiles = [fm contentsOfDirectoryAtPath:keychainPath error:&dataError];
	
	[fm release];
	
	if(dataError) {
		NSLog(@"Error: %@",dataError);
		return nil;
	}
	
	// Set this up to get only the files ending in .1pwd
	NSPredicate *contains1Pwd = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '1Password'"];

	// Set the 1Pwd bundle to access the images
	NSBundle *OnePasswordBundle = [NSBundle bundleWithIdentifier:@"ws.agile.1Password"];
	
	
	// For each .1pwd file in the filtered files
	for (NSString *dataPath in [dataFiles filteredArrayUsingPredicate:contains1Pwd])
	{		
		
		NSData *JSONData = [NSData dataWithContentsOfFile:[keychainPath stringByAppendingPathComponent:dataPath]];
		NSDictionary *JSONDict = [JSONData yajl_JSON];
		
		// If there's something wrong with the JSON Dictionary
		if(!JSONDict) {
			NSLog(@"Error getting JSONDict");
			continue;
		}
		// Don't catalog trashed items
		if([JSONDict objectForKey:@"trashed"]) {
			continue;
		}
		
		NSString *type = [theEntry objectForKey:kItemType];
		NSString *objectType = [JSONDict objectForKey:@"typeName"];
		
		if ([objectType isEqualToString:@"passwords.Password"]) {
			continue;
		}
		// if it's a webform
		
		NSString *title = [JSONDict objectForKey:@"title"];
		NSString *uuidString = [JSONDict objectForKey:@"uuid"];

		QSObject *newObject;
		newObject=[QSObject makeObjectWithIdentifier:uuidString];
		[newObject setName:title];

		if([objectType isEqualToString:@"webforms.WebForm"])
		{					
			if ([type isEqualToString:@"WebForm"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
			
				NSString *location = [JSONDict objectForKey:@"location"];				
				[newObject setObject:uuidString forType:QS1PasswordForm];
				[newObject setLabel:location];
				[newObject setDetails:location];
				[newObject setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
				[newObject setObject:[JSONDict objectForKey:@"locationKey"] forMeta:@"locationKey"];
				[objects addObject:newObject];
			}
		}
		else {
			[newObject setDetails:title];
			
			// if it's an identity
			if ([objectType isEqualToString:@"identities.Identity"])
			{
				if ([type isEqualToString:@"Identity"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
					
					[newObject setObject:uuidString forType:QS1PasswordIdentity];
					[newObject setIcon:[QSResourceManager imageNamed:@"UserIcon"]];
					[objects addObject:newObject];
				}
			}
			
			// else if it's a wallet or sofware license (wallet items are wallet.financial, software licenses are wallet.computer)
			else if ([objectType hasPrefix:@"wallet.financial"])
			{
				if ([type isEqualToString:@"WalletItem"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
					[newObject setObject:title forType:QS1PasswordWalletItem];
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"wallet-icon-128" ofType:@"png"]]autorelease]];
					[objects addObject:newObject];
				}
			}
			
			// else if it's a software license
			else if ([objectType hasPrefix:@"wallet.computer"])
			{
				if ([type isEqualToString:@"SoftwareLicense"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
					[newObject setObject:title forType:QS1PasswordSoftwareLicense];
					[newObject setIcon:[QSResourceManager imageNamed:@"ToolbarAppsFolderIcon"]];
					[objects addObject:newObject];
				}
			}
			
			// else if it's an online service
			else if ([objectType hasPrefix:@"wallet.onlineservices"])
			{
				if ([type isEqualToString:@"OnlineService"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
					[newObject setObject:title forType:QS1PasswordOnlineService];
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"logins-icon-128" ofType:@"png"]] autorelease]];
					[objects addObject:newObject];
				}
			}
			
			// else if it's a secure note
			else if ([objectType isEqualToString:@"securenotes.SecureNote"])
			{
				if ([type isEqualToString:@"SecureNote"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
					
					[newObject setObject:title forType:QS1PasswordSecureNote];
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"secure-notes-icon-128" ofType:@"png"]]autorelease]];
					[objects addObject:newObject];
				}
			}	
		}
	}
	
	return objects;
}


// Object Handler Methods
// An icon that is either already in memory or easy to load
- (void)setQuickIconForObject:(QSObject *)object{
	if ([[object primaryType] isEqualToString:@"QS1PasswordForm"])
	{
		[object setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordSecureNote"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:@"ws.agile.1Password"] pathForResource:@"secure-notes-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordOnlineService"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:@"ws.agile.1Password"] pathForResource:@"logins-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordWalletItem"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:@"ws.agile.1Password"] pathForResource:@"wallet-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordIdentity"])
	{
		[object setIcon:[QSResourceManager imageNamed:@"UserIcon"]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordSoftwareLicense"])
	{
		[object setIcon:[QSResourceManager imageNamed:@"ToolbarAppsFolderIcon"]];
	}
}
//- (BOOL)loadIconForObject:(QSObject *)object{
//[object setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
// return YES;
// }

@end
