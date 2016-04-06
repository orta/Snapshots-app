@interface NSFileManager (ORRecursiveFind)

- (NSString *)or_findFileWithNamePrefix:(NSString *)name inFolder:(NSString *)folder;

@end