//
//  AppDelegate.m
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
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
	if (!storedLinks) {
		storedLinks = [[NSMutableArray alloc] init];
	}

	[self.linksTableView setDelegate:self];
	[self.linksTableView setDataSource:self];

	[self.button_deleteLink setEnabled:NO];
	[self.button_openLink setEnabled:NO];
	[self.button_clipboard setEnabled:NO];
}

- (NSURL *)trySettingUpURLWithString:(NSString *)attempt
{
	if ([self validateUrl:attempt]) {
		NSURL *result = [[NSURL alloc] initWithString:attempt];
		return result;
	} else {
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

- (BOOL)validateUrl:(NSString *)url {
	NSString *theURL = @"^(http|https|ftp)\\://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9\\-\\._\\?\\,\'/\\\\\\+&amp;%\\$#\\=~])*$";
	NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theURL];
	return [urlTest evaluateWithObject:url];
}

- (NSString *)appSupportFolder {
	NSString *libDir;

	libDir = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Links Keeper/"];

	if (![[NSFileManager defaultManager] fileExistsAtPath:libDir]) {
		#ifdef DEBUG
		NSLog(@"Creating Application Support Folder");
		#endif
		[[NSFileManager defaultManager] createDirectoryAtPath:libDir withIntermediateDirectories:YES attributes:nil error:nil];
	}

	return libDir;
}

- (void)saveDataToFile
{
	[self.progressIndicator setHidden:NO];
	[self.progressIndicator startAnimation:self];
	NSData *compressedData = [NSKeyedArchiver archivedDataWithRootObject:storedLinks];
	NSString *file = [[self appSupportFolder] stringByAppendingPathComponent:@"links.plist"];
	[compressedData writeToFile:file atomically:YES];
	[self performSelector:@selector(animateSavedLabel) withObject:nil afterDelay:0.5];
}

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

- (void)readDataFromFile
{
	[self.progressIndicator startAnimation:self];
	NSString *file = [[self appSupportFolder] stringByAppendingPathComponent:@"links.plist"];
	storedLinks = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	[self.linksTableView reloadData];
	[self updateLinksCount];
	[self.progressIndicator performSelector:@selector(stopAnimation:) withObject:self afterDelay:0.5];
}

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
				informativeTextWithFormat:@""];
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
	NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
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
	[saveDlg setNameFieldStringValue:@"ExportedLinks.bxml"];

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
	if ([alert runModal] == 0) {
		return;
	}
	
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];

	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setAllowsMultipleSelection:NO];

	NSInteger returnValue = [openDlg runModal];
	
	if (returnValue == 1)
	{
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
	if ([[aTableColumn identifier] isEqualToString:@"name"]) {
		return [(LinkData *)[storedLinks objectAtIndex:rowIndex] name];
	} else {
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

	switch (editedColumn) {
		case 0:
		{
			[(LinkData *)[storedLinks objectAtIndex:editedRow] setName:[field string]];
			[self saveDataToFile];
		}
			break;

		case 1:
		{
			NSURL *url = [self trySettingUpURLWithString:[field string]];
			if (url) {
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
