
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

// See https://support.1password.com/integration-mac/

#import "OnePasswordSource.h"
#import "OnePasswordDefines.h"
#import <YAJL/YAJL.h>

@implementation OnePasswordSource

- (void)dealloc
{
	self.bundleID = nil;
}

static id _sharedInstance;

+ (id)sharedInstance {
	if (!_sharedInstance) _sharedInstance = [[[self class] alloc] init];
	return _sharedInstance;
}

-(id)init {
	if (self = [super init]) {
		self.bundleID = kVersion7BundleID;
		// QSDefaults probably won't be read until after this, so maybe pointless
		NSString *location = [k1Password3rdPartyItemsPath stringByStandardizingPath];
		NSFileManager *fm = [[NSFileManager alloc] init];
		// valid location exists
		BOOL valid = location && [fm fileExistsAtPath:location];
		if (!valid) {
			NSImage *icon = [QSResourceManager imageNamed:kQS1PasswordIcon];
			QSShowNotifierWithAttributes(@{
				QSNotifierType: @"OnePasswordNotifType",
				QSNotifierIcon: icon ? icon : [QSResourceManager imageNamed:@"com.blacktree.Quicksilver"],
				QSNotifierTitle : @"Unable to locate 1Password items",
				QSNotifierText : @"Please enable 3rd Party integration in 1Password to use the 1Password Plugin"
			});
		}
	}
	return self;
}

- (NSString *)keychainPath {
	return [k1Password3rdPartyItemsPath stringByStandardizingPath];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	
	// Check to see if keychain has been modified since last scan
	
	NSError *error = nil;
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSDate *modDate=[[fm attributesOfItemAtPath:[self keychainPath] error:&error] fileModificationDate];
	
	if (error) {
		NSLog(@"Error: %@", error);
		return NO;
	}
	
	// return the difference between the keychain mod date and the last index time
	return ([modDate compare:indexDate]==NSOrderedAscending);
}

- (NSString *)detailsOfObject:(QSObject *)object
{
	return [object objectForMeta:kOnePasswordItemDetails];
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
	// For the children to 1Pwd, just load items from the catalog
	NSMutableArray *children = [[QSLib scoredArrayForType:QS1PasswordForm] mutableCopy];
	[object setChildren:children];
	return YES;
}

- (NSArray *)objectsForEntry:(QSCatalogEntry *)theEntry
{
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects = [NSMutableArray array];
	QSObject *newObject;
	NSString *location = [self keychainPath];
	NSSet *searchLocations = [NSSet setWithObject:location];
	NSMetadataQuery *passwordSearch = [[NSMetadataQuery alloc] init];
	NSArray *OPItems = [passwordSearch resultsForSearchString:@"kMDItemContentType == 'com.agilebits.itemmetadata'" inFolders:searchLocations];
	for (NSMetadataItem *item in OPItems) {
		NSDictionary *metadata = [item valuesForAttributes:@[(NSString *)kMDItemPath]];
		NSString *itemPath = metadata[(NSString *)kMDItemPath];
		NSData *JSONData = [NSData dataWithContentsOfFile:itemPath];
		NSDictionary *OPItem = [JSONData yajl_JSON];
		NSString *uuid = OPItem[@"uuid"];
		NSString *categoty = OPItem[@"categoryUUID"];
		NSString *title = OPItem[@"itemTitle"];
		NSArray *urls = OPItem[@"websiteURLs"];
		NSString *details = OPItem[@"itemDescription"];
		newObject = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"1PasswordItem:%@", uuid]];
		[newObject setName:title];
		[newObject setObject:itemPath forType:QSFilePathType];
		[newObject setObject:categoty forMeta:kOnePasswordItemCategory];
		[newObject setObject:details forMeta:kOnePasswordItemDetails];
		if (urls) {
			NSString *firstURL = urls[0];
			[newObject setObject:firstURL forType:QSURLType];
			[newObject setObject:uuid forType:QS1PasswordForm];
		}
		[newObject setPrimaryType:QS1PasswordForm];
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
