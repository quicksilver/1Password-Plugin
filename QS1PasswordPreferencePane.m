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
        onePasswdPathField.stringValue = storedPath ? [self prettyPath:[NSURL fileURLWithPath:storedPath]] : @"Select the file containing your logins";
    }
}

- (NSString *)prettyPath:(NSURL *)URLpath {
    NSString *prettyPath = [NSString string];
    for (NSString *pathComponent in [[URLpath pathComponents] subarrayWithRange:NSMakeRange(1, [URLpath pathComponents].count - 1)]) {
        prettyPath = [prettyPath stringByAppendingFormat:@"▸ %@ ",pathComponent];
    }
    return prettyPath;
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
             [onePasswdPathField setStringValue:[self prettyPath:URLpath]];
             [[NSUserDefaults standardUserDefaults] setObject:[URLpath path] forKey:k1PPath];
             return;
         }
     }];
}

@end
