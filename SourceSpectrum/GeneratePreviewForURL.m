#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import "N4HTMLStringCreator.h"

// Prototypes
OSStatus GeneratePreviewForURL(void *thisInterface,
							   QLPreviewRequestRef preview,
							   CFURLRef url,
							   CFStringRef contentTypeUTI,
							   CFDictionaryRef options);

void CancelPreviewGeneration(void *thisInterface,
							 QLPreviewRequestRef preview);

// Definitions
OSStatus GeneratePreviewForURL(void *thisInterface,
							   QLPreviewRequestRef preview,
							   CFURLRef url,
							   CFStringRef contentTypeUTI,
							   CFDictionaryRef options)
{
	CFBundleRef bundle = QLPreviewRequestGetGeneratorBundle(preview);
	CFDataRef htmlData = CreateHTMLDataFromItemAtURL(url, bundle, NULL);
	if (htmlData) {
		QLPreviewRequestSetDataRepresentation(preview, htmlData, kUTTypeHTML, NULL);
		CFRelease(htmlData);
		return noErr;
	} else {
		return -1;
	}
}

void CancelPreviewGeneration(void *thisInterface,
							 QLPreviewRequestRef preview)
{
	// Implement only if supported
}
