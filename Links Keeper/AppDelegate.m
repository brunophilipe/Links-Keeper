//
//  AppDelegate.m
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

#import "AppDelegate.h"

@implementation AppDelegate
{
	NSMutableArray *storedLinks;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self readDataFromFile];
	if (!storedLinks)
	{
		storedLinks = [[NSMutableArray alloc] init];
	}

	[self.linksTableView setDelegate:self];
	[self.linksTableView setDataSource:self];

	[self.button_deleteLink setEnabled:NO];
	[self.button_openLink setEnabled:NO];
	[self.button_clipboard setEnabled:NO];
}

/**
 Validates the string using `-validateUrl:`. If it passes the test, creates an `NSURL` object and initializes it with the parameter string as URL.
 @param attempt The string to be tested and used.
 @returns An NSURL instance if `attempt` is valid. Otherwise returns `nil`.
 */
- (NSURL *)trySettingUpURLWithString:(NSString *)attempt
{
	if ([self validateUrl:attempt])
	{
		NSURL *result = [[NSURL alloc] initWithString:attempt];
		return result;
	}
	else
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"The inserted link is not valid! Please check for typing errors. (URL is Malformed)"];
		[[alert window] setTitle:@"Links Keeper"];
		[alert runModal];
		return nil;
	}
}

/**
 Verifies if the provided URL is valid for instantiating a `NSURL` object. Currently supports http, https and ftp protocol only.
 @param url The string to be verified as URL.
 @returns `YES` if string is valid, otherwise returns `NO`.
 */
- (BOOL)validateUrl:(NSString *)url
{
	NSString *theURL = @"^(http|https|ftp)\\://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9\\-\\._\\?\\,\'/\\\\\\+&amp;%\\$#\\=~])*$";
	NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theURL];
	return [urlTest evaluateWithObject:url];
}

/**
 Finds and creates if necessary the Application Support folder for the App. By default it is placed in `"~/Library/Application Support/Links Keeper/"`.
 
 @returns The App Support folder path as a string.
 */
- (NSString *)appSupportFolder
{
	NSString *libDir;

	libDir = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Links Keeper/"];

	if (![[NSFileManager defaultManager] fileExistsAtPath:libDir])
	{
		#ifdef DEBUG
		NSLog(@"Creating Application Support Folder");
		#endif
		[[NSFileManager defaultManager] createDirectoryAtPath:libDir withIntermediateDirectories:YES attributes:nil error:nil];
	}

	return libDir;
}

/**
 Serializes the data from the `storedLinks` variable and stores it on a custom file in the Application Support folder.
 
 The file is saved in `"~/Library/Application Support/Links Keeper/links.plist"`.
 
 This method also makes the activity indicator on the status bar visible. After finished, it calls `-animateSavedLabel` to make it stop using a graceful animation.
 */
- (void)saveDataToFile
{
	[self.progressIndicator setHidden:NO];
	[self.progressIndicator startAnimation:self];
	NSData *compressedData = [NSKeyedArchiver archivedDataWithRootObject:storedLinks];
	NSString *file = [[self appSupportFolder] stringByAppendingPathComponent:@"links.plist"];
	[compressedData writeToFile:file atomically:YES];
	[self performSelector:@selector(animateSavedLabel) withObject:nil afterDelay:0.5];
}

/**
 Stops and hides the activity indicator in the status bar using core animations.
 */
- (void)animateSavedLabel
{
	[self.progressIndicator stopAnimation:self];
	[self.label_saved setHidden:NO];
	NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[@{NSViewAnimationTargetKey: self.label_saved, NSViewAnimationStartFrameKey: [NSValue valueWithRect:self.label_saved.frame], NSViewAnimationEndFrameKey: [NSValue valueWithRect:self.label_saved.frame], NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect}]];
		[animation startAnimation];
	}];
	[block performSelector:@selector(start) withObject:nil afterDelay:0.5];
}

/**
 Reads the contents of the file in the Application Support folder and unserializes it.
 */
- (void)readDataFromFile
{
	[self.progressIndicator startAnimation:self];
	NSString *file = [[self appSupportFolder] stringByAppendingPathComponent:@"links.plist"];
	storedLinks = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	[self.linksTableView reloadData];
	[self updateLinksCount];
	[self.progressIndicator performSelector:@selector(stopAnimation:) withObject:self afterDelay:0.5];
}

/**
 Updates the link counter on the status bar.
 */
- (void)updateLinksCount
{
	NSInteger count = [storedLinks count];
	[self.label_count setStringValue:[NSString stringWithFormat:@"%ld Link%c",(long)count,(count != 1 ? 's' : ' ')]];
}

#pragma mark - Actions

- (IBAction)addLink:(id)sender {
	NSAlert		*alert;
	NSView		*view;
	NSTextField *fieldName;
	NSTextField *fieldURL;

	//Build alert view
	alert = [NSAlert alertWithMessageText:@"Insert Link information:"
							defaultButton:@"OK"
						  alternateButton:@"Cancel"
							  otherButton:nil
				informativeTextWithFormat:@"If there is a link on your clipboard, Links Keeper places it below automatically."];
	[[alert window] setTitle:@"Links Keeper"];

	//Build input view
	view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 50)];

	fieldName = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 30, 300, 20)];
	[fieldName setTag:1];
	[[fieldName cell] setPlaceholderString:@"Insert the Link name here"];

	fieldURL = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 20)];
	[fieldURL setTag:2];
	[[fieldURL cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[[fieldURL cell] setPlaceholderString:@"Insert the URL here"];

	//If clipboard contains a link, put it in the URL field
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSArray *classes = @[[NSString class]];
	NSDictionary *options = [NSDictionary dictionary];
	NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
	if (copiedItems != nil && copiedItems.count > 0 && [self validateUrl:[copiedItems objectAtIndex:0]]) {
		[fieldURL setStringValue:[copiedItems objectAtIndex:0]];
	}

	//Add the fields to the accessory view
	[view addSubview:fieldName];
	[view addSubview:fieldURL];

	//Insert accessory view into alert view
	[alert setAccessoryView:view];

	//Run alert
	NSInteger result = [alert runModal];

	//Check alert output
	if (result == 1) {
		NSURL *url = [self trySettingUpURLWithString:[fieldURL stringValue]];
		if (url) {
			[storedLinks addObject:[LinkData linkDataWithName:[fieldName stringValue] andURL:url]];
			[self updateLinksCount];
			[self.linksTableView reloadData];
			[self saveDataToFile];
		}
	}
}

- (IBAction)removeLink:(id)sender {
	NSString *informative;
	NSIndexSet *selectedRows = [self.linksTableView selectedRowIndexes];
	if ([selectedRows count] > 1) {
		informative = @"Are you sure you want to delete these links? There is no undo!";
	} else {
		informative = @"Are you sure you want to delete this link? There is no undo!";
	}

	NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!"
									 defaultButton:@"Delete"
								   alternateButton:@"Cancel"
									   otherButton:nil
						 informativeTextWithFormat:@"%@",informative];
	[[alert window] setTitle:@"Links Keeper"];
	
	if ([alert runModal] == 1) {
		[self.linksTableView beginUpdates];
		[self.linksTableView removeRowsAtIndexes:selectedRows withAnimation:NSTableViewAnimationEffectGap];
		[storedLinks removeObjectsAtIndexes:selectedRows];
		[self.linksTableView endUpdates];
		[self updateLinksCount];
		[self.linksTableView reloadData];
		[self saveDataToFile];
	}
}

- (IBAction)openLink:(id)sender {
	NSInteger selectedRow = [self.linksTableView selectedRow];
	if (selectedRow >= 0) {
		[[NSWorkspace sharedWorkspace] openURL:[(LinkData *)[storedLinks objectAtIndex:selectedRow] url]];
	}
}

- (IBAction)copyToClipboard:(id)sender {
	NSInteger selectedRow = [self.linksTableView selectedRow];
	if (selectedRow >= 0) {
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		[pasteboard clearContents];
		[pasteboard writeObjects:@[[(LinkData *)[storedLinks objectAtIndex:selectedRow] url]]];
	}
}

- (IBAction)exportLinks:(id)sender {
	NSSavePanel *saveDlg = [NSSavePanel savePanel];

	[saveDlg setCanCreateDirectories:YES];
	[saveDlg setCanSelectHiddenExtension:NO];
	[saveDlg setExtensionHidden:YES];
	[saveDlg setNameFieldStringValue:@"ExportedLinks.bxml"]; //Binary XML

	NSInteger returnValue = [saveDlg runModal];

	if (returnValue == 1) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:storedLinks];
		NSString *filePath = [[saveDlg URL] relativePath];
		NSLog(@"Exporting to: %@",filePath);
		[data writeToFile:filePath atomically:YES];
	}
}

- (IBAction)importLinks:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!" defaultButton:@"Continue" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Are you sure you want to continue? All your current links will be merged with the links from the file."];
	[[alert window] setTitle:@"Links Keeper"];
	
	if ([alert runModal] == 0)
	{
		//Alert view returned the "Cancel button pressed" status
		return;
	}
	
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];

	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setAllowsMultipleSelection:NO];

	NSInteger returnValue = [openDlg runModal];
	
	if (returnValue == 1)
	{
		//Open panel returned "OK button pressed" status
		NSURL* file = [[openDlg URLs] objectAtIndex:0];
		NSMutableArray *importedLinks = [NSKeyedUnarchiver unarchiveObjectWithFile:[file relativePath]];
		for (LinkData *link in importedLinks) {
			[storedLinks addObject:link];
		}
		[importedLinks removeAllObjects];
		importedLinks = nil;
		[self.linksTableView reloadData];
		[self updateLinksCount];
		[self saveDataToFile];
	}
}

- (IBAction)showWindow:(id)sender {
	[self.window makeKeyAndOrderFront:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return storedLinks.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"name"])
	{
		return [(LinkData *)[storedLinks objectAtIndex:rowIndex] name];
	}
	else
	{
		return [[(LinkData *)[storedLinks objectAtIndex:rowIndex] url] absoluteString];
	}
}

#pragma mark - Table view delegate

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
	NSTableView		*tv =				[obj object];
	NSTextView		*field =			[[obj userInfo] objectForKey:@"NSFieldEditor"];
	NSInteger		editedColumn =		[tv editedColumn];
	NSInteger		editedRow =			[tv editedRow];

	switch (editedColumn)
	{
		case 0:
		{
			[(LinkData *)[storedLinks objectAtIndex:editedRow] setName:[field string]];
			[self saveDataToFile];
		}
			break;

		case 1:
		{
			NSURL *url = [self trySettingUpURLWithString:[field string]];
			if (url)
			{
				[(LinkData *)[storedLinks objectAtIndex:editedRow] setUrl:url];
				[self saveDataToFile];
			}
		}
			break;

		default:
			break;
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	/*
	 Changes the enabled status for the Toolbar buttons. "Delete Link" button should not be enabled if there are no links selected.
	 */
	NSInteger selectedRow = [self.linksTableView selectedRow];
	if (selectedRow < 0)
	{
		[self.button_deleteLink setEnabled:NO];
		[self.button_openLink setEnabled:NO];
		[self.button_clipboard setEnabled:NO];

		[self.menu_deleteLink setEnabled:NO];
		[self.menu_openLink setEnabled:NO];
		[self.menu_clipboard setEnabled:NO];
	}
	else if ([[self.linksTableView selectedRowIndexes] count] > 1)
	{
		[self.button_deleteLink setEnabled:YES];
		[self.button_openLink setEnabled:NO];
		[self.button_clipboard setEnabled:NO];

		[self.menu_deleteLink setEnabled:YES];
		[self.menu_openLink setEnabled:NO];
		[self.menu_clipboard setEnabled:NO];
	}
	else
	{
		[self.button_deleteLink setEnabled:YES];
		[self.button_openLink setEnabled:YES];
		[self.button_clipboard setEnabled:YES];

		[self.menu_deleteLink setEnabled:YES];
		[self.menu_openLink setEnabled:YES];
		[self.menu_clipboard setEnabled:YES];
	}
}

@end
