//
//  OnePasswordSource.m
//  OnePassword
//
//  Created by Patrick Robertson on 15/01/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "OnePasswordSource.h"
#import <QSCore/QSObject.h>
#import "JSON.h"

@implementation OnePasswordSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	
	// Check to see if keychain has been modified since last scan
	NSString *keychainPath= (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
	NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[keychainPath stringByStandardizingPath] traverseLink:YES]fileModificationDate];
	
	// return the difference between the keychain mod date and the last index time
	return ([modDate compare:indexDate]==NSOrderedDescending);
}


- (BOOL)loadChildrenForObject:(QSObject *)object {
	// For the children to 1Pwd, just load what's in objectsForEntry
	NSArray *items = [self objectsForEntry:nil];
	[object setChildren:items];
	return YES;
}

// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry{
	
	// Define the objects (Empty to start with) we're going to send back to QS
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
	// Find the path to the agile keychain file **has to be agilekeychain format
	NSString *keychainPath= (NSString *)CFPreferencesCopyAppValue((CFStringRef)@"AgileKeychainLocation",(CFStringRef) @"ws.agile.1Password");
	
	DLog(@"Keychain path: %@", keychainPath);
	
	// make sure the keychain is in agile format
	if ([[keychainPath pathExtension] isEqualToString:@"agilekeychain"]) 
	{
		
		// Get into the data folder of it
		keychainPath = [keychainPath stringByAppendingPathComponent:@"data/default/"];
		
		// Expand the tilde
		keychainPath = [keychainPath stringByExpandingTildeInPath];
		
		DLog(@"Keychain data path: %@", keychainPath);
		
		// Define Filemanager
		NSFileManager *fm = [NSFileManager defaultManager];
		
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
		
		DLog(@"filtered files: %@", [filteredFiles objectAtIndex:0]);
		
		// For each .1pwd file in the filtered files
		for (NSString *dataPath in filteredFiles)
		{
			NSError *stringError = nil;
						
			// Stuff the file contents into a string
			NSString *stringFromFileAtPath = [[NSString alloc]
											  initWithContentsOfFile:[keychainPath stringByAppendingPathComponent:dataPath]
											  encoding:NSUTF8StringEncoding
											  error:&stringError];
			if(!stringFromFileAtPath)
				NSLog(@"%@", stringError);
			
			// store the JSON file in a dictionary
			NSDictionary *JSONDict = [stringFromFileAtPath JSONValue];
			
			if(!JSONDict)
				NSLog(@"Error getting JSONDict");
			
			// Now we're gonna need to distinguish between the different types of things - web forms, passwords, identities, 
			
			// First of all make sure it hasn't been trashed. We don't want to index trashed items (that is, trashed within 1Pwd)
			if(![JSONDict objectForKey:@"trashed"])
			{
				
				// Start the sorting
				// if it's an identity
				if ([[JSONDict objectForKey:@"typeName"] isEqualToString:@"identities.Identity"])
				{
					//NSLog(@"File: %@ is an identity", dataPath);
					QSObject *newObject;
					NSString *newObjectName = [JSONDict objectForKey:@"title"];
					newObject=[QSObject objectWithString:newObjectName];
					[newObject setObject:newObjectName forType:QS1PasswordWalletItem];
					[newObject setLabel:newObjectName];
					DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"identities" ofType:@"png"]);
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"identities" ofType:@"png"]]autorelease]];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					
					[objects addObject:newObject];
					NSLog(@"File: %@ is a secure note", dataPath);
					
					
				}
				
				// else if it's a wallet or sofware license (wallet items are wallet.financial, sofwtare licenses are wallet.computer)
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.financial"])
				{
					//NSLog(@"File: %@ is a wallet", dataPath);
					QSObject *newObject;
					NSString *newObjectName = [JSONDict objectForKey:@"title"];
					newObject=[QSObject objectWithString:newObjectName];
					[newObject setObject:newObjectName forType:QS1PasswordWalletItem];
					[newObject setLabel:newObjectName];
					DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"wallet" ofType:@"png"]);
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"wallet" ofType:@"png"]]autorelease]];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					
					[objects addObject:newObject];
					NSLog(@"File: %@ is a secure note", dataPath);
					
				}
				
				// else if it's a software license
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.computer"])
				{
					//NSLog(@"File: %@ is a software license", dataPath);
					QSObject *newObject;
					NSString *newObjectName = [JSONDict objectForKey:@"title"];
					newObject=[QSObject objectWithString:newObjectName];
					[newObject setObject:newObjectName forType:QS1PasswordSoftwareLicense];
					[newObject setLabel:newObjectName];
					DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"software" ofType:@"png"]);
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"software" ofType:@"png"]]autorelease]];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					
					[objects addObject:newObject];
					NSLog(@"File: %@ is a wallet item", dataPath);
					
				}
				
				// else if it's an online service
				else if ([[JSONDict objectForKey:@"typeName"] hasPrefix:@"wallet.onlineservices"])
				{
					//NSLog(@"File: %@ is an onlineservice", dataPath);
					QSObject *newObject;
					NSString *newObjectName = [JSONDict objectForKey:@"title"];
					newObject=[QSObject objectWithString:newObjectName];
					[newObject setObject:newObjectName forType:QS1PasswordOnlineService];
					[newObject setLabel:newObjectName];
					DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"accounts" ofType:@"png"]);
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"accounts" ofType:@"png"]]autorelease]];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					
					[objects addObject:newObject];
					NSLog(@"File: %@ is an online service", dataPath);
					
				}
				
				// else if it's a secure note
				else if ([[JSONDict objectForKey:@"typeName"] isEqualToString:@"securenotes.SecureNote"])
				{
					/**/
					
					QSObject *newObject;
					NSString *newObjectName = [JSONDict objectForKey:@"title"];
					 newObject=[QSObject objectWithString:newObjectName];
					[newObject setObject:newObjectName forType:QS1PasswordSecureNote];
					[newObject setLabel:newObjectName];
					DLog(@"Image is at: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"secure-note" ofType:@"png"]);
					[newObject setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"secure-note" ofType:@"png"]]autorelease]];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					 
					 [objects addObject:newObject];
					 NSLog(@"File: %@ is a secure note", dataPath);
				}
				
				// if it's a webform
				else if([[JSONDict objectForKey:@"typeName"] isEqualToString:@"webforms.WebForm"])
				{					
					// Add the stuff into a new array
					QSObject *newObject;
					
					newObject=[QSObject objectWithString:[JSONDict objectForKey:@"location"]];
					[newObject setObject:[JSONDict objectForKey:@"location"] forType:QS1PasswordForm];
					[newObject setLabel:[JSONDict objectForKey:@"title"]];
					[newObject setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
					[newObject setObject:[JSONDict objectForKey:@"locationKey"] forMeta:@"locationKey"];
					[newObject setObject:[JSONDict objectForKey:@"uuid"] forMeta:@"form"];
					[objects addObject:newObject];
					
					//[plistDict writeToFile:path atomically:YES];
				}
				
			}
		}
		//NSLog(@"files are: %@", dataFiles);
		
		
		//NSLog(@"agile path: %@", keychainPath);
		
		return objects;
		
	}
	
	else
	{
		NSLog(@"Keychain is not in Agile Keychain Format. Change this in the 1Password preferences to use this plugin.");
		NSLog(@"Nothing added to the Quicksilver Catalog");
	}
	
}


// Object Handler Methods

//- (void)setQuickIconForObject:(QSObject *)object{
	//[object setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]]; // An icon that is either already in memory or easy to load
//}
//- (BOOL)loadIconForObject:(QSObject *)object{
//[object setIcon:[QSResourceManager imageNamed:@"ws.agile.1Password"]];
// return YES;
// }

@end
