//
//  AppDelegate.h
//  SourceSpectrum
//
//  Created by Guillermo Enriquez on 5/22/12.
//  Copyright (c) 2012 nacho4d. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet WebView *webView;

@end
