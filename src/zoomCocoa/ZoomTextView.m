//
//  ZoomTextView.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on Thu Oct 09 2003.
//  Copyright (c) 2003 Andrew Hunter. All rights reserved.
//

#import "ZoomTextView.h"
#import "ZoomView.h"

@implementation ZoomTextView

- (id) initWithFrame: (NSRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        pastedLines = [[NSMutableArray allocWithZone: [self zone]] init];
    }
    return self;
}

- (void) dealloc {
    [pastedLines release];
    [super dealloc];
}

- (void) keyDown: (NSEvent*) event {
    NSView* superview = [self superview];

    while (![superview isKindOfClass: [ZoomView class]]) {
        superview = [superview superview];
        if (superview == nil) break;
    }

    if (![(ZoomView*)superview handleKeyDown: event]) {
        [super keyDown: event];
    }
}

- (void) drawRect: (NSRect) r {
    [super drawRect: r];

    NSRect ourBounds = [self bounds];
    NSRect superBounds = [[self superview] frame];

    // The enclosing ZoomView
    NSView* superview = [self superview];

    while (![superview isKindOfClass: [ZoomView class]]) {
        superview = [superview superview];
        if (superview == nil) break;
    }
    ZoomView* zoomView = (ZoomView*) superview;

    double offset = [zoomView upperBufferHeight];
    
    // Draw pasted lines
    NSEnumerator* lineEnum = [pastedLines objectEnumerator];
    NSArray* line;

    while (line = [lineEnum nextObject]) {
        NSValue* rect = [line objectAtIndex: 0];
        NSRect   lineRect = [rect rectValue];

        lineRect.origin.y -= offset;

        if (NSIntersectsRect(r, lineRect)) {
            NSAttributedString* str = [line objectAtIndex: 1];

            if (NSMaxY(lineRect) < NSMaxY(ourBounds)-superBounds.size.height) {
                // Draw it faded out (so text underneath becomes increasingly visible)
                NSImage* fadeImage;

                double fadeAmount = (NSMaxY(ourBounds)-superBounds.size.height) - NSMaxY(lineRect);
                fadeAmount /= 2048;
                fadeAmount += 0.25;
                if (fadeAmount > 0.75) fadeAmount = 0.75;
                fadeAmount = 1-fadeAmount;
                
                fadeImage = [[NSImage alloc] initWithSize: lineRect.size];

                [fadeImage setSize: lineRect.size];
                [fadeImage lockFocus];
                [str drawAtPoint: NSMakePoint(0,0)];
                [fadeImage unlockFocus];

                [fadeImage compositeToPoint:NSMakePoint(lineRect.origin.x,
                                                        lineRect.origin.y+lineRect.size.height)
                                   fromRect:NSMakeRect(0,0,
                                                       lineRect.size.width,
                                                       lineRect.size.height)
                                  operation:NSCompositeSourceOver
                                   fraction:fadeAmount];

                [fadeImage release];
            } else {
                [str drawAtPoint: lineRect.origin];
            }
        }
    }
}

- (void) clearPastedLines {
    [pastedLines removeAllObjects];
}

- (void) pasteUpperWindowLinesFrom: (ZoomUpperWindow*) win {
    NSArray* lines = [win lines];
    BOOL changed;
    
    if ([lines count] < [win length]) {
        return; // Nothing to do
    }

    // Get some information about the view
    NSView* container = (NSView*)[self superview];

    // The container
    while (![container isKindOfClass: [NSClipView class]]) {
        container = [container superview];
        if (container == nil) break;
    }

    if (container == nil) container = self;

    // The enclosing ZoomView
    NSView* superview = [self superview];

    while (![superview isKindOfClass: [ZoomView class]]) {
        superview = [superview superview];
        if (superview == nil) break;
    }
    ZoomView* zoomView = (ZoomView*) superview;
    
    NSRect ourBounds = [self bounds];
    NSRect containerBounds = [container bounds];

    double offset = [zoomView upperBufferHeight];

    double topPoint = NSMaxY(ourBounds) - containerBounds.size.height;
    
    NSSize fixedSize = [@"M" sizeWithAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [zoomView fontWithStyle:ZFixedStyle], NSFontAttributeName, nil]];
    
    // Perform the pasting
    changed = NO;

    NSRect drawRect = NSZeroRect;
    
    int l;
    for (l=[win length]; l<[lines count]; l++) {
        NSRect r;
        NSAttributedString* str = [lines objectAtIndex: l];

        if ([str length] > 0) {
            r = NSMakeRect(0, topPoint+fixedSize.height*(l-[win length]), 0,0);
            r.origin.y += offset;
            r.size = [str size];

            [pastedLines addObject: [NSArray arrayWithObjects:
                [NSValue valueWithRect: r],
                str,
                nil]];

            r.origin.y -= offset;

            drawRect = NSUnionRect(drawRect, r);
            changed = YES;
        }
    }

    if (changed) {
        // Update the window
        [self setNeedsDisplayInRect: drawRect];
    }

    // Scrub the lines
    [win cutLines];
}

@end