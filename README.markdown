# 1Password 3 Plugin 

## What does it do?

This plugin enables you to right arrow into the 1Password application, giving you a list of all your Logins saved in 1Password.

For this plugin to work, you must have **Mac OS X Leopard or higher (10.5+)** and **1Password 3+**. It is also recommended you upgrade to QS β58+ if you're having problems.

You can download the latest version and any previous versions from the [Quicksilver Plugins Repository](http://qsapp.com/plugins "Download")

### Actions

Having selected a login there are 2 actions that you can perform.

Using the action 'Go & Fill...' will work just like the Go & Fill command from within 1Password; it will launch your default browser and automatically log you in.

The 'Go & Fill...' action works with the comma trick, so you can open multiple logins at once.

![Go And Fill... Action](http://i42.tinypic.com/i35lig.jpg "Go And Fill... Action")


The second action is 'Open in 1Password'. This action will launch 1Password and bring the selected login item to the front for you to view/edit etc.

![Open in 1Password Action](http://i42.tinypic.com/wk62qd.jpg "Open in 1Password Action")


### Adding to the Catalog

To save you from having to search for 1Password in the first pane then right arrowing into it, you can **tick** any of the 1Password data types (logins, identities, secure notes etc.) in the Quicksilver Catalog Preferences Pane (under Modules). This will mean that the 1Password types enabled will be searchable directly from the first pane in Quicksilver. This feature is disabled by default.

![1Password Catalog Source](http://i.imgur.com/RDRP7.jpg "1Password Catalog Source")

## Getting Started

First, make sure you're using the **Agile Keychain**. The plugin does **not** work with the Mac OS X keychain. (Check in the 1Password preferences).

You may need to rescan manually to start with to get your logins to show up.
If the plugin doesn't seem to work, try re-downloading and installing it. Quicksilver will pop up a message saying 'Install Complete'.
Click 'Relaunch' and it should hopefully fix any of your problems.

![Relaunch Dialog](http://i43.tinypic.com/35bi0es.jpg "Relaunch Dialog")

**If either of the actions don't seem to work, I'd recommend upgrading to QS β58+**

## Donating

Believe it or not, this plugin has taken me quite a while to develop. If you wish to donate, then the click the links below. I'd really appreciate it :)

[![Donate to Quicksilver 1Password Plugin](https://www.paypal.com/en_GB/i/btn/btn_donate_LG.gif "Donate")](http://patjack.co.uk/donating-for-my-quicksilver-1password-plugin/)  (Redirect) - Click the 'Donate' button on the redirected page.

**Don't donate here for any work I've done on the QS app itself, this is just for my plugin**

## Bugs

This is nicely maturing, but you may still have some ideas or have found some bugs. If so, let me know at me@patjack.co.uk


## Thanks

Thanks goes to Rob McBroom for his excellent work on writing documentation detailing [QS Plugin Development](http://github.com/tiennou/blacktree-elements/blob/master/PluginDevelopmentReference/QuicksilverPlug-inReference.mdown).
Thanks also to Jamie of the 1Password development team for his [excellent advice](http://support.agilewebsolutions.com/showthread.php?21959-Developing-a-Quicksilver-Plugin-for-1Password) and insights into how 1Password works.

## Changelog

### 1.2
**Interface clean up. Things look much better :)**

* Cleaned up the interface. The plugin now displays the names of Web Forms, and it's these names that are searchable. This greatly cleans the UI.
* Fixed a bug that would cause Quicksilver to hang (re-cataloguing everything) when trying to right arrow into a 1Password Object in Quicksilver.

### 1.0
**Reached the 1.0 milestone!**

* Fixed a bug that had cropped into the 0.9 release stopping some users from indexing their 1Password entries

### 0.9
**This is quite a major update to the 1Password Plugin!**

* Added alternate action to go and fill - hold CMD to 'reveal in 1Pwd'
* Action 'Open in 1Password' renamed to 'Reveal in 1Password' - more Mac like
* Added scanning of identities, accounts, software and secure notes
* Added separate entries in the catalog preference pane to chose which sources to scan
* Better crash resilience - won't crash if there's a problem finding the keychain or indexing the catalog
* Fixed a (fairly) bug for users when their keychain was in the default ~/Library/Application Support/1Password folder
* Added nice new icons for each type of 1Password data

### 0.8
* Fixed bug when 'Opening in 1Password' after having searched using the 1Password search field

### 0.7
*  Changed the precedence of the Actions

### 0.6
* Fixed another applescript problem by using Apple's NSApplescript approach as opposed to Alcor's
* *Hopefully* fixed most people's bugs

### 0.5
* Fixed problem where keychain location wasn't being picked up properly for some due to the '~' (tilde) in the file name

### 0.4
*	Updated to JSON framework 2.2.3 (Released: 07/03/10)
*	Set project to build JSON framework from scratch to avoid linking problems

### 0.3
*	Fixed: 'Open in 1Password' action for some (make sure using latest QS β58+)

### 0.2
*	Added 'Open in 1Password' action

### 0.1
*	Initial Release