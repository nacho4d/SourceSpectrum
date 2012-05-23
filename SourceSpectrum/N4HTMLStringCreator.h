//
//  N4HTMLStringCreator.h
//  SourceSpectrum
//
//  Created by Guillermo Enriquez on 5/22/12.
//  Copyright (c) 2012 nacho4d. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>

CFDataRef CreateHTMLDataFromItemAtURL(CFURLRef itemURL, CFBundleRef bundle, CFErrorRef *readingError);

