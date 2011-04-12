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
#import <QSCore/QSObject.h>
#import "JSON.h"
#define kItemType @"type"

@implementation OnePasswordSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	
	// Check to see if keychain has been modified since last scan
	NSString *keychainPath= (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
	NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[keychainPath stringByStandardizingPath] traverseLink:YES]fileModificationDate];
	
	// return the difference between the keychain mod date and the last index time
	return ([modDate compare:indexDate]==NSOrderedAscending);
}


- (BOOL)loadChildrenForObject:(QSObject *)object {
	// For the children to 1Pwd, just load what's in objectsForEntry
	NSArray *items = [self objectsForEntry:[NSDictionary dictionaryWithObject:@"TRUE" forKey:@"LoadingChildren"]];
	[object setChildren:items];
	return YES;
}

// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry{
	
	// Define Filemanager
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
	// Find the path to the agile keychain file **has to be agilekeychain format
	NSString *keychainPath= (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
		
	// Check if keychain path is declared in the .plist (AgileKeychainLocation is set)
	if (keychainPath == nil)
	{
		// If not, set it to the default location
		keychainPath = [NSString stringWithString:@"~/Library/Application Support/1Password/1Password.agilekeychain"];
	}
	
	// Expand the tilde !important!
	keychainPath = [keychainPath stringByExpandingTildeInPath];

	// Make sure there's actually a file where we're looking, otherwise return 0 (below)
	if ([fm fileExistsAtPath:keychainPath]) {
		
		// Get into the data folder of it
		keychainPath = [keychainPath stringByAppendingPathComponent:@"data/default/"];
		
		// Catch any errors
		NSError *dataError = nil;
		
		// get all the files in the directory
		NSArray *dataFiles = [fm contentsOfDirectoryAtPath:keychainPath error:&dataError];
		
		if(!dataFiles)
			NSLog(@"Error: %@",dataError);
		
		// Set this up to get only the files ending in .1pwd
		NSPredicate *contains1Pwd = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '1Password'"];
		
		// Put these files in a new array
		NSArray *filteredFiles = [dataFiles filteredArrayUsingPredicate:contains1Pwd];
		
		//DLog(@"filtered files: %@", [filteredFiles objectAtIndex:0]);
		
		// For each .1pwd file in the filtered files
		for (NSString *dataPath in filteredFiles)
		{
			NSError *stringError = nil;
			
			// Stuff the file contents into a string
			NSString *stringFromFileAtPath = [[NSString alloc]
											  initWithContentsOfFile:[keychainPath stringByAppendingPathComponent:dataPath]
											  encoding:NSUTF8StringEncoding
											  error:&stringError];
			
			// if there's something wrong with the string
			if(!stringFromFileAtPath)
				NSLog(@"%@", stringError);
			
			// store the JSON file in a dictionary
			NSDictionary *JSONDict = [stringFromFileAtPath JSONValue];
			
			// If there's something wrong with the JSON Dictionary
			if(!JSONDict)
				NSLog(@"Error getting JSONDict");
		
			// Now we're gonna need to distinguish between the different types of things - web forms, passwords, identities, 
			
			// First of all make sure it hasn't been trashed. We don't want to index trashed items (that is, trashed within 1Pwd)
			if(![JSONDict objectForKey:@"trashed"])
			{
				// Set the 1Pwd bundle to access the images
				NSBundle *OnePasswordBundle = [NSBundle bundleWithIdentifier:@"ws.agile.1Password"];
				
				NSString *type = [theEntry objectForKey:kItemType];
				//DLog(@"Type is: %@", type);
				
				// Start the sorting
				// if it's an identity
				if ([[JSONDict objectForKey:@"typeName"] isEqualToString:@"identities.Identity"])
				{
					if ([type isEqualToString:@"Identity"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						
						//NSLog(@"File: %@ is an identity", dataPath);
						QSObject *newObject;
						NSString *newObjectName = [JSONDict objectForKey:@"title"];
						newObject=[QSObject objectWithString:newObjectName];
						[newObject setObject:newObjectName forType:QS1PasswordIdentity];
						[newObject setPrimaryType:QS1PasswordIdentity];
						[newObject setLabel:newObjectName];
						//DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"identities" ofType:@"png"]);
						[newObject setIcon:[QSResourceManager imageNamed:@"UserIcon"]];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						
						[objects addObject:newObject];
						//DLog(@"File: %@ is a secure note", dataPath);
					}
					
				}
				
				// else if it's a wallet or sofware license (wallet items are wallet.financial, sofwtare licenses are wallet.computer)
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.financial"])
				{
					if ([type isEqualToString:@"WalletItem"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						//NSLog(@"File: %@ is a wallet", dataPath);
						QSObject *newObject;
						NSString *newObjectName = [JSONDict objectForKey:@"title"];
						newObject=[QSObject objectWithString:newObjectName];
						[newObject setObject:newObjectName forType:QS1PasswordWalletItem];
						[newObject setPrimaryType:QS1PasswordWalletItem];
						[newObject setLabel:newObjectName];
						//DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"wallet-icon-128" ofType:@"png"]);
						[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"wallet-icon-128" ofType:@"png"]]autorelease]];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						
						[objects addObject:newObject];
						//DLog(@"File: %@ is a secure note", dataPath);
					}
				}
				
				// else if it's a software license
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.computer"])
				{
					if ([type isEqualToString:@"SoftwareLicense"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						//NSLog(@"File: %@ is a software license", dataPath);
						QSObject *newObject;
						NSString *newObjectName = [JSONDict objectForKey:@"title"];
						newObject=[QSObject objectWithString:newObjectName];
						[newObject setObject:newObjectName forType:QS1PasswordSoftwareLicense];
						[newObject setPrimaryType:QS1PasswordSoftwareLicense];
						[newObject setLabel:newObjectName];
						//DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"software" ofType:@"png"]);
						[newObject setIcon:[QSResourceManager imageNamed:@"ToolbarAppsFolderIcon"]];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						
						[objects addObject:newObject];
						//DLog(@"File: %@ is a wallet item", dataPath);
					}
				}
				
				// else if it's an online service
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.onlineservices"])
				{
					if ([type isEqualToString:@"OnlineService"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						//NSLog(@"File: %@ is an onlineservice", dataPath);
						QSObject *newObject;
						NSString *newObjectName = [JSONDict objectForKey:@"title"];
						newObject=[QSObject objectWithString:newObjectName];
						[newObject setObject:newObjectName forType:QS1PasswordOnlineService];
						[newObject setPrimaryType:QS1PasswordOnlineService];
						[newObject setLabel:newObjectName];
						//DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"logins-icon-128" ofType:@"png"]);
						[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"logins-icon-128" ofType:@"png"]]autorelease]];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						
						[objects addObject:newObject];
						//DLog(@"File: %@ is an online service", dataPath);
					}
				}
				
				// else if it's a secure note
				else if ([[JSONDict objectForKey:@"typeName"] isEqualToString:@"securenotes.SecureNote"])
				{
					if ([type isEqualToString:@"SecureNote"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						
						QSObject *newObject;
						NSString *newObjectName = [JSONDict objectForKey:@"title"];
						newObject=[QSObject objectWithString:newObjectName];
						[newObject setObject:newObjectName forType:QS1PasswordSecureNote];
						[newObject setPrimaryType:QS1PasswordSecureNote];
						[newObject setLabel:newObjectName];
						//DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"secure-notes-icon-128" ofType:@"png"]);
						[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"secure-notes-icon-128" ofType:@"png"]]autorelease]];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						
						[objects addObject:newObject];
						
						//DLog(@"File: %@ is a secure note", dataPath);
					}
				}
				
				// if it's a webform
				else if([[JSONDict objectForKey:@"typeName"] isEqualToString:@"webforms.WebForm"])
				{					
					if ([type isEqualToString:@"WebForm"] || [[theEntry objectForKey:@"LoadingChildren"] isEqualToString:@"TRUE"]) {
						// Add the stuff into a new array
						QSObject *newObject;
						
						newObject=[QSObject objectWithString:[JSONDict objectForKey:@"location"]];
						[newObject setObject:[JSONDict objectForKey:@"location"] forType:QS1PasswordForm];
						[newObject setPrimaryType:QS1PasswordForm];
						[newObject setLabel:[JSONDict objectForKey:@"title"]];
						[newObject setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
						[newObject setObject:[JSONDict objectForKey:@"locationKey"] forMeta:@"locationKey"];
						[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
						[objects addObject:newObject];
					}
				}
				
			}
		}
		
		//NSLog(@"files are: %@", dataFiles);
		//NSLog(@"agile path: %@", keychainPath);
		return objects;
	}
	
	// If we can't find the Agile Keychain
	else
	{
		// Tell the user and exit so as not to cause crashes
		NSLog(@"Could not determine keychain location. Please report this to the developer");
		return 0;
	}
	
	
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
