//
//  ZoomSavePreviewView.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on Mon Mar 22 2004.
//  Copyright (c) 2004 Andrew Hunter. All rights reserved.
//

#import "ZoomSavePreviewView.h"
#import "ZoomSavePreview.h"


@implementation ZoomSavePreviewView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		upperWindowViews = nil;
		[self setAutoresizesSubviews: YES];
		[self setAutoresizingMask: NSViewWidthSizable];
    }
    return self;
}

- (void) dealloc {
	if (upperWindowViews) [upperWindowViews release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
}

- (void) setDirectoryToUse: (NSString*) directory {
	// Get rid of our old views
	if (upperWindowViews) {
		[upperWindowViews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		[upperWindowViews release];
		upperWindowViews = nil;
	}
	
	upperWindowViews =  [[NSMutableArray alloc] init];
	
	if (directory == nil || ![[NSFileManager defaultManager] fileExistsAtPath: directory]) {
		NSRect ourFrame = [self frame];
		ourFrame.size.height = 2;
		[self setFrameSize: ourFrame.size];
		[self setNeedsDisplay: YES];
		return;
	}
	
	// Get our frame size
	NSRect ourFrame = [self frame];
	ourFrame.size.height = 0;
	
	// Load all the zoomQuet files from the given directory
	NSArray* contents = [[NSFileManager defaultManager] directoryContentsAtPath: directory];
	
	if (contents == nil) {
		return;
	}
	
	// Read in the previews from any .zoomQuet packages
	NSEnumerator* fileEnum = [contents objectEnumerator];
	NSString* file;
	
	while (file = [fileEnum nextObject]) {
		if ([[[file pathExtension] lowercaseString] isEqualToString: @"zoomquet"]) {
			// This is a zoomQuet file - load the preview
			NSString* previewFile = [directory stringByAppendingPathComponent: file];
			previewFile = [previewFile stringByAppendingPathComponent: @"ZoomPreview.dat"];
			
			BOOL isDir;
			
			if (![[NSFileManager defaultManager] fileExistsAtPath: previewFile
													  isDirectory: &isDir]) {
				// Can't be a valid zoomQuet file
				continue;
			}
			
			if (isDir) {
				// Also can't be a valid zoomQuet file
				continue;
			}
			
			// Presumably, this is a valid preview file...
			ZoomUpperWindow* win = [NSUnarchiver unarchiveObjectWithFile: previewFile];
			
			if (win == nil) continue;
			if (![win isKindOfClass: [ZoomUpperWindow class]]) continue;
			
			// We've got a valid window - add to the list of upper windows
			ZoomSavePreview* preview;
			
			preview = [[ZoomSavePreview alloc] initWithPreview: win
													  filename: previewFile];
			
			[preview setAutoresizingMask: NSViewWidthSizable];
			[self addSubview: preview];
			[upperWindowViews addObject: [preview autorelease]];
		}
	}
	
	// Arrange the views, resize ourselves
	float size = 2;
	NSRect bounds = [self bounds];
	
	NSEnumerator* viewEnum = [upperWindowViews objectEnumerator];
	ZoomSavePreview* view;
	
	while (view = [viewEnum nextObject]) {
		[view setFrame: NSMakeRect(0, size, bounds.size.width, 48)];
		size += 49;
	}
	
	NSRect frame = [self frame];
	frame.size.height = size;
	
	[self setFrameSize: frame.size];
	[self setNeedsDisplay: YES];
}


@end
