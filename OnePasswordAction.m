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
#import <CommonCrypto/CommonDigest.h>

NSString *sha256HashFor(NSString* input) {
	const char* original = [input UTF8String];
	unsigned char result[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(original, (unsigned int)strlen(original), result);
	NSMutableString *sha256hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		[sha256hash appendFormat:@"%02x", result[i]];
	}
	return sha256hash;
}

NSURL *openAndFillURL(NSString *targetURL, QSObject *onePasswordItem) {
	// onepassword7://open_and_fill/profileUUID/UUID/sha256_of_url
	NSString *onePasswordURLFormat = @"onepassword7://open_and_fill/%@/%@/%@";
	NSString *vault = [onePasswordItem objectForMeta:kOnePasswordVaultIdentifier];
	NSString *uuid = [onePasswordItem objectForType:QS1PasswordItemType];
	NSString *stringURL = [NSString stringWithFormat:onePasswordURLFormat, vault, uuid, sha256HashFor(targetURL)];
	return [[NSURL alloc] initWithString:stringURL];
}

@implementation OnePasswordAction

- (QSObject *)openAndFill:(QSObject *)dObject
{
	// see https://support.1password.com/integration-mac/#open-a-url
	QSObject *onePasswordItem = [dObject parent];
	NSString *targetURL = [dObject objectForType:QSURLType];
	if (onePasswordItem && targetURL) {
		NSURL *computedURL = openAndFillURL(targetURL, onePasswordItem);
		[[NSWorkspace sharedWorkspace] openURL:computedURL];
	}
	return nil;
}
@end
