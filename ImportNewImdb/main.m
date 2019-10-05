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
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"tconst\ttitleType\tprimaryTitle\toriginalTitle\tisAdult\tstartYear\tendYear\truntimeMinutes\tgenres\n"]) {
                    NSLog(@"wrong format - not: tconst\ttitleType\tprimaryTitle\toriginalTitle\tisAdult\tstartYear\tendYear\truntimeMinutes\tgenres");
                    exit(-1);
                }
                continue;
            }
            //NSLog(@"read line: %ld %@", l, line);
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=9)
                    [movie insertMovieWithTconst:arr[0] titleType:arr[1] primaryTitle:arr[2] originalTitle:arr[3] isAdult:arr[4] startYear:arr[5] endYear:arr[6] runtimeMinutes:arr[7] genres:arr[8]];
                else
                    NSLog(@"discarded line: %ld %@",l, line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld", l, [reader nLines]);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld ", l);
        [movie commit];
        [movie closeDb];
    }
        
    //titleId    ordering    title    region    language    types    attributes    isOriginalTitle
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.akas.tsv"]];
        long l = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"titleId\tordering\ttitle\tregion\tlanguage\ttypes\tattributes\tisOriginalTitle\n"]) {
                    NSLog(@"wrong format: - not titleId\tordering\ttitle\tregion\tlanguage\ttypes\tattributes\tisOriginalTitle");
                    exit(-1);
                }
                continue;
            }
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=8)
                    [movie insertAkaMovieWithTconst:arr[0] ordering:arr[1] title:arr[2] region:arr[3] language:arr[4] types:arr[5] attributes:arr[6] isOriginalTitle:arr[7]];
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld", l, [reader nLines]);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld", l);
        [movie commit];
        [movie closeDb];
    }
        
    //tconst	averageRating	numVotes
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.ratings.tsv"]];
        long l = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"tconst\taverageRating\tnumVotes\n"]) {
                    NSLog(@"wrong format - not: tconst\taverageRating\tnumVotes");
                    exit(-1);
                }
                continue;
            }
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=3)
                    [movie insertMovieRatingWithTconst:arr[0] averageRating:arr[1] numVotes:arr[2]];
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld", l, [reader nLines]);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld", l);
        [movie commit];
        [movie closeDb];
    }
        
    //tconst	parentTconst	seasonNumber	episodeNumber
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.episode.tsv"]];
        long l = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"tconst\tparentTconst\tseasonNumber\tepisodeNumber\n"]) {
                    NSLog(@"wrong format - not tconst\tparentTconst\tseasonNumber\tepisodeNumber");
                    exit(-1);
                }
                continue;
            }
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=4)
                    [movie insertMovieEpisodeWithTconst:arr[0] parentTconst:arr[1] seasonNumber:arr[2] episodeNumber:arr[3]];
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld", l, [reader nLines]);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld", l);
        [movie commit];
        [movie closeDb];
    }
        
    //tconst    ordering    nconst    category    job    characters
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.principals.tsv"]];
        long l = 0;
        long skip = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"tconst\tordering\tnconst\tcategory\tjob\tcharacters\n"]) {
                    NSLog(@"wrong format - not: tconst\tordering\tnconst\tcategory\tjob\tcharacters");
                    exit(-1);
                }
                continue;
            }
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=6){
                    [movie insertCharacterWithNconst:arr[2]
                                              tconst:arr[0]
                                               ttype:@"p"
                                            position:[arr[1] integerValue]
                                            category:arr[3]
                                                 job:arr[4]
                                          characters:arr[5]];
                    
                }
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld - skip:%ld", l, [reader nLines], skip);
                [movie commit];
                //[Movie printChar];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld - skip:%ld", l, skip);
        [movie commit];
        [movie closeDb];
    }
        
    //tconst	directors	writers
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/title.crew.tsv"]];
        long l = 0;
        long skipd = 0;
        long skipw = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"tconst\tdirectors\twriters\n"]) {
                    NSLog(@"wrong format - not tconst\tdirectors\twriters");
                    exit(-1);
                }
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
                            [movie insertCharacterWithNconst:arrstr
                                                      tconst:arr[0]
                                                       ttype:@"d"
                                                    position:locd
                                                    category:@"director"
                                                         job:@"\\N"
                                                  characters:@"\\N"];
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
                            [movie insertCharacterWithNconst:arrstr
                                                      tconst:arr[0]
                                                       ttype:@"w"
                                                    position:locw
                                                    category:@"writer"
                                                         job:@"\\N"
                                                  characters:@"\\N"];
                        }
                    }
                }
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld - skipped d: %ld - skipped w: %ld", l, [reader nLines], skipd,skipw);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld - skipped d: %ld - skipped w: %ld", l, skipd, skipw);
        [movie commit];
        [movie printChar];
        [movie closeDb];
    }
    
    //nconst	primaryName	birthYear	deathYear	primaryProfession	knownForTitles
    @autoreleasepool {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:[path stringByAppendingString:@"/name.basics.tsv"]];
        long l = 0;
        long skip = 0;
        NSString * line = nil;
        Movie* movie = [[Movie alloc] init];
        [movie begin];
        while ((line = [reader readLine])) {
            l++;
            if (l==1) {
                NSLog(@"header: %@", line);
                if (![line isEqualToString:@"nconst\tprimaryName\tbirthYear\tdeathYear\tprimaryProfession\tknownForTitles\n"]) {
                    NSLog(@"wrong format - not nconst\tprimaryName\tbirthYear\tdeathYear\tprimaryProfession\tknownForTitles");
                    exit(-1);
                }
                continue;
            }
            @autoreleasepool {
                NSArray *arr = [line componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
                
                if(arr.count>=6) {
                    [movie insertNameWithNconst:arr[0] primaryName:arr[1] birthYear:arr[2] deathYear:arr[3] primaryProfession:arr[4]];
                    NSArray *arr2 = [arr[5] componentsSeparatedByCharactersInSet:
                                     [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
                    NSInteger loc = 0;
                    for (NSString* arrstr in arr2) {
                        if(arrstr.length==0 || [arrstr isEqualToString:@"\\N"]){
                            skip++;
                        } else {
                            loc++;
                            [movie insertCharacterWithNconst:arr[0]
                                                      tconst:arrstr
                                                       ttype:@"k"
                                                    position:loc
                                                    category:@"\\N"
                                                         job:@"\\N"
                                                  characters:@"\\N"];
                        }
                    }
                }
                else
                    NSLog(@"discarded: %@",line);
            }
            if (l % 1000000ULL == 0) {
                NSLog(@"read line: %ld of %ld - skip: %ld", l, [reader nLines], skip);
                [movie commit];
                [movie begin];
            }
        }
        NSLog(@"read line: %ld - skip: %ld", l, skip);
        [movie commit];
        [movie printChar];
        [movie closeDb];
    }
    
    @autoreleasepool {
        Movie* movie = [[Movie alloc] init];
        [movie importAwards];
        [movie createIdxChar_final];
        [movie createLocalTables];
        [movie closeDb];
    }
    return 0;
}
