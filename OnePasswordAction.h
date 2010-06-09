//
//  OnePasswordAction.h
//  OnePassword
//
//  Created by Patrick Robertson on 15/01/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
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

@interface OnePasswordAction : QSActionProvider
{
}

- (void)writePlistAndFill:(QSObject *)dObject;
- (QSObject *)viewInOnePwd:(QSObject *)dObject;
- (QSObject *)goAndFill:(QSObject *)dObject;
//- (QSObject *)trashForm:(QSObject *)dObject;

@end

