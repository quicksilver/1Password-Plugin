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
#define kOnePasswordBundleIDs @[@"com.agilebits.onepassword-osx", @"ws.agile.1Password", @"com.agilebits.onepassword4"]

// Key for storing the keychain path in the prefs
#define k1PPath @"QS1PasswordKeychainPath"
