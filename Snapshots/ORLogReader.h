#import <Foundation/Foundation.h>
#import "ORTestsSuiteModels.h"

@interface ORLogReader : NSObject

- (void)readLog:(NSString *)log;

- (NSArray *)uniqueDiffCommands;
- (NSArray *)ksdiffCommands;

- (NSArray *)testSuites;

- (BOOL)hasNewSnapshots;

@property (readonly, nonatomic, assign) BOOL hasCGErrors;

- (BOOL)hasSnapshotTestErrors;
@end
