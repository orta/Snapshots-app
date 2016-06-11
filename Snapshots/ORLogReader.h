#import <Foundation/Foundation.h>
#import "ORTestsSuiteModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface ORLogReader : NSObject

- (void)readLog:(NSString *)log;

- (NSArray <ORKaleidoscopeCommand *>*)uniqueDiffCommands;
- (NSArray <ORKaleidoscopeCommand *>*)ksdiffCommands;
- (NSArray <ORSnapshotCreationReference *>*)newSnapshots;

- (NSArray <ORTestSuite *>*)testSuites;

- (BOOL)hasNewSnapshots;
- (BOOL)hasCGErrors;
- (BOOL)hasSnapshotTestErrors;
@end

NS_ASSUME_NONNULL_END