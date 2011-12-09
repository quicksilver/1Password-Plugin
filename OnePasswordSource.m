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

@implementation OnePasswordSource

@synthesize bundleID, keychainPath, onePasswordImage;

-(void)dealloc {
    [bundleID release];
    [keychainPath release];
    [onePasswordImage release];
    [super dealloc];
}

-(id)sharedInstance {
    
}

-(id)init {
    if (self = [super init]) {
        OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator,CFSTR("com.agilebits.onepassword-osx"),NULL,nil,nil);
        if (result == noErr) {
            [self setBundleID:@"com.agilebits.onepassword-osx"]; 
        }
        else {
            [self setBundleID:@"ws.agile.1Password"];
        }
//        NSLog(@"1Password Bundle ID: %@",[self bundleID]);

        NSString *tempKeychainPath = nil;

        NSString *CFkeychainPath = (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
        
        NSFileManager *fm = [[NSFileManager alloc] init];

        if (CFkeychainPath) {
//            NSLog(@"Found keychain location from ws.agile.1Password plist for key AgileKeychainLocation");
            tempKeychainPath = [CFkeychainPath mutableCopy];
        }
        
        [CFkeychainPath release];
        
        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
//                   NSLog(@"DropBoxEnabled BOOL is set in ws.agile.1Password.plist, assuming keychain is in the dropbox folder");
                    tempKeychainPath = [[NSString alloc] initWithString:kDropboxLocation];
        }
        
        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
//            NSLog(@"Assuming 1Password keychain is in  ~/Library/Containers folder");
            tempKeychainPath = [[NSString alloc] initWithString:kNewMASKeychainLocation];                
        }
        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
//            NSLog(@"Assuming 1Password keychain is in ~/Library/App Support folder");
            tempKeychainPath = [[NSString alloc] initWithString:kOldKeychainLocation];
        }
        
        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
            NSLog(@"Could not determine where your keychain resides.\n Tried everything for Bundle ID: %@, all I came up with was keychain: %@",
                  [self bundleID], keychainPath);
        }
       
        [self setKeychainPath:[tempKeychainPath stringByStandardizingPath]];
        [fm release];
        [tempKeychainPath release];
    }
    
    // save the 1pass image as it's used a lot
    [self setOnePasswordImage:[QSResourceManager imageNamed:[self bundleID]]];
    
    return self;
}



- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	
	// Check to see if keychain has been modified since last scan
	
	NSError *error = nil;
    NSFileManager *fm = [[NSFileManager alloc] init];
	NSDate *modDate=[[fm attributesOfItemAtPath:[self keychainPath] error:&error] fileModificationDate];
    
	[fm release];
    
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
    
	
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects=[[NSMutableArray alloc] init];
	
	// Get into the data folder of it
	NSString *dataFolder = [[self keychainPath] stringByAppendingPathComponent:@"data/default/"];
	
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if (![self keychainPath] || ![fm fileExistsAtPath:[self keychainPath]]) {
        NSLog(@"Unable to determine 1Password keychain path. Assumed it was in %@, but file not found.",[self keychainPath]);
        return nil;
    }
    
	// get all the files in the directory
	NSError *dataError = nil;
	NSArray *dataFiles = [fm contentsOfDirectoryAtPath:dataFolder error:&dataError];
	
	[fm release];
	
	if(dataError) {
		NSLog(@"Error: %@",dataError);
		return nil;
	}
	   
	// Set this up to get only the files ending in .1pwd
	NSPredicate *contains1Pwd = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '1Password'"];

	// Set the 1Pwd bundle to access the images
	NSBundle *OnePasswordBundle = [NSBundle bundleWithIdentifier:bundleID];
	
	
	// For each .1pwd file in the filtered files
	for (NSString *dataPath in [dataFiles filteredArrayUsingPredicate:contains1Pwd])
	{		
		
		NSData *JSONData = [NSData dataWithContentsOfFile:[dataFolder stringByAppendingPathComponent:dataPath]];
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
		
        // Ignore password types
		if ([objectType isEqualToString:@"passwords.Password"]) {
			continue;
		}
        		
		NSString *title = [JSONDict objectForKey:@"title"];
		NSString *uuidString = [JSONDict objectForKey:@"uuid"];

		QSObject *newObject;
		newObject=[QSObject makeObjectWithIdentifier:uuidString];
		[newObject setLabel:title];
		[newObject setName:title];

        // if it's a webform
		if([objectType isEqualToString:@"webforms.WebForm"])
		{					
			if ([type isEqualToString:@"WebForm"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
			
				NSString *location = [JSONDict objectForKey:@"location"];				
				[newObject setObject:uuidString forType:QS1PasswordForm];
				[newObject setDetails:location];
				[newObject setIcon:onePasswordImage];
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
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"wallet-icon-128" ofType:@"png"]] autorelease]];
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
		[object setIcon:onePasswordImage];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordSecureNote"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:bundleID] pathForResource:@"secure-notes-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordOnlineService"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:bundleID] pathForResource:@"logins-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:@"QS1PasswordWalletItem"])
	{
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:bundleID] pathForResource:@"wallet-icon-128" ofType:@"png"]]autorelease]];
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
//[object setIcon:[QSResourceManager imageNamed:bundleID]];
// return YES;
// }

@end
