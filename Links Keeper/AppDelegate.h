//
//  AppDelegate.h
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//	Copyright (C) 2013 Bruno Philipe
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import "LinkData.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>


@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTableView *linksTableView;

@property (strong) IBOutlet NSTextField *label_count;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *label_saved;

@property (strong) IBOutlet NSToolbarItem *button_deleteLink;
@property (strong) IBOutlet NSToolbarItem *button_openLink;
@property (strong) IBOutlet NSToolbarItem *button_clipboard;

@property (strong) IBOutlet NSMenuItem *menu_deleteLink;
@property (strong) IBOutlet NSMenuItem *menu_openLink;
@property (strong) IBOutlet NSMenuItem *menu_clipboard;

/**
 Action called by pressing the "Add Link" button on the toolbar or on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)addLink:(id)sender;

/**
 Action called by pressing the "Remove Link" button on the toolbar or on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)removeLink:(id)sender;

/**
 Action called by pressing the "Open Link" button on the toolbar or on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)openLink:(id)sender;

/**
 Action called by pressing the "Copy to Clipboard" button on the toolbar or on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)copyToClipboard:(id)sender;

/**
 Action called by pressing the "Export Links" button on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)exportLinks:(id)sender;

/**
 Action called by pressing the "Import Links" button on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)importLinks:(id)sender;

/**
 Action called by pressing the "Show Window" button on the menu.
 @param sender The object who sent the message.
 */
- (IBAction)showWindow:(id)sender;

@end
