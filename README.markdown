# 1Password 3 Plugin 

## What does it do?

This plugin enables you to right arrow into the 1Password application, giving you a list of all your data saved in 1Password.

Requirements: **Mac OS X Leopard or higher (10.5+)**, **1Password 3+** and **Quicksilver ß60+**.

You can download the latest version from the [Plugins preference pane in Quicksilver](http://qs.qsapp.com/plugins)

### Actions

The plugin enables 2 actions for 1Password objects.

The 'Go & Fill' action will work just like the Go & Fill command from within 1Password; it will launch your default browser and automatically log you in.

The 'Go & Fill With...' action enabled you to open logins in your non-default browser(s).

Both the 'Go & Fill' and 'Go & Fill With...' actions work with the comma trick, so you can open multiple logins at once, or open logins in multiple browsers.

![Go And Fill... Action](http://i42.tinypic.com/i35lig.jpg "Go And Fill... Action")

--------

Previously, the plugin also added the following action to Quicksilver, but it no longer works with recent versions of 1Password.

The final action, which works on all 1Password objects is 'Reveal in 1Password'. This action will launch 1Password and bring the selected login item to the front for you to view/edit it.

![Open in 1Password Action](http://i42.tinypic.com/wk62qd.jpg "Open in 1Password Action")


### Adding to the Catalog

To save you from having to search for 1Password in the first pane then right arrowing into it, you can **tick** any of the 1Password data types (logins, identities, secure notes etc.) in the Quicksilver Catalog Preferences Pane (under Modules). This will mean that the 1Password types enabled will be searchable directly from the first pane in Quicksilver. This feature is disabled by default.

![1Password Catalog Source](http://i.imgur.com/RDRP7.jpg "1Password Catalog Source")

-----------

## Getting Started

First, make sure you're using the **Agile Keychain** or **opvault** keychain. You will also need to go into the 1Password settings and click 'Advanced' then 'Enable 3rd party app integrations'.

You may need to rescan manually to start with to get your logins to show up.
If the plugin doesn't seem to work, try re-downloading and installing it. Quicksilver will pop up a message saying 'Install Complete'.
Click 'Relaunch' and it should hopefully fix any of your problems.

![Relaunch Dialog](http://i43.tinypic.com/35bi0es.jpg "Relaunch Dialog")

## Thanks

Thanks goes to Rob McBroom for his excellent work on writing documentation detailing [QS Plugin Development]((http://github.com/tiennou/blacktree-elements/blob/master/PluginDevelopmentReference/QuicksilverPlug-inReference.mdown)http://projects.skurfer.com/QuicksilverPlug-inReference.mdown).
Thanks also to Jamie of the 1Password development team for his [excellent advice](http://support.agilewebsolutions.com/showthread.php?21959-Developing-a-Quicksilver-Plugin-for-1Password) and insights into how 1Password works.

## Changelog

### 2.0.0
**Plugin overhaul and tidy up**

* Now Quicksilver versions ß60+ only
* Fixed object identifiers. Can now set abbreviations and increase/decrease score for 1Password objects
* Added new 'Go and Fill With...' action to allow you to log in with different browsers
* Many memory leak fixes
* More robust error logging
* Fixed a fatal crash that could be caused with multiple 1Password entries with the same name 
* Changed to YAJL for JSON parsing. Maintains 10.5 support and faster than SBJSON
* Code optimisations and reduction of duplicate code
* More efficient storing of data in QSObjects
* Source code tidy up and fixed references in .xcodeproj
* Other small bug fixes

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
