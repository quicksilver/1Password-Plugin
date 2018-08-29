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

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
	if ([[dObject objectForMeta:kOnePasswordItemCategory] isEqualToString:kOnePasswordCategoryLogin] || [[dObject primaryType] isEqualToString:QS1PasswordURLType]) {
		return @[@"openAndFill"];
	}
	return nil;
}

- (QSObject *)openAndFill:(QSObject *)dObject
{
	// see https://support.1password.com/integration-mac/#open-a-url
	return nil;
}
@end
