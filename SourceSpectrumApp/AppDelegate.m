//
//  AppDelegate.m
//  SourceSpectrum
//
//  Created by Guillermo Enriquez on 5/22/12.
//  Copyright (c) 2012 nacho4d. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>

#import "N4HTMLStringCreator.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize webView = _webView; 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSRect contentViewBounds = [self.window.contentView bounds];
	NSRect renderRect = contentViewBounds;
	float scale = 1; // ?
	NSSize scaleSize = NSMakeSize(scale, scale);

	// Data to render
	NSString *filePath = @"/Users/Ignacio/Desktop/test.js";
	//NSError *error = nil;
	CFBundleRef bundle = (__bridge CFBundleRef)[NSBundle mainBundle];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
	NSString *htmlString = (__bridge NSString *)CreateHTMLDataFromItemAtURL(url, bundle, NULL);
	NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];

	// Make webView
	_webView = [[WebView alloc] initWithFrame:renderRect];
	[_webView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	[_webView scaleUnitSquareToSize:scaleSize];
	[[[_webView mainFrame] frameView] setAllowsScrolling:YES];
	[self.window.contentView addSubview:_webView];

	// Render data
	[[_webView mainFrame] loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];

	while([_webView isLoading]) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
	}
}

@end
