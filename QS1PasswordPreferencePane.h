//
//  QSDropboxPreferencePane.h
//  Dropbox Plugin
//
//  Created by Patrick Robertson on 25/02/2013.
//
//

#import <Cocoa/Cocoa.h>
#include <QSInterface/QSInterface.h>

@interface QS1PasswordPreferencePane : QSPreferencePane {
    IBOutlet NSTextField *onePasswdPathField;
}

- (IBAction)setPath:(id)sender;

@end
