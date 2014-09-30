
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
#import "OnepasswordDefines.h"
#import <YAJL/YAJL.h>

@implementation OnePasswordSource

@synthesize bundleID, keychainPath;

-(void)dealloc {
    [bundleID release];
    [keychainPath release];
    [super dealloc];
}

static id _sharedInstance;

+ (id)sharedInstance {
	if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
	return _sharedInstance;
}

-(id)init {
    if (self = [super init]) {
        OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator,CFSTR("com.agilebits.onepassword-osx"),NULL,nil,nil);
        if (result == noErr) {
            [self setBundleID:kOnePasswordMASBundleID]; 
        }
        else {
            [self setBundleID:kOnePasswordOldBundleID];
        }
//        NSLog(@"1Password Bundle ID: %@",[self bundleID]);

        NSString *tempKeychainPath = [(NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password") autorelease];
        
        NSFileManager *fm = [[NSFileManager alloc] init];

        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
            for (NSString *testKeychainPath in kKeychainPathArray) {
                if ([fm fileExistsAtPath:[testKeychainPath stringByStandardizingPath]]) {
                    tempKeychainPath = testKeychainPath;
                    break;
                }
            }   
            
        }
            
        if (!tempKeychainPath || (tempKeychainPath && ![fm fileExistsAtPath:[tempKeychainPath stringByStandardizingPath]])) {
            NSLog(@"Could not determine where your keychain resides.\n Tried everything for Bundle ID: %@, all I came up with was keychain: %@",
                  [self bundleID], keychainPath);
        }
       
        [self setKeychainPath:[tempKeychainPath stringByStandardizingPath]];
        [fm release];
    }
        
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
	if([[object primaryType] isEqualToString:QSFilePathType]) {
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
    
    // Define the objects (Empty to start with) we're going to send back to QS
    NSMutableArray *objects=[[NSMutableArray alloc] init];
    
    // Set this up to get only the files with format UUID.1password (to ignore dropbox conflicts)
    NSPredicate *contains1Pwd = [NSPredicate predicateWithFormat:@"SELF MATCHES '[0-9A-F]+.1password'"];
    
    // Set the 1Pwd bundle to access the images
    NSBundle *OnePasswordBundle = [NSBundle bundleWithIdentifier:bundleID];
    
    NSArray *filteredFiles = [dataFiles filteredArrayUsingPredicate:contains1Pwd];
    
    @autoreleasepool {
        // For each .1pwd file in the filtered files
        for (NSString *dataPath in filteredFiles) {
            NSData *JSONData = [NSData dataWithContentsOfFile:[dataFolder stringByAppendingPathComponent:dataPath]];
            NSDictionary *JSONDict = nil;
            @try {
                JSONDict = [JSONData yajl_JSON];
            }
            @catch (NSException *exception) {
                NSLog(@"Error parsing 1Password data for %@.\nException: %@",dataPath,exception);
                continue;
            }
            
            // If there's something wrong with the JSON Dictionary
            if(JSONDict == nil) {
                NSLog(@"Error getting JSONDict for %@",dataPath);
                continue;
            }
            // Don't catalog trashed items
            if([JSONDict objectForKey:@"trashed"] != nil && [[JSONDict objectForKey:@"trashed"] boolValue]) {
                continue;
            }
            
            // Get the type of search we're performing: right arrow or a preset type as defined in the catalog prefs
            NSString *type = [theEntry objectForKey:kItemType];
            
            // get the 1Password type from the JSONDict (webform, wallet item etc.)
            NSString *objectType = [JSONDict objectForKey:@"typeName"];
            
            // Ignore password types
            if ([objectType isEqualToString:@"passwords.Password"]) {
                continue;
            }
            NSString *title = [JSONDict objectForKey:@"title"];
            NSString *uuidString = [JSONDict objectForKey:@"uuid"];
            
            QSObject *newObject =nil;
            
            // if it's a webform
            if([objectType isEqualToString:@"webforms.WebForm"])
            {					
                if ([type isEqualToString:@"WebForm"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
                    NSString *location = [JSONDict objectForKey:@"location"];				
                    newObject = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"%@-%@",location,uuidString]];
                    [newObject setName:location];
                    [newObject setObject:uuidString forType:QS1PasswordForm];
                    [newObject setDetails:location];
                    [newObject setLabel:title];
                    [newObject setIcon:[QSResourceManager imageNamed:bundleID]];
                    [newObject setObject:[JSONDict objectForKey:@"locationKey"] forMeta:@"locationKey"];
                    [objects addObject:newObject];
                }
            }
            else {
                newObject=[QSObject makeObjectWithIdentifier:uuidString];
                [newObject setName:title];
                [newObject setLabel:title];
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
                        [newObject setObject:uuidString forType:QS1PasswordWalletItem];
                        [newObject setIcon:[[[NSImage alloc] initByReferencingFile:[OnePasswordBundle pathForResource:@"wallet-icon-128" ofType:@"png"]] autorelease]];
                        [objects addObject:newObject];
                    }
                }
                
                // else if it's a software license
                else if ([objectType hasPrefix:@"wallet.computer"])
                {
                    if ([type isEqualToString:@"SoftwareLicense"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
                        [newObject setObject:uuidString forType:QS1PasswordSoftwareLicense];
                        [newObject setIcon:[QSResourceManager imageNamed:@"ToolbarAppsFolderIcon"]];
                        [objects addObject:newObject];
                    }
                }
                
                // else if it's an online service
                else if ([objectType hasPrefix:@"wallet.onlineservices"])
                {
                    if ([type isEqualToString:@"OnlineService"] || [[theEntry objectForKey:@"LoadingChildren"] boolValue]) {
                        [newObject setObject:uuidString forType:QS1PasswordOnlineService];
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
    }
	return [objects autorelease];
}

// Object Handler Methods
// An icon that is either already in memory or easy to load
- (void)setQuickIconForObject:(QSObject *)object{
	if ([[object primaryType] isEqualToString:QS1PasswordForm])
	{
		[object setIcon:[QSResourceManager imageNamed:bundleID]];
	}
	else if([[object primaryType] isEqualToString:QS1PasswordSecureNote])
	{
		[object setIcon:[QSResourceManager imageNamed:@"secure-notes-icon-128.png" inBundle:[NSBundle bundleWithIdentifier:bundleID]]];
//        [[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:bundleID] pathForResource:@"secure-notes-icon-128" ofType:@"png"]]autorelease]];
	}
	else if([[object primaryType] isEqualToString:QS1PasswordOnlineService])
	{
		[object setIcon:[QSResourceManager imageNamed:@"logins-icon-128.png" inBundle:[NSBundle bundleWithIdentifier:bundleID]]];
	}
	else if([[object primaryType] isEqualToString:QS1PasswordWalletItem])
	{
		[object setIcon:[QSResourceManager imageNamed:@"wallet-icon-128.png" inBundle:[NSBundle bundleWithIdentifier:bundleID]]];
	}
	else if([[object primaryType] isEqualToString:QS1PasswordIdentity])
	{
		[object setIcon:[QSResourceManager imageNamed:@"UserIcon"]];
	}
	else if([[object primaryType] isEqualToString:QS1PasswordSoftwareLicense])
	{
		[object setIcon:[QSResourceManager imageNamed:@"ToolbarAppsFolderIcon"]];
	}
}
//- (BOOL)loadIconForObject:(QSObject *)object{
//[object setIcon:[QSResourceManager imageNamed:bundleID]];
// return YES;
// }

@end
