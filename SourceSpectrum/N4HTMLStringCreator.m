//
//  N4HTMLStringCreator.m
//  SourceSpectrum
//
//  Created by Guillermo Enriquez on 5/22/12.
//  Copyright (c) 2012 nacho4d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "N4HTMLStringCreator.h"

#define KEY_SH_CORE_JS @"___SH_CORE_JS___"
#define KEY_SH_BRUSH_JS @"___SH_BRUSH_JS___"
#define KEY_SH_CORE_CSS @"___SH_CORE_CSS___"
#define KEY_SH_OPTIONS @"___SH_OPTIONS_JS___"
#define KEY_SH_BRUSH_TYPE @"___SH_BRUSH_TYPE___"
#define KEY_SH_CODE @"___SH_CODE___"

#define endIfNil(x) {\
		if (!(x)) {\
			printf("ERROR: Object is nil (%s: %s %d)", __FILE__, __PRETTY_FUNCTION__, __LINE__);\
			return nil;\
		}\
	}
#define endIfNotNoFound(r, e) {\
		if ((r).location == NSNotFound) { \
			printf("ERROR: Invalid range (%s: %s %d)", __FILE__, __PRETTY_FUNCTION__, __LINE__);\
			return nil;\
		}\
	}

NSString *const shPrefix = @"sh.defaults.";

CFDataRef CreateHTMLDataFromItemAtURL(CFURLRef url, CFBundleRef bundle, CFErrorRef *error)
{
	NSError *readingError = (error)?(__bridge NSError *)(*error): nil;
	NSURL *itemURL = (__bridge NSURL *)url;
	NSMutableString *fileContents = [NSMutableString stringWithContentsOfURL:itemURL usedEncoding:NULL error:&readingError];
	endIfNil(fileContents);

	[fileContents replaceOccurrencesOfString:@"&" withString:@"&quot;" options:0 range:NSMakeRange(0, fileContents.length)];
	[fileContents replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, fileContents.length)];
	[fileContents replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, fileContents.length)];
	[fileContents replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, fileContents.length)];
	
	NSURL *_templateHTMLURL = (__bridge_transfer NSURL *)CFBundleCopyResourceURL(bundle, CFSTR("template"), CFSTR("html"), NULL);
	NSMutableString *template = [NSMutableString stringWithContentsOfURL:_templateHTMLURL usedEncoding:NULL error:&readingError];
	endIfNil(template);

	NSURL * _shCoreCssURL = (__bridge_transfer NSURL *)CFBundleCopyResourceURL(bundle, CFSTR("shCoreDefault"), CFSTR("css"), NULL);
	NSString *shCoreCssString = [NSString stringWithContentsOfURL:_shCoreCssURL usedEncoding:NULL error:&readingError];
	endIfNil(shCoreCssString);
	
	NSURL *_shCoreJsURL = (__bridge_transfer NSURL *)CFBundleCopyResourceURL(bundle, CFSTR("shCore"), CFSTR("js"), NULL);
	NSString *shCoreJsString = [NSString stringWithContentsOfURL:_shCoreJsURL usedEncoding:NULL error:&readingError];
	endIfNil(shCoreJsString);
	
	NSString *shBrushString = nil;
	NSString *shBrushType = nil;
	NSString *extension = [itemURL pathExtension];
	if ([extension isEqualToString:@"js"]) {
		NSURL *_jsBrushURL = (__bridge_transfer NSURL *)CFBundleCopyResourceURL(bundle, CFSTR("shBrushJScript"), CFSTR("js"), NULL);
		shBrushString = [NSString stringWithContentsOfURL:_jsBrushURL usedEncoding:NULL error:&readingError];
		shBrushType = @"js";
	//TODO : Handle other extensions/brushes here
	//} else if ([extension isEqualToString:@""]) {
	}
	endIfNil(shBrushString);
	endIfNil(shBrushType);

	NSDictionary *appDefaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSMutableDictionary *shOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  @"false", @"gutter",
									  @"false", @"toolbar",
									  nil];
	for (id key in appDefaults) {
		if ([key isKindOfClass:[NSString class]] && [key hasPrefix:shPrefix]) {
			[shOptions setObject:[appDefaults objectForKey:key] forKey:[key substringFromIndex:shPrefix.length]];
		}
	}
	NSMutableString *shOptionsString = [[NSMutableString alloc] init];
	for (NSString *key in shOptions) {
		[shOptionsString appendFormat:@"SyntaxHighlighter.defaults['%@'] = %@;\n", key, [shOptions objectForKey:key]];
	}
	
	NSRange shOptionsRange = [template rangeOfString:KEY_SH_OPTIONS options:0];
	endIfNotNoFound(shOptionsRange, &readingError);
	[template replaceCharactersInRange:shOptionsRange withString:shOptionsString];
	
	NSRange codeRange = [template rangeOfString:KEY_SH_CODE options:0];
	endIfNotNoFound(codeRange, &readingError);
	[template replaceCharactersInRange:codeRange withString:fileContents];
	
	NSRange codeTypeRange = [template rangeOfString:KEY_SH_BRUSH_TYPE options:0];
	endIfNotNoFound(codeTypeRange, &readingError);
	[template replaceCharactersInRange:codeTypeRange withString:shBrushType];
	
	NSRange shCoreCssRange = [template rangeOfString:KEY_SH_CORE_CSS options:0];
	endIfNotNoFound(shCoreCssRange, &readingError);
	[template replaceCharactersInRange:shCoreCssRange withString:shCoreCssString];
	
	NSRange shBrushJsRange = [template rangeOfString:KEY_SH_BRUSH_JS options:0];
	endIfNotNoFound(shBrushJsRange, &readingError);
	[template replaceCharactersInRange:shBrushJsRange withString:shBrushString];
	
	NSRange shCoreJsRange = [template rangeOfString:KEY_SH_CORE_JS options:0];
	endIfNotNoFound(shCoreJsRange, &readingError);
	[template replaceCharactersInRange:shCoreJsRange withString:shCoreJsString];

	NSData *htmlData = [template dataUsingEncoding:NSUTF8StringEncoding];
	return (__bridge CFDataRef)htmlData;
}
