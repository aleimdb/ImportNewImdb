//
//  DDFileReader.m
//  ImportNewImdb
//
// Dave's DDFileReader from http://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line
//

#import "DDFileReader.h"

//@interface NSData (DDAdditions)
//
//- (NSRange) rangeOfData_dd:(NSData *)dataToFind startFrom:(NSUInteger) startIndex;
//
//@end
//
//@implementation NSData (DDAdditions)
//
//- (NSRange) rangeOfData_dd:(NSData *)dataToFind startFrom:(NSUInteger) startIndex {
//
//    const void * bytes = [self bytes];
//    NSUInteger length = [self length];
//
//    const void * searchBytes = [dataToFind bytes];
//    NSUInteger searchLength = [dataToFind length];
//    NSUInteger searchIndex = startIndex;
//
//    NSRange foundRange = {NSNotFound, searchLength};
//    for (NSUInteger index = startIndex; index < length; index++) {
//        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
//            //the current character matches
//            if (foundRange.location == NSNotFound) {
//                foundRange.location = index;
//            }
//            searchIndex++;
//            if (searchIndex >= searchLength) { return foundRange; }
//        } else {
//            searchIndex = 0;
//            foundRange.location = NSNotFound;
//        }
//    }
//    return foundRange;
//}
//
//@end

@implementation NSString (SSToolkitAdditions)

#pragma mark Trimming Methods

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end

@implementation DDFileReader
@synthesize nLines;
//@synthesize lineDelimiter, chunkSize;

-(NSUInteger) getLines:(NSString *)aPath {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    [task setLaunchPath:@"/usr/bin/wc"];
    [task setArguments:[NSArray arrayWithObjects:@"-l", aPath, nil]];
    [task setStandardOutput:pipe];
    [task setStandardInput:[NSPipe pipe]];

    [task launch];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];

    NSString *wcOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    wcOutput = [wcOutput stringByTrimmingLeadingWhitespaceAndNewlineCharacters];
    
    NSRange ran = [wcOutput rangeOfString:@" " options:NSLiteralSearch];
    wcOutput = [wcOutput substringWithRange:NSMakeRange(0, ran.location)];
    
    NSUInteger nLines = [wcOutput longLongValue];
    
    //NSLog (@"%@", nLines);
    return nLines;
    
}

- (id) initWithFilePath:(NSString *)aPath {
    if (self = [super init]) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (fileHandle == nil) {
            NSLog(@"No file at path: %@", aPath);
            return nil;
        }
        
        lineDelimiter = @"\n";
        currentOffset = 0ULL;
        chunkSize = 1024000ULL;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];
        //we don't need to seek back, since readLine will do that.
        nLines = [self getLines:aPath];
        NSLog(@"%@ - totalFileLength: %llu - nLines: %lu", aPath, totalFileLength, nLines);
        
        [fileHandle seekToFileOffset:currentOffset];
        @autoreleasepool {
            NSData* prevChunk = [fileHandle readDataOfLength:chunkSize];
            prevChunkString = [[NSString alloc] initWithData:prevChunk encoding:NSUTF8StringEncoding];
            currentOffset += [prevChunk length];
            offsetInPrevChunkString = 0ULL;
        }
    }
    return self;
}

- (void) dealloc {
    NSLog(@"called dealloc");
    [fileHandle closeFile];
    currentOffset = 0ULL;
}

- (NSString *) readLine {
    
    NSString * line = @"";
    
    //NSData * newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
        
    NSRange newLineRange = [prevChunkString rangeOfString:lineDelimiter options:NSLiteralSearch range:NSMakeRange(offsetInPrevChunkString,[prevChunkString length]-offsetInPrevChunkString) ];
    
    if (newLineRange.location != NSNotFound) {
        line = [prevChunkString substringWithRange:NSMakeRange(offsetInPrevChunkString,newLineRange.location - offsetInPrevChunkString + [lineDelimiter length]) ];
        offsetInPrevChunkString = newLineRange.location + [lineDelimiter length];
    } else {
        if (currentOffset >= totalFileLength) { return nil; }
        
        NSString* prevChunkRemainString = [prevChunkString substringWithRange:NSMakeRange(offsetInPrevChunkString,[prevChunkString length]-offsetInPrevChunkString)];
        
        [fileHandle seekToFileOffset:currentOffset];
        NSString* newChunkString;
        @autoreleasepool {
            NSData * newChunk = [fileHandle readDataOfLength:chunkSize];
            currentOffset += [newChunk length];
            
            newChunkString = [[NSString alloc] initWithData:newChunk encoding:NSUTF8StringEncoding];
            if(newChunkString==nil) {
                newChunkString = [[NSString alloc] initWithData:newChunk encoding:NSISOLatin1StringEncoding];
            }
        }
        prevChunkString = [prevChunkRemainString stringByAppendingString:newChunkString];
        offsetInPrevChunkString = 0ULL;

//        [prevChunkRemain appendData:newChunk];
//        prevChunk = prevChunkRemain;
//        prevChunkString = [[NSString alloc] initWithData:prevChunk encoding:NSUTF8StringEncoding];
        
        newLineRange = [prevChunkString rangeOfString:lineDelimiter options:NSLiteralSearch range:NSMakeRange(offsetInPrevChunkString,[prevChunkString length]-offsetInPrevChunkString) ];
        
        if (newLineRange.location != NSNotFound) {
            line = [prevChunkString substringWithRange:NSMakeRange(offsetInPrevChunkString,newLineRange.location - offsetInPrevChunkString + [lineDelimiter length]) ];
            offsetInPrevChunkString = newLineRange.location + [lineDelimiter length];
        } else {
            NSLog(@"error");
        }
    }
    
    return line;
}


@end
