//
//  Movie.m
//  myimdb
//
//  Created by Alessandro on 09/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Movie.h"
#import <sqlite3.h>

@implementation Movie

static sqlite3 *databaseLocal = nil;

static sqlite3_stmt *addStmtMovie = nil;
static sqlite3_stmt *addStmtAkaMovie = nil;
static sqlite3_stmt *addStmtMovieRating = nil;
static sqlite3_stmt *addStmtMovieEpisode = nil;
static sqlite3_stmt *addStmtName = nil;
static sqlite3_stmt *addStmtChar = nil;

static int countChar = 0;
static int countCharFailed = 0;



+ (void) createDb {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString* newDbName = [documentsDirectory stringByAppendingString:@"/new.sqlite"];
    NSLog(@"db path: %@", newDbName);
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *writeError = nil;
    if( [manager fileExistsAtPath:newDbName] )
    {
        [manager removeItemAtPath:newDbName error:&writeError];
    }
    
    if (sqlite3_open([newDbName UTF8String], &databaseLocal) != SQLITE_OK) {
        sqlite3_close(databaseLocal); //Even though the open call failed, close the database connection to release all the memory.
        
        NSAssert1(0, @"Error creating db. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementMovie = "CREATE TABLE movies(tconst varchar(30), titleType varchar(30), primaryTitle varchar(255), originalTitle varchar(255), isAdult varchar(1), startYear varchar(4), endYear varchar(4), runtimeMinutes varchar(4), genres  varchar(255))";
    char *error;
    if (sqlite3_exec(databaseLocal, sqlStatementMovie, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating movies. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementAkaMovie = "CREATE TABLE akamovies(titleId varchar(30), ordering varchar(30), title varchar(255), region varchar(255), language varchar(30), types varchar(30), attributes varchar(30), isOriginalTitle  varchar(1))";
    if (sqlite3_exec(databaseLocal, sqlStatementAkaMovie, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating akamovies. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementName = "CREATE TABLE names(nconst varchar(30), primaryName varchar(255), birthYear varchar(4), deathYear varchar(4), primaryProfession varchar(255))";
    if (sqlite3_exec(databaseLocal, sqlStatementName, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating names. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementChar = "CREATE TABLE characters(nconst varchar(30), tconst varchar(30), ttype varchar(1), position integer, category varchar(30), job varchar(255), characters varchar(255))";
    if (sqlite3_exec(databaseLocal, sqlStatementChar, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating characters. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementRatings = "CREATE TABLE ratings(tconst varchar(30), averageRating varchar(5), numVotes varchar(15))";
    if (sqlite3_exec(databaseLocal, sqlStatementRatings, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating ratings. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementEpisodes = "CREATE TABLE episodes(tconst varchar(30), parentTconst varchar(30), seasonNumber varchar(10), episodeNumber varchar(10))";
    if (sqlite3_exec(databaseLocal, sqlStatementEpisodes, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating episodes. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementAwards = "CREATE TABLE awards(eventEditionId varchar(50), eventName varchar(100), eventYear varchar(10), awardName varchar(255), categoryName varchar(255), name varchar(255), tconst varchar(30), winner varchar(4), prisec varchar(4), notes varchar(1024), ref varchar(30))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating awards. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    


}

+ (void) createIdxChar_final {
    
    char *error;
    
    const char *sqlStatementIdx1 = "CREATE INDEX idx_char_nconst on characters(nconst)";
    NSLog(@"%s",sqlStatementIdx1);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx2 = "CREATE INDEX idx_char_tconst on characters(tconst)";
    NSLog(@"%s",sqlStatementIdx2);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3 = "CREATE INDEX idx_epi_tconst on episodes(tconst)";
    NSLog(@"%s",sqlStatementIdx3);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3b = "CREATE INDEX idx_epi_ptconst on episodes(parenttconst)";
    NSLog(@"%s",sqlStatementIdx3b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx4 = "CREATE INDEX idx_movies_tconst on movies(tconst)";
    NSLog(@"%s",sqlStatementIdx4);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx4b = "CREATE INDEX idx_akamovies_titleId on akamovies(titleId)";
    NSLog(@"%s",sqlStatementIdx4b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx4b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }

    
    const char *sqlStatementIdx5 = "CREATE INDEX idx_names_nconst on names(nconst)";
    NSLog(@"%s",sqlStatementIdx5);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx6 = "CREATE INDEX idx_ratings_tconst on ratings(tconst)";
    NSLog(@"%s",sqlStatementIdx6);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx6, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx7 = "CREATE INDEX idx_awards_tconst on awards(tconst)";
    NSLog(@"%s",sqlStatementIdx7);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx7, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx8 = "CREATE INDEX idx_awards_tconst on awards(ref)";
    NSLog(@"%s",sqlStatementIdx8);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx8, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
}

+ (void) createLocalTables {
    
    char *error;
    
    const char *sqlStatementIdx1 = "CREATE TABLE mmovies ( whereis varchar(50), seen varchar(1), itatitle varchar(255), notes varchar(50), type varchar(10), myvote integer, myid INTEGER PRIMARY KEY AUTOINCREMENT, updatedby varchar(255), title_imdb varchar(255), date_imdb varchar(30), tconst varchar(30) )";
    NSLog(@"%s",sqlStatementIdx1);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx2 = "CREATE INDEX mmidx_mmovies_tconst on mmovies(tconst)";
    NSLog(@"%s",sqlStatementIdx2);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3 = "CREATE TABLE mm_dates ( date_type varchar(100), date DATETIME, location varchar(255), notes varchar(255), channel varchar(45), price float, source varchar(45), updatedby varchar(255), tconst varchar(30), datepk INTEGER PRIMARY KEY AUTOINCREMENT )";
    NSLog(@"%s",sqlStatementIdx3);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3b = "CREATE INDEX mmidx_mm_dates_tconst on mm_dates(tconst)";
    NSLog(@"%s",sqlStatementIdx3b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx4 = "CREATE TABLE mm_epi_dates ( date_type varchar(100), date DATETIME, updatedby varchar(255), parenttconst varchar(30), tconst varchar(30), datepk INTEGER PRIMARY KEY AUTOINCREMENT , seasonNumber varchar(10), episodeNumber varchar(10))";
    NSLog(@"%s",sqlStatementIdx4);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx5 = "CREATE INDEX mmidx_epi_parenttconst on mm_epi_dates(parenttconst)";
    NSLog(@"%s",sqlStatementIdx5);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx6 = "CREATE INDEX mmidx_epi_tconst on mm_epi_dates(tconst)";
    NSLog(@"%s",sqlStatementIdx6);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx6, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx7 = "CREATE TABLE mstats ( stat varchar(255) )";
    NSLog(@"%s",sqlStatementIdx7);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx7, NULL, NULL, &error) != SQLITE_OK)
    {
        NSAssert1(0, @"Error creating mmovies_local7. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    sqlite3_stmt *statsStmt = nil;
    
    char *insertSQLMovie = "INSERT INTO mstats(stat) VALUES (?)";
    if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &statsStmt, NULL) != SQLITE_OK)
        NSAssert1(0, @"Error while creating stats statement. '%s'", sqlite3_errmsg(databaseLocal));
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    sqlite3_bind_text(statsStmt,1,[[dateFormatter stringFromDate:[NSDate date]] UTF8String],-1,SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(statsStmt)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(statsStmt);
}

+(void) bindString:(NSString*)myString statement:(sqlite3_stmt*)statement position:(int)position{
    if (myString && ![myString isEqualToString:@"\\N"])
        sqlite3_bind_text(statement,position,[myString UTF8String],-1,SQLITE_TRANSIENT);
    else
        sqlite3_bind_text(statement,position,[@"" UTF8String],-1,SQLITE_TRANSIENT);
        //sqlite3_bind_null(statement,position);
}

//tconst	titleType	primaryTitle	originalTitle	isAdult	startYear	endYear	runtimeMinutes	genres
+ (void) insertMovieWithTconst:(NSString*)tconst titleType:(NSString*)titleType primaryTitle:(NSString*)primaryTitle originalTitle:(NSString*)originalTitle isAdult:(NSString*)isAdult startYear:(NSString*)startYear endYear:(NSString*)endYear runtimeMinutes:(NSString*)runtimeMinutes genres:(NSString*)genres {
    if(addStmtMovie == nil) {
        char *insertSQLMovie = "INSERT INTO movies(tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres) VALUES (?,?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovie, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:tconst statement:addStmtMovie position:1];
    [Movie bindString:titleType statement:addStmtMovie position:2];
    [Movie bindString:primaryTitle statement:addStmtMovie position:3];
    [Movie bindString:originalTitle statement:addStmtMovie position:4];
    [Movie bindString:isAdult statement:addStmtMovie position:5];
    [Movie bindString:startYear statement:addStmtMovie position:6];
    [Movie bindString:endYear statement:addStmtMovie position:7];
    [Movie bindString:runtimeMinutes statement:addStmtMovie position:8];
    [Movie bindString:genres statement:addStmtMovie position:9];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovie)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovie);
}

//titleId    ordering    title    region    language    types    attributes    isOriginalTitle
+ (void) insertAkaMovieWithTconst:(NSString*)tconst ordering:(NSString*)ordering title:(NSString*)title region:(NSString*)region language:(NSString*)language types:(NSString*)types attributes:(NSString*)attributes isOriginalTitle:(NSString*)isOriginalTitle{
    if(addStmtAkaMovie == nil) {
        char *insertSQLMovie = "INSERT INTO akamovies(titleId, ordering, title, region, language, types, attributes, isOriginalTitle) VALUES (?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovie, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:tconst statement:addStmtMovie position:1];
    [Movie bindString:ordering statement:addStmtMovie position:2];
    [Movie bindString:title statement:addStmtMovie position:3];
    [Movie bindString:region statement:addStmtMovie position:4];
    [Movie bindString:language statement:addStmtMovie position:5];
    [Movie bindString:types statement:addStmtMovie position:6];
    [Movie bindString:attributes statement:addStmtMovie position:7];
    [Movie bindString:isOriginalTitle statement:addStmtMovie position:8];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovie)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovie);
}

//tconst	averageRating	numVotes
+ (void) insertMovieRatingWithTconst:(NSString*)tconst averageRating:(NSString*)averageRating numVotes:(NSString*)numVotes {
    if(addStmtMovieRating == nil) {
        char *insertSQLMovieRating = "INSERT INTO ratings(tconst, averageRating, numVotes) VALUES (?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovieRating, -1, &addStmtMovieRating, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:tconst statement:addStmtMovieRating position:1];
    [Movie bindString:averageRating statement:addStmtMovieRating position:2];
    [Movie bindString:numVotes statement:addStmtMovieRating position:3];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovieRating)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovieRating);
}

//tconst	parentTconst	seasonNumber	episodeNumber
+ (void) insertMovieEpisodeWithTconst:(NSString*)tconst parentTconst:(NSString*)parentTconst seasonNumber:(NSString*)seasonNumber episodeNumber:(NSString*)episodeNumber {
    if(addStmtMovieEpisode == nil) {
        char *insertSQLMovieEpisode = "INSERT INTO episodes(tconst, parentTconst, seasonNumber, episodeNumber) VALUES (?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovieEpisode, -1, &addStmtMovieEpisode, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:tconst statement:addStmtMovieEpisode position:1];
    [Movie bindString:parentTconst statement:addStmtMovieEpisode position:2];
    [Movie bindString:seasonNumber statement:addStmtMovieEpisode position:3];
    [Movie bindString:episodeNumber statement:addStmtMovieEpisode position:4];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovieEpisode)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovieEpisode);
}

//nconst	primaryName	birthYear	deathYear	primaryProfession//	knownForTitles
+ (void) insertNameWithNconst:(NSString*)nconst primaryName:(NSString*)primaryName birthYear:(NSString*)birthYear deathYear:(NSString*)deathYear primaryProfession:(NSString*)primaryProfession {
    if(addStmtName == nil) {
        char *insertSQLName = "INSERT INTO names(nconst, primaryName, birthYear, deathYear, primaryProfession) VALUES (?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLName, -1, &addStmtName, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:nconst statement:addStmtName position:1];
    [Movie bindString:primaryName statement:addStmtName position:2];
    [Movie bindString:birthYear statement:addStmtName position:3];
    [Movie bindString:deathYear statement:addStmtName position:4];
    [Movie bindString:primaryProfession statement:addStmtName position:5];
    
    if(SQLITE_DONE != sqlite3_step(addStmtName)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtName);
    
}

+ (void) insertCharacterWithNconst:(NSString*)nconst tconst:(NSString*)tconst ttype:(NSString*)ttype position:(NSInteger) position category:(NSString*)category job:(NSString*)job characters:(NSString*)characters{
    if(addStmtChar == nil) {
        char *insertSQLChar = "INSERT INTO characters(nconst, tconst, ttype, position, category, job, characters) VALUES (?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLChar, -1, &addStmtChar, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [Movie bindString:nconst statement:addStmtChar position:1];
    [Movie bindString:tconst statement:addStmtChar position:2];
    [Movie bindString:ttype statement:addStmtChar position:3];
    sqlite3_bind_int (addStmtChar, 4, (int)position);
    [Movie bindString:category statement:addStmtChar position:5];
    [Movie bindString:job statement:addStmtChar position:6];
    [Movie bindString:characters statement:addStmtChar position:7];
    
    if(SQLITE_DONE != sqlite3_step(addStmtChar)) {
        //NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
        countCharFailed++;
    } else {
        countChar++;
    }
    sqlite3_reset(addStmtChar);
    
}


+ (void) importAwards {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString* newDbName = [documentsDirectory stringByAppendingString:@"/aw.sqlite"];
    NSLog(@"db path: %@", newDbName);
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if( ![manager fileExistsAtPath:newDbName] )
    {
        NSLog(@"no awards db");
        return;
    }
    
    sqlite3 *databaseAwards = nil;
    
    if (sqlite3_open([newDbName UTF8String], &databaseAwards) != SQLITE_OK) {
        sqlite3_close(databaseAwards); //Even though the open call failed, close the database connection to release all the memory.
        NSAssert1(0, @"Error creating awards db. '%s'", sqlite3_errmsg(databaseLocal));
    }
    //eventName, eventYear, awardName, categoryName, name, tconst, winner, prisec, notes, ref, eventEditionId
    const char *sql1 = "select ifnull(eventName,''), ifnull(eventYear,''), ifnull(awardName,''), ifnull(categoryName,''), ifnull(name,''), ifnull(tconst,''), ifnull(winner,''), ifnull(prisec,''), ifnull(notes,''), ifnull(ref,''), ifnull(eventEditionId,'') from awards";
    
    sqlite3_stmt *selectstmt;
    if(sqlite3_prepare_v2(databaseAwards, sql1, -1, &selectstmt, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awards(eventName, eventYear, awardName, categoryName, name, tconst, winner, prisec, notes, ref, eventEditionId) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovie, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt) == SQLITE_ROW) {
            
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] statement:addStmtMovie position:1];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)] statement:addStmtMovie position:2];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)] statement:addStmtMovie position:3];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)] statement:addStmtMovie position:4];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)] statement:addStmtMovie position:5];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] statement:addStmtMovie position:6];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 6)] statement:addStmtMovie position:7];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 7)] statement:addStmtMovie position:8];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 8)] statement:addStmtMovie position:9];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 9)] statement:addStmtMovie position:10];
            [Movie bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 10)] statement:addStmtMovie position:11];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovie)) {
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovie);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished mmovies - commit done");
    }
    
    sqlite3_reset(selectstmt);
    
    sqlite3_close(databaseAwards);
    
    NSLog(@"updates imported from awards file");
}


+ (void) closeDb {
    sqlite3_close(databaseLocal);
    [Movie printChar];
}

+ (void) printChar {
    NSLog(@"Characters: %i, Characters failed: %i", countChar, countCharFailed);
}

+ (void) begin {
    sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
}
+ (void) commit {
    sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);
}

@end
