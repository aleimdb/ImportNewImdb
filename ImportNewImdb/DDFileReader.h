//
//  DDFileReader.h
//  ImportNewImdb
//
// Dave's DDFileReader from http://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line
//

#import <Foundation/Foundation.h>

@interface DDFileReader : NSObject {
    NSString * filePath;
    
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
    
    NSString * lineDelimiter;
    NSUInteger chunkSize;
    
    NSUInteger nLines;
    
    NSString * prevChunkString;
    NSUInteger offsetInPrevChunkString;
}

//@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger nLines;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLine;

@end
