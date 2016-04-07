@import Cocoa;

@interface ORSlidingImageView : NSView

@property (nonatomic, strong) NSImage *frontImage;
@property (nonatomic, strong) NSImage *backImage;

@property (readwrite, nonatomic, strong) NSString *frontMessage;
@property (readwrite, nonatomic, strong) NSString *backMessage;

@end
