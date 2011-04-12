//
//  OnePasswordAction.h
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

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "OnePasswordAction.h"

#define kOnePasswordAction @"OnePasswordAction"
#define kQSObjectComponents @"QSObjectComponents"
#define QS1PasswordForm @"QS1PasswordForm"
#define QS1PasswordSecureNote @"QS1PasswordSecureNote"
#define QS1PasswordIdentity @"QS1PasswordIdentity"
#define QS1PasswordSoftwareLicense @"QS1PasswordSoftwareLicense"
#define QS1PasswordOnlineService @"QS1PasswordOnlineService"
#define QS1PasswordWalletItem @"QS1PasswordWalletItem"

// Some things from Carbon
#define kASAppleScriptSuite 'ascr'
#define kASSubroutineEvent  'psbr'
#define keyASSubroutineName 'snam'


@interface OnePasswordAction : QSActionProvider
{
}

- (void)writePlistAndFill:(QSObject *)dObject;
- (QSObject *)viewInOnePwd:(QSObject *)dObject;
- (QSObject *)goAndFill:(QSObject *)dObject;
//- (QSObject *)trashForm:(QSObject *)dObject;

@end

