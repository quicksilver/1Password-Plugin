// Keychain location defines
#define kOldKeychainLocation @"~/Library/Application Support/1Password/1Password.agilekeychain"
#define kNewMASKeychainLocation @"~/Library/Containers/com.agilebits.onepassword-osx-helper/Data/Documents/1Password.agilekeychain"
#define kDropboxLocation @"~/Dropbox/1Password/1Password.agilekeychain"
#define kOldDropboxLocation @"~/Dropbox/1Password.agilekeychain"

#define kKeychainPathArray [NSArray arrayWithObjects:kOldKeychainLocation,kNewMASKeychainLocation,kDropboxLocation,kOldDropboxLocation,nil]

// QSObject type defines
#define QS1PasswordForm @"QS1PasswordForm"
#define kOnePasswordAction @"OnePasswordAction"

// Some things from Carbon
#define kASAppleScriptSuite 'ascr'
#define kASSubroutineEvent  'psbr'
#define keyASSubroutineName 'snam'

// JSON defines
#define kItemType @"type"

// OnePassword Bundle IDs
#define kNonMASBundleID @"com.agilebits.onepassword4"
#define kMASBundleID @"com.agilebits.onepassword-osx"
#define kOnePasswordBundleIDs @[kMASBundleID, @"ws.agile.1Password", kNonMASBundleID]
#define kOnePasswordPrefs @[kNonMASBundleID, [[@"~/Library/Containers/com.agilebits.onepassword-osx/Data/Library/Preferences/" stringByStandardizingPath] stringByAppendingPathComponent:kMASBundleID]]

// Key for storing the keychain path in the prefs
#define k1PPath @"QS1PasswordKeychainPath"

#define kQS1PasswordIcon @"QS1PasswordIcon"

#define kMAS1Password3rdPartyFile @"~/Library/Containers/2BUA8C4S2C.com.agilebits.onepassword-osx-helper/Data/Library/3rd Party Integration/bookmarks-default.json"
#define kNonMAS1Password3rdPartyFile @"~/Library/Application Support/1Password 4/3rd Party Integration/bookmarks-default.json"