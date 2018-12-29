//
//  Movie.h
//  myimdb
//
//  Created by Alessandro on 09/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Movie : NSObject {

}

+ (void) createDb;
+ (void) insertMovieWithTconst:(NSString*)tconst titleType:(NSString*)titleType primaryTitle:(NSString*)primaryTitle originalTitle:(NSString*)originalTitle isAdult:(NSString*)isAdult startYear:(NSString*)startYear endYear:(NSString*)endYear runtimeMinutes:(NSString*)runtimeMinutes genres:(NSString*)genres;

+ (void) insertAkaMovieWithTconst:(NSString*)tconst ordering:(NSString*)ordering title:(NSString*)title region:(NSString*)region language:(NSString*)language types:(NSString*)types attributes:(NSString*)attributes isOriginalTitle:(NSString*)isOriginalTitle;

+ (void) insertMovieRatingWithTconst:(NSString*)tconst averageRating:(NSString*)averageRating numVotes:(NSString*)numVotes;

+ (void) insertMovieEpisodeWithTconst:(NSString*)tconst parentTconst:(NSString*)parentTconst seasonNumber:(NSString*)seasonNumber episodeNumber:(NSString*)episodeNumber;

+ (void) insertNameWithNconst:(NSString*)nconst primaryName:(NSString*)primaryName birthYear:(NSString*)birthYear deathYear:(NSString*)deathYear primaryProfession:(NSString*)primaryProfession;

+ (void) insertCharacterWithNconst:(NSString*)nconst tconst:(NSString*)tconst ttype:(NSString*)ttype position:(NSInteger) position category:(NSString*)category job:(NSString*)job characters:(NSString*)characters;

+ (void) importAwards;
+ (void) closeDb;
+ (void) begin;
+ (void) commit;
+ (void) createIdxChar_final;
+ (void) createLocalTables;
+ (void) printChar;

@end
