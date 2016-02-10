
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

-(void)dealloc {
	self.bundleID = nil;
	[super dealloc];
}

static id _sharedInstance;

+ (id)sharedInstance {
	if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
	return _sharedInstance;
}

-(id)init {
	if (self = [super init]) {
		
		for (NSString *bundleID in kOnePasswordBundleIDs) {
			OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator,(CFStringRef)bundleID, NULL, nil, nil);
			if (result == noErr) {
				self.bundleID = bundleID;
				break;
			}
		}
		Boolean t = false;
		Boolean isValid = false;
		NSString *prefsUsed = nil;
		for (NSString *prefsString in kOnePasswordPrefs) {
			t = CFPreferencesGetAppBooleanValue((CFStringRef)@"Enable3rdPartyIntegration", (CFStringRef) prefsString, &isValid);
			if (isValid) {
				prefsUsed = prefsString;
				break;
			}
		}
		NSImage *icon = [QSResourceManager imageNamed:kQS1PasswordIcon];
		if (isValid) {
			if (!t) {
				QSShowNotifierWithAttributes(@{QSNotifierType : @"OnePasswordNotifType", QSNotifierIcon : icon ? icon : [QSResourceManager imageNamed:@"com.blacktree.Quicksilver"], QSNotifierTitle : @"1Password 3rd Party Integration not enabled", QSNotifierText : @"Please enable 3rd Party integration in 1Password to use the 1Password Plugin"});
			} else {
				// QSDefaults probably won't be read until after this, so maybe pointless
				NSString *location = [[[NSUserDefaults standardUserDefaults] objectForKey:k1PPath] stringByStandardizingPath];
				NSFileManager *fm = [[NSFileManager alloc] init];
				// valid locations exist and are of type 'json' (since we read this in as JSON)
				BOOL valid = location && [fm fileExistsAtPath:location] && [[location pathExtension] isEqualToString:@"json"];
				if (!valid) {
					if ([prefsUsed isEqualToString:kNonMASBundleID]) {
						location = kNonMAS1Password3rdPartyFile;
					} else {
						location = kMAS1Password3rdPartyFile;
					}
					location = [location stringByStandardizingPath];
					if ([fm fileExistsAtPath:location]) {
						valid = YES;
						[[NSUserDefaults standardUserDefaults] setObject:location forKey:k1PPath];
					}
				}
				if (!valid) {
					NSImage *icon = [QSResourceManager imageNamed:kQS1PasswordIcon];
					QSShowNotifierWithAttributes(@{QSNotifierType : @"OnePasswordNotifType", QSNotifierIcon : icon ? icon : [QSResourceManager imageNamed:@"com.blacktree.Quicksilver"], QSNotifierTitle : @"Unable to locate 1Password logins", QSNotifierText : @"Please set the 1Password 3rd party integration file's location in Quicksilver's Preferences"});
				}
				[fm release];
			}
		}
	}
	return self;
}

- (NSString *)keychainPath {
	NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:k1PPath];
	return path ? path : @"";
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

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry{
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects = [NSMutableArray array];
	QSObject *newObject;
	NSString *location = [[[NSUserDefaults standardUserDefaults] objectForKey:k1PPath] stringByStandardizingPath];
	NSData *JSONData = [NSData dataWithContentsOfFile:location];
	// TODO - check to make sure this is valid JSON data before running yajl_JSON OR switch to NSJSONSerialization
	NSArray *OPItems = [JSONData yajl_JSON];
	for (NSArray *metadata in OPItems) {
		NSString *uuid = metadata[0];
		NSString *title = metadata[1];
		NSString *location = metadata[2];
		newObject = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"%@-%@", location, uuid]];
		[newObject setName:location];
		[newObject setObject:uuid forType:QS1PasswordForm];
		[newObject setObject:location forType:QSURLType];
		[newObject setPrimaryType:QS1PasswordForm];
		[newObject setDetails:location];
		[newObject setLabel:title];
		[newObject setIcon:[QSResourceManager imageNamed:self.bundleID]];
		[objects addObject:newObject];
	}
	return objects;
}

// Object Handler Methods
// An icon that is either already in memory or easy to load
- (void)setQuickIconForObject:(QSObject *)object{
	if ([[object primaryType] isEqualToString:QS1PasswordForm])
	{
		[object setIcon:[QSResourceManager imageNamed:self.bundleID]];
	}
}
@end
