//
//  shSubtitleFixerAppDelegate.h
//  shSubtitleFixer
//
//  Created by Shaahin on 5/17/11.
//  Copyright 2011 Shaahin.us. Distributed under GNU General Public License v3.0.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <AppKit/AppKit.h>
@interface shSubtitleFixerAppDelegate : NSViewController <NSApplicationDelegate, NSDraggingDestination> {
@private
    NSMutableArray *subtitleQueue;
    IBOutlet WebView *shWebView;
    IBOutlet NSTextField *shLabel;
    IBOutlet NSProgressIndicator *shProgress;
    IBOutlet NSImageView *shImage;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSMutableArray *subtitleQueue;

@end
