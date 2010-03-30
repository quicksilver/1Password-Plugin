# 1Password 3 Plugin 

## What does it do?

This plugin enables you to right arrow into the 1Password application, giving you a list of all your Logins saved in 1Password.

### Actions

Having selected a login, using the action 'Go & Fill...' will perform just like the Go & Fill from within 1Password.

The 'Go & Fill...' action works with the comma trick, so you can open multiple logins at once.

### Adding to the Catalog

To save you time from having to search for 1Password then right arrow, you can **tick** the 'Web Forms' source in the Catalog Preferences Pane (under Modules). This will make all forms will searchable from anywhere in Quicksilver (this is disabled by default).

## Getting Started

First, make sure you're using the **Agile Keychain**. The plugin does **not** work with the Mac OS X keychain.

You may need to rescan manually to start with to get your logins to show up.
If the plugin doesn't seem to work, try re-downloading and installing it so you get a message from Quicksilver Saying 'Install Complete asking you to 'Relaunch' or do so 'Later' (chose 'Relaunch').

![Relaunch Dialog](http://i43.tinypic.com/35bi0es.jpg "Relaunch Dialog")

**If either of the actions don't seem to work, I'd recommend upgrading to QS β58+**

## Bugs

This is an early test project, and any ideas or bugs should be addressed to me@patjack.co.uk

## Donating

Believe it or not, this plugin has taken me quite a while to develop. If you wish to donate, then the link's in the top right hand corner and I'd really appreciate it :)

**Don't donate here for any work I've done on the QS app itself, this is just for my plugin**

## Thanks

Thanks goes to Rob McBroom for his excellent work on writing documentation detailing [QS Plugin Development](http://github.com/tiennou/blacktree-elements/blob/master/PluginDevelopmentReference/QuicksilverPlug-inReference.mdown).
Thanks also to Jamie of the 1Password development team for his [excellent advice](http://support.agilewebsolutions.com/showthread.php?21959-Developing-a-Quicksilver-Plugin-for-1Password) and insights into how 1Password works.

## Changelog

### 0.4
*	Updated to JSON framework 2.2.3 (Released: 07/03/10)
*	Set project to build JSON framework from scratch to avoid linking problems

### 0.3
*	Fixed: 'Open in 1Password' action for some (make sure using latest QS β58+)

### 0.2
*	Added 'Open in 1Password' action

### 0.1
*	Initial Release