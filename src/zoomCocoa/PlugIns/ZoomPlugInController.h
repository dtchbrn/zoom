//
//  ZoomPlugInController.h
//  ZoomCocoa
//
//  Created by Andrew Hunter on 29/09/2007.
//  Copyright 2007 Andrew Hunter. All rights reserved.
//

#import <Cocoa/Cocoa.h>


///
/// NSWindowController object that runs the plugins window
///
@interface ZoomPlugInController : NSWindowController {
	IBOutlet NSTableView* pluginTable;								// The table of plugins
	IBOutlet NSProgressIndicator* pluginProgress;					// Download progress indicator
	IBOutlet NSButton* installButton;								// The 'install' button
	IBOutlet NSTextField* statusField;								// The status field
}

// Initialisation
+ (ZoomPlugInController*) sharedPlugInController;					// The shared plugin controller window

// Actions
- (IBAction) installUpdates: (id) sender;							// 'Install' button clicked

@end
