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
        onePasswdPathField.stringValue = @"Select your .agilekeychain";
    }
}


-(IBAction)setPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"agilekeychain"]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel beginWithCompletionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton) {
             NSURL *URLpath = [panel URL];
             NSString *prettyPath = [NSString string];
             for (NSString *pathComponent in [URLpath pathComponents]) {
                 prettyPath = [prettyPath stringByAppendingFormat:@"▸ %@ ",pathComponent];
             }
             [onePasswdPathField setStringValue:[prettyPath substringFromIndex:2]];
             [[NSUserDefaults standardUserDefaults] setObject:[URLpath path] forKey:k1PPath];
             return;
         }
     }];
}

@end
