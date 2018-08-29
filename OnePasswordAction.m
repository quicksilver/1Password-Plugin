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
#import "OnePasswordSource.h"
#import "OnePasswordDefines.h"


@implementation OnePasswordAction

// Method to only show browsers in the 3rd pane for the 'Go & Fill With...' action
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
// only for 'Go & Fill With...' action
	if (![action isEqualToString:@"goAndFillWith"]) {
		return nil;
	}
	NSArray *validBrowsers = [NSArray arrayWithObjects:@"org.mozilla.firefox",
							  @"com.apple.Safari",@"com.google.Chrome",@"org.mozilla.camino",@"com.operasoftware.Opera",
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
	NSURL *appURL = (__bridge NSURL *)LSCopyDefaultApplicationURLForURL((__bridge CFURLRef)[NSURL URLWithString:@"http://"], kLSRolesAll, NULL);
	
	// Set the default app to be 1st in the returned list
	id preferred = [QSObject fileObjectWithPath:[appURL path]];
	if (!preferred) {
		preferred = [NSNull null];
	}
	
	[set addObjectsFromArray:validBrowserPaths];
	validIndirects = [[QSLibrarian sharedInstance] scoredArrayForString:nil inSet:[QSObject fileObjectsWithPathArray:[set allObjects]]];
	
	return [NSArray arrayWithObjects:preferred, validIndirects, nil];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
	if ([[dObject objectForMeta:kOnePasswordItemCategory] isEqualToString:kOnePasswordCategoryLogin]) {
		return @[@"goAndFill"];
	}
	return nil;
}

- (QSObject *)goAndFill:(QSObject *)dObject with:(QSObject *)iObject {
	
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    NSMutableArray *URLArray = [[NSMutableArray alloc] initWithCapacity:[dObject count]];
    for (QSObject *goAndFillObject in [dObject splitObjects]) {
        
        NSString *URLString = [NSString stringWithFormat:@"%@?onepasswdfill=%@",[goAndFillObject details],[goAndFillObject objectForType:QS1PasswordItemType]];
        [URLArray addObject:[NSURL URLWithString:[URLString URLEncoding]]];
        
    }
       
    if (!iObject) {
        [ws openURLs:URLArray withAppBundleIdentifier:nil
                                              options:0
                       additionalEventParamDescriptor:nil
                                    launchIdentifiers:nil];
    } else {
        for(QSObject *individual in [iObject splitObjects]){
            if([individual isApplication]) {	
                NSString *ident = [[NSBundle bundleWithPath:[individual singleFilePath]] bundleIdentifier];
                [ws openURLs:URLArray withAppBundleIdentifier:ident
                     options:0
additionalEventParamDescriptor:nil
           launchIdentifiers:nil];
                
            }
        }
    }
	return nil;
}
@end
