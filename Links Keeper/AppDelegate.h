//
//  AppDelegate.h
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
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
