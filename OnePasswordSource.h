//
//  OnePasswordSource.h
//  OnePassword
//
//  Created by Patrick Robertson on 15/01/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QSCore/QSObjectSource.h>
#import "JSON.h"

#define QS1PasswordForm @"QS1PasswordForm"
#define QS1PasswordSecureNote @"QS1PasswordSecureNote"
#define QS1PasswordIdentity @"QS1PasswordIdentity"
#define QS1PasswordSoftwareLicense @"QS1PasswordSoftwareLicense"
#define QS1PasswordOnlineService @"QS1PasswordOnlineService"
#define QS1PasswordWalletItem @"QS1PasswordWalletItem"

@interface OnePasswordSource : QSObjectSource
{
}
@end


