# 1Password 3 Plugin 

## What does it do?

This plugin enables you to right arrow into the 1Password application, giving you a list of all your Logins saved in 1Password.

For this plugin to work, you must have **Mac OS X Leopard or higher (10.5+)** and **1Password 3+**. It is also recommended you upgrade to QS β58+ if you're having problems.

You can download the latest version and any previous versions from the Github downloads page [here](http://github.com/pjrobertson/1Password-Plugin/downloads "Download")

### Actions

Having selected a login there are 2 actions that you can perform.

Using the action 'Go & Fill...' will work just like the Go & Fill command from within 1Password; it will launch your default browser and automatically log you in.

The 'Go & Fill...' action works with the comma trick, so you can open multiple logins at once.

![Go And Fill... Action](http://i42.tinypic.com/i35lig.jpg "Go And Fill... Action")


The second action is 'Open in 1Password'. This action will launch 1Password and bring the selected login item to the front for you to view/edit etc.

![Open in 1Password Action](http://i42.tinypic.com/wk62qd.jpg "Open in 1Password Action")


### Adding to the Catalog

To save you time from having to search for 1Password then right arrow, you can **tick** the 'Web Forms' source in the Catalog Preferences Pane (under Modules). This will make all forms will searchable from anywhere in Quicksilver (this is disabled by default).

![1Password Catalog Source](http://i43.tinypic.com/znvo1.jpg "1Password Catalog Source")

## Getting Started

First, make sure you're using the **Agile Keychain**. The plugin does **not** work with the Mac OS X keychain.

You may need to rescan manually to start with to get your logins to show up.
If the plugin doesn't seem to work, try re-downloading and installing it. Quicksilver will pop up a message saying 'Install Complete'.
Click 'Relaunch' and it should hopefully fix any of your problems.

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

### 0.7
*  Changed the precedence of the Actions

   I'd meant to set 'Go & Fill...' to be first but had actually set 'Open in 1Password to be first'
   You only really need to download this version if...

     1. This is the first time you're using the plugin
     2. You haven't changed the order of the actions and want 'Go & Fill...' to be the default action

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