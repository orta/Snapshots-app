#import "ORKaleidoscopeController.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation ORKaleidoscopeController

+ (BOOL)isInstalled
{
    //  If no application could be found,
    // *    NULL is returned and outError (if not NULL) is populated with kLSApplicationNotFoundErr.

    CFErrorRef error = NULL;
    CFArrayRef result = LSCopyApplicationURLsForBundleIdentifier (CFSTR("com.blackpixel.kaleidoscope"), &error );
    if (result) {  CFRelease(result); }
    return error != nil;
}

@end
