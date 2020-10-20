//
//  shSubtitleFixerAppDelegate.m
//  shSubtitleFixer
//
//  Created by Shaahin on 5/17/11.
//  Copyright 2011 Shaahin.us. Distributed under GNU General Public License v3.0.
//

#import "shSubtitleFixerAppDelegate.h"
#import "AppSandboxFileAccess.h"

@implementation shSubtitleFixerAppDelegate

@synthesize window;
@synthesize subtitleQueue;
- (void) awakeFromNib
{
    [window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    self.subtitleQueue = [NSMutableArray new];
    
    [shImage setEditable:NO];
    [shImage unregisterDraggedTypes];
    [shImage setImage:[NSImage imageNamed:@"Drop"]];
}

- (void)windowWillClose:(NSNotification *)aNotification {

    // Terminate Application if window closed.
	[NSApp terminate:self];
}

// MARK: - Enable Dragging

-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}

-(BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard* pbrd = [sender draggingPasteboard];
    NSArray *files = [pbrd propertyListForType:NSFilenamesPboardType];

    self.subtitleQueue = [files mutableCopy];

    if(self.subtitleQueue.count > 0) {

        [self loadSubtitleFile:self.subtitleQueue.lastObject];
    }

    return YES;
}

// MARK: - Load Subtitle

- (void) loadSubtitleFile: (NSString *) file
{
    if ([[file pathExtension] isEqualToString:@"srt"]) {

        [shLabel setStringValue:[file lastPathComponent]];
        
        NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        NSString *path = [[self pathForItem:timestamp] stringByExpandingTildeInPath];
        NSError *error = nil;

        [[NSFileManager defaultManager] copyItemAtPath: file toPath: [NSString stringWithFormat:@"%@", path] error:&error];

        [shWebView setCustomTextEncodingName:@"Windows-1256"];

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"file://%@", path]];

        [[shWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];

        [shProgress startAnimation:self];
        [shImage setHidden:YES];

    } else
    {

        [self showInvalidFileAlert];

        [shImage setHidden:NO];
        [shImage setImage:[NSImage imageNamed:@"Drop"]];
    }
}

// MARK: - WebView
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    
    NSString *subtitle= sender.mainFrame.dataSource.representation.documentSource;
    if([subtitle isNotEqualTo:NULL])
    {
        __block NSError *error;
        NSMutableArray *pathes = [[self.subtitleQueue.lastObject pathComponents] mutableCopy];
        [pathes insertObject:@"shFixed" atIndex:pathes.count-1];
        
        NSString *targetFilePath = [NSString pathWithComponents:pathes];
        [pathes removeLastObject];

        AppSandboxFileAccess *fileAccess = [AppSandboxFileAccess fileAccess];

        // get the parent directory for the file
        NSString *parentDirectory = [NSString pathWithComponents:pathes];
        
        // get access to the parent directory
        BOOL accessAllowed = [fileAccess accessFilePath:parentDirectory persistPermission:YES withBlock:^{

            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString pathWithComponents:pathes] withIntermediateDirectories:YES attributes:nil error:&error];

            [subtitle writeToFile:targetFilePath atomically: NO encoding:NSUTF8StringEncoding error:&error];
        }];
        
        if (!accessAllowed) {

            NSLog(@"No access.");
        }

        [self.subtitleQueue removeLastObject];
        if(self.subtitleQueue.count == 0)
        {
            [shProgress stopAnimation:self];
            [shLabel setStringValue:@"Drop your Persian .srt subtitle file here to convert."];
            [shImage setHidden:NO];
            [shImage setImage:[NSImage imageNamed:@"ok"]];

        } else
        {
            [self loadSubtitleFile:self.subtitleQueue.lastObject];
        }
    }
}

// MARK: - Privates

- (void) showInvalidFileAlert {

    NSAlert *theAlert = [[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"];
    [theAlert setMessageText:@"Invalid File Format" ];
    [theAlert setInformativeText:@"only .srt subtitles are accepted!"];
    [theAlert setAlertStyle: 1];
    [theAlert runModal];
}

- (NSString *) pathForItem:(NSString *)file
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sub.temp.%@.txt", file]];
    return path;
}

@end
