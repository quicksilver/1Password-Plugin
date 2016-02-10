//
//  QSDropboxPreferencePane.m
//  Dropbox Plugin
//
//  Created by Patrick Robertson on 25/02/2013.
//
//

#import "QS1PasswordPreferencePane.h"
#import "OnePasswordDefines.h"

@implementation QS1PasswordPreferencePane

- (void)mainViewDidLoad {
    if (!onePasswdPathField.stringValue.length) {
        NSString *storedPath = [[NSUserDefaults standardUserDefaults] stringForKey:k1PPath];
        onePasswdPathField.stringValue = storedPath ? [storedPath stringByAbbreviatingWithTildeInPath] : @"Select the file containing your logins";
    }
}

-(IBAction)setPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"json"]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel beginWithCompletionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton) {
             NSURL *URLpath = [panel URL];
             [onePasswdPathField setStringValue:[URLpath path]];
             [[NSUserDefaults standardUserDefaults] setObject:[URLpath path] forKey:k1PPath];
             return;
         }
     }];
}

@end
