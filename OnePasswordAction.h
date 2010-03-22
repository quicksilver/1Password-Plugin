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

@interface OnePasswordAction : QSActionProvider
{
}

- (void)writePlistAndFill:(QSObject *)dObject;
- (QSObject *)viewInOnePwd:(QSObject *)dObject;
- (QSObject *)goAndFill:(QSObject *)dObject;
//- (QSObject *)trashForm:(QSObject *)dObject;

@end

