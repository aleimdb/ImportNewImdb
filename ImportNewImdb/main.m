//
//  main.m
//  ImportNewImdb
//
//  Created by Alessandro Meroni on 08/08/17.
//  Copyright © 2017 Alessandro Meroni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFileReader.h"
#import "Movie.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        if(argc != 2) {
            NSLog(@"usage: importNewImdb path_to_folder");
            return 1;
        }
        NSString* path = [NSString stringWithUTF8String:argv[1]];
        
        [Movie createDb];
        
        //tconst	titleType	primaryTitle	originalTitle	isAdult	startYear	endYear	runtimeMinutes	genres
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.basics.tsv"]];
            long l = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=9)
                        [Movie insertMovieWithTconst:arr[0] titleType:arr[1] primaryTitle:arr[2] originalTitle:arr[3] isAdult:arr[4] startYear:arr[5] endYear:arr[6] runtimeMinutes:arr[7] genres:arr[8]];
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld", l);
                    [Movie commit];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld", l);
            [Movie commit];
        }
        
        //titleId    ordering    title    region    language    types    attributes    isOriginalTitle
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.akas.tsv"]];
            long l = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=8)
                        [Movie insertAkaMovieWithTconst:arr[0] ordering:arr[1] title:arr[2] region:arr[3] language:arr[4] types:arr[5] attributes:arr[6] isOriginalTitle:arr[7]];
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld", l);
                    [Movie commit];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld", l);
            [Movie commit];
        }
        
        //tconst	averageRating	numVotes
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.ratings.tsv"]];
            long l = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=3)
                        [Movie insertMovieRatingWithTconst:arr[0] averageRating:arr[1] numVotes:arr[2]];
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld", l);
                    [Movie commit];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld", l);
            [Movie commit];
        }
        
        //tconst	parentTconst	seasonNumber	episodeNumber
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.episode.tsv"]];
            long l = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=4)
                        [Movie insertMovieEpisodeWithTconst:arr[0] parentTconst:arr[1] seasonNumber:arr[2] episodeNumber:arr[3]];
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld", l);
                    [Movie commit];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld", l);
            [Movie commit];
        }
        
        //tconst	principalCast
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.principals.tsv"]];
            long l = 0;
            long skip = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=2){
                        NSArray *arr2 = [arr[1] componentsSeparatedByCharactersInSet:
                                        [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
                        NSInteger loc = 0;
                        for (NSString* arrstr in arr2) {
                            if(arrstr.length==0 || [arrstr isEqualToString:@"\\N"]){
                                skip++;
                            } else {
                                loc++;
                                [Movie insertCharacterWithNconst:arrstr tconst:arr[0] ttype:@"p" position:loc];
                            }
                        }
                    }
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld - skip:%ld", l, skip);
                    [Movie commit];
                    //[Movie printChar];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld - skip:%ld", l, skip);
            [Movie commit];
            [Movie printChar];
        }
        
        //tconst	directors	writers
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.crew.tsv"]];
            long l = 0;
            long skipd = 0;
            long skipw = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=3){
                        NSArray *arr2 = [arr[1] componentsSeparatedByCharactersInSet:
                                         [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
                        NSInteger locd = 0;
                        for (NSString* arrstr in arr2) {
                            if(arrstr.length==0 || [arrstr isEqualToString:@"\\N"]){
                                skipd++;
                            } else {
                                locd++;
                                [Movie insertCharacterWithNconst:arrstr tconst:arr[0] ttype:@"d" position:locd];
                            }
                        }
                        NSArray *arr3 = [arr[2] componentsSeparatedByCharactersInSet:
                                         [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
                        NSInteger locw = 0;
                        for (NSString* arrstr in arr3) {
                            if(arrstr.length==0 || [arrstr isEqualToString:@"\\N"]){
                                skipw++;
                            } else {
                                locw++;
                                [Movie insertCharacterWithNconst:arrstr tconst:arr[0] ttype:@"w" position:locw];
                            }
                        }
                    }
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld - skipped d: %ld - skipped w: %ld", l, skipd, skipw);
                    [Movie commit];
                    //[Movie printChar];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld - skipped d: %ld - skipped w: %ld", l, skipd, skipw);
            [Movie commit];
            [Movie printChar];
        }
        
        
        //nconst	primaryName	birthYear	deathYear	primaryProfession	knownForTitles
        @autoreleasepool {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/name.basics.tsv"]];
            long l = 0;
            long skip = 0;
            NSString * line = nil;
            [Movie begin];
            while ((line = [reader readLine])) {
                l++;
                if (l==1) {
                    NSLog(@"header: %@", line);
                    continue;
                }
                @autoreleasepool {
                    NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                    
                    if(arr.count>=6) {
                        [Movie insertNameWithNconst:arr[0] primaryName:arr[1] birthYear:arr[2] deathYear:arr[3] primaryProfession:arr[4]];
                        NSArray *arr2 = [arr[5] componentsSeparatedByCharactersInSet:
                                         [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
                        NSInteger loc = 0;
                        for (NSString* arrstr in arr2) {
                            if(arrstr.length==0 || [arrstr isEqualToString:@"\\N"]){
                                skip++;
                            } else {
                                loc++;
                                [Movie insertCharacterWithNconst:arr[0] tconst:arrstr ttype:@"k" position:loc];
                            }
                        }
                    }
                    else
                        NSLog(@"discarded: %@",line);
                }
                if (l % 1000000ULL == 0) {
                    NSLog(@"read line: %ld - skip: %ld", l, skip);
                    [Movie commit];
                    //[Movie printChar];
                    [Movie begin];
                }
            }
            NSLog(@"read line: %ld - skip: %ld", l, skip);
            [Movie commit];
            [Movie printChar];
        }
        //[Movie createIdxChar_tmp];
        
        [Movie createIdxChar_final];
        
        [Movie createLocalTables];
        
        [Movie closeDb];
    }
    return 0;
}