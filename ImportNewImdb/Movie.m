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

//static sqlite3 *databaseLocal = nil;
//
//static sqlite3_stmt *addStmtMovie = nil;
//static sqlite3_stmt *addStmtAkaMovie = nil;
//static sqlite3_stmt *addStmtMovieRating = nil;
//static sqlite3_stmt *addStmtMovieEpisode = nil;
//static sqlite3_stmt *addStmtName = nil;
//static sqlite3_stmt *addStmtChar = nil;
//
//static int countChar = 0;
//static int countCharFailed = 0;

- (id) init {
    if (self = [super init]) {
        [self openDb];
    }
    return self;
}

- (void) openDb {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString* newDbName = [documentsDirectory stringByAppendingString:@"/new.sqlite"];
    //NSLog(@"open db path: %@", newDbName);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(! [manager fileExistsAtPath:newDbName] )
    {
        NSLog(@"db not exists at path: %@", newDbName);
        exit(1);
    }
    
    if (sqlite3_open([newDbName UTF8String], &databaseLocal) != SQLITE_OK) {
        sqlite3_close(databaseLocal); //Even though the open call failed, close the database connection to release all the memory.
        
        NSLog(@"Error opening db. '%s'", sqlite3_errmsg(databaseLocal));
        exit(1);
    }
    char *error;
    sqlite3_exec(databaseLocal, "PRAGMA synchronous = OFF", NULL, NULL, &error);
    sqlite3_exec(databaseLocal, "PRAGMA journal_mode = MEMORY", NULL, NULL, &error);
}

+ (void) createDb {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString* newDbName = [documentsDirectory stringByAppendingString:@"/new.sqlite"];
    NSLog(@"create db path: %@", newDbName);
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *writeError = nil;
    if( [manager fileExistsAtPath:newDbName] )
    {
        [manager removeItemAtPath:newDbName error:&writeError];
    }
    
    sqlite3 *databaseGlobal = nil;
    
    if (sqlite3_open([newDbName UTF8String], &databaseGlobal) != SQLITE_OK) {
        sqlite3_close(databaseGlobal); //Even though the open call failed, close the database connection to release all the memory.
        
        NSLog(@"Error creating db. '%s'", sqlite3_errmsg(databaseGlobal));
        exit(1);
    }
    
    char *error;
    
    sqlite3_exec(databaseGlobal, "PRAGMA synchronous = OFF", NULL, NULL, &error);
    sqlite3_exec(databaseGlobal, "PRAGMA journal_mode = MEMORY", NULL, NULL, &error);
    
    const char *sqlStatementMovie = "CREATE TABLE movies(tconst varchar(30), titleType varchar(30), primaryTitle varchar(255), originalTitle varchar(255), isAdult varchar(1), startYear varchar(4), endYear varchar(4), runtimeMinutes varchar(4), genres  varchar(255))";
    
    if (sqlite3_exec(databaseGlobal, sqlStatementMovie, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating movies. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementIdx4 = "CREATE unique INDEX idx_movies_tconst on movies(tconst)";
    NSLog(@"%s",sqlStatementIdx4);
    if (sqlite3_exec(databaseGlobal, sqlStatementIdx4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_movies_tconst. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementAkaMovie = "CREATE TABLE akamovies(titleId varchar(30), ordering varchar(30), title varchar(255), region varchar(255), language varchar(30), types varchar(30), attributes varchar(30), isOriginalTitle  varchar(1))";
    if (sqlite3_exec(databaseGlobal, sqlStatementAkaMovie, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating akamovies. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementName = "CREATE TABLE names(nconst varchar(30), primaryName varchar(255), birthYear varchar(4), deathYear varchar(4), primaryProfession varchar(255))";
    if (sqlite3_exec(databaseGlobal, sqlStatementName, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating names. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementIdx5 = "CREATE unique INDEX idx_names_nconst on names(nconst)";
    NSLog(@"%s",sqlStatementIdx5);
    if (sqlite3_exec(databaseGlobal, sqlStatementIdx5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_names_nconst. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementChar = "CREATE TABLE characters(nconst varchar(30), tconst varchar(30), ttype varchar(1), position integer, category varchar(30), job varchar(255), characters varchar(255))";
    if (sqlite3_exec(databaseGlobal, sqlStatementChar, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating characters. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementRatings = "CREATE TABLE ratings(tconst varchar(30), averageRating varchar(5), numVotes varchar(15))";
    if (sqlite3_exec(databaseGlobal, sqlStatementRatings, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating ratings. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementIdx6 = "CREATE unique INDEX idx_ratings_tconst on ratings(tconst)";
    NSLog(@"%s",sqlStatementIdx6);
    if (sqlite3_exec(databaseGlobal, sqlStatementIdx6, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_ratings_tconst. '%s'", sqlite3_errmsg(databaseGlobal));
    }
    
    const char *sqlStatementEpisodes = "CREATE TABLE episodes(tconst varchar(30), parentTconst varchar(30), seasonNumber varchar(10), episodeNumber varchar(10))";
    if (sqlite3_exec(databaseGlobal, sqlStatementEpisodes, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating episodes. '%s'", sqlite3_errmsg(databaseGlobal));
    }
        
    sqlite3_close(databaseGlobal);
    
}

- (void) createIdxChar_final {
    
    char *error;
    
    const char *sqlStatementIdx1 = "CREATE INDEX idx_char_nconst on characters(nconst)";
    NSLog(@"%s",sqlStatementIdx1);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_char_nconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx2 = "CREATE INDEX idx_char_tconst on characters(tconst)";
    NSLog(@"%s",sqlStatementIdx2);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_char_tconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3 = "CREATE INDEX idx_epi_tconst on episodes(tconst)";
    NSLog(@"%s",sqlStatementIdx3);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_epi_tconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3b = "CREATE INDEX idx_epi_ptconst on episodes(parenttconst)";
    NSLog(@"%s",sqlStatementIdx3b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_epi_ptconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    
    
    const char *sqlStatementIdx4b = "CREATE INDEX idx_akamovies_titleId on akamovies(titleId)";
    NSLog(@"%s",sqlStatementIdx4b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx4b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_akamovies_titleId. '%s'", sqlite3_errmsg(databaseLocal));
    }

/*
    const char *sqlStatementIdx6 = "CREATE INDEX idx_ratings_tconst on ratings(tconst)";
    NSLog(@"%s",sqlStatementIdx6);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx6, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_ratings_tconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
        
    const char *sqlStatementIdx9 = "create index ratings_tconst on ratings(tconst)";
    NSLog(@"%s",sqlStatementIdx9);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx9, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating ratings_tconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
*/
    
    const char *sqlStatementIdx10 = "create index movies_year on movies(startyear)";
    NSLog(@"%s",sqlStatementIdx10);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx10, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating movies_year. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx11 = "create table movieratings as select distinct m.tconst, m.primarytitle, m.originaltitle, m.startyear,m.genres, m.titletype, cast (numvotes as number) numvotes, cast (averageRating as number) rating,'' as posit, '' as positsci from movies m, ratings where m.tconst=ratings.tconst and cast (numvotes as number)>100 and titletype <> 'tvEpisode' order by cast (numvotes as number) desc";
    NSLog(@"%s",sqlStatementIdx11);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx11, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating movieratings. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx12 = "create index movieratings_year on movieratings(startyear)";
    NSLog(@"%s",sqlStatementIdx12);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx12, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating movieratings_year. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx13 = "create index movieratings_tconst on movieratings(tconst)";
    NSLog(@"%s",sqlStatementIdx13);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx13, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating movieratings_year. '%s'", sqlite3_errmsg(databaseLocal));
    }

    const char *sqlStatementIdx14 = "CREATE INDEX idx_movies_primarytitle ON movies(primarytitle COLLATE NOCASE)";
    NSLog(@"%s",sqlStatementIdx14);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx14, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_movies_primarytitle. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx15 = "CREATE INDEX idx_movies_originaltitle ON movies(originaltitle COLLATE NOCASE)";
    NSLog(@"%s",sqlStatementIdx15);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx15, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_movies_originaltitle. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx16 = "CREATE INDEX idx_akamovies_title ON akamovies(title COLLATE NOCASE)";
    NSLog(@"%s",sqlStatementIdx16);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx16, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_akamovies_title. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx18 = "CREATE INDEX idx_names_primaryname ON names(primaryname COLLATE NOCASE)";
    NSLog(@"%s",sqlStatementIdx18);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx18, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_names_primaryname. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    NSLog(@"updating posit");
    NSString* nsSql = @"WITH RECURSIVE cnt(x) AS ( SELECT 1 UNION ALL SELECT x+1 FROM cnt LIMIT 3000) SELECT cast(x as varchar) x FROM cnt where x>=1900 and x<2030 order by 1 desc";
    sqlite3_stmt *selectstmt;
    sqlite3_prepare_v2(databaseLocal, [nsSql UTF8String], -1, &selectstmt, NULL);
    
    NSString* nsSql1 = @"select a.tconst from movieratings a where a.startyear=? order by numvotes desc";
    sqlite3_stmt *selectstmt1;
    sqlite3_prepare_v2(databaseLocal, [nsSql1 UTF8String], -1, &selectstmt1, NULL);
    
    NSString* nsSql2 = @"select a.tconst from movieratings a where a.startyear=? and genres like '%Sci-Fi%' order by numvotes desc";
    sqlite3_stmt *selectstmt2;
    sqlite3_prepare_v2(databaseLocal, [nsSql2 UTF8String], -1, &selectstmt2, NULL);
    
    while(sqlite3_step(selectstmt) == SQLITE_ROW) {
        
        NSString* year = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
        NSLog(@"%@ - 1",year);
        
        sqlite3_bind_text(selectstmt1, 1, [year UTF8String], -1, SQLITE_TRANSIENT);
        
        int i = 1;
        NSString *primaryKey;
        NSString *updStatement;
        
        while(sqlite3_step(selectstmt1) == SQLITE_ROW) {
            
            primaryKey = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt1, 0)];
            
            updStatement = [NSString stringWithFormat:@"update movieratings set posit = '%@-%i' where tconst = '%@'",year,i,primaryKey];
            
            if ( sqlite3_exec(databaseLocal, [updStatement UTF8String], NULL, NULL, &error) != SQLITE_OK)
            {
                NSLog(@"Error while creating updStatement statement. '%s'", sqlite3_errmsg(databaseLocal));
            }
            
            i++;
        }
        sqlite3_reset(selectstmt1);
        
        NSLog(@"%@ - 2",year);
        sqlite3_bind_text(selectstmt2, 1, [year UTF8String], -1, SQLITE_TRANSIENT);
        
        i = 1;
        
        while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
            
            primaryKey = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt2, 0)];
            
            updStatement = [NSString stringWithFormat:@"update movieratings set positsci = '%@-%i' where tconst = '%@'",year,i,primaryKey];
            
            if ( sqlite3_exec(databaseLocal, [updStatement UTF8String], NULL, NULL, &error) != SQLITE_OK)
            {
                NSLog(@"Error while creating updStatement statement. '%s'", sqlite3_errmsg(databaseLocal));
            }
            
            i++;
        }
        sqlite3_reset(selectstmt2);
    }
    sqlite3_reset(selectstmt);
    NSLog(@"updating posit done");
}

- (void) createLocalTables {
    
    char *error;
    
    const char *sqlStatementIdx1 = "CREATE TABLE mmovies ( whereis varchar(50), seen varchar(1), itatitle varchar(255), notes varchar(50), type varchar(10), myvote integer, myid INTEGER PRIMARY KEY AUTOINCREMENT, updatedby varchar(255), title_imdb varchar(255), date_imdb varchar(30), tconst varchar(30) )";
    NSLog(@"%s",sqlStatementIdx1);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx61 = "CREATE TABLE mmfavourites ( favid INTEGER PRIMARY KEY AUTOINCREMENT, tconst varchar(30), title_imdb varchar(255), date_imdb varchar(30), insertdate DATETIME )";
    NSLog(@"%s",sqlStatementIdx61);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx61, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx62 = "CREATE INDEX mmidx_fav_tconst on mmfavourites(tconst)";
    NSLog(@"%s",sqlStatementIdx62);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx62, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx2 = "CREATE INDEX mmidx_mmovies_tconst on mmovies(tconst)";
    NSLog(@"%s",sqlStatementIdx2);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3 = "CREATE TABLE mm_dates ( date_type varchar(100), date DATETIME, location varchar(255), notes varchar(255), channel varchar(45), price float, source varchar(45), updatedby varchar(255), tconst varchar(30), datepk INTEGER PRIMARY KEY AUTOINCREMENT )";
    NSLog(@"%s",sqlStatementIdx3);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx3b = "CREATE INDEX mmidx_mm_dates_tconst on mm_dates(tconst)";
    NSLog(@"%s",sqlStatementIdx3b);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx3b, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx4 = "CREATE TABLE mm_epi_dates ( date_type varchar(100), date DATETIME, updatedby varchar(255), parenttconst varchar(30), tconst varchar(30), datepk INTEGER PRIMARY KEY AUTOINCREMENT , seasonNumber varchar(10), episodeNumber varchar(10))";
    NSLog(@"%s",sqlStatementIdx4);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx5 = "CREATE INDEX mmidx_epi_parenttconst on mm_epi_dates(parenttconst)";
    NSLog(@"%s",sqlStatementIdx5);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx6 = "CREATE INDEX mmidx_epi_tconst on mm_epi_dates(tconst)";
    NSLog(@"%s",sqlStatementIdx6);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx6, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx7 = "CREATE TABLE mstats ( stat varchar(255) )";
    NSLog(@"%s",sqlStatementIdx7);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx7, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating mmovies_local7. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    sqlite3_stmt *statsStmt = nil;
    
    char *insertSQLMovie = "INSERT INTO mstats(stat) VALUES (?)";
    if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &statsStmt, NULL) != SQLITE_OK)
        NSLog(@"Error while creating stats statement. '%s'", sqlite3_errmsg(databaseLocal));
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    sqlite3_bind_text(statsStmt,1,[[dateFormatter stringFromDate:[NSDate date]] UTF8String],-1,SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(statsStmt)) {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(statsStmt);
}
/*
- (void) createAwardsTables {
    
    char *error;
    
    const char *sqlStatementAwards = "CREATE TABLE awards(eventEditionId varchar(50), eventName varchar(100), eventYear varchar(10), awardName varchar(255), categoryName varchar(255), name varchar(255), tconst varchar(30), winner varchar(4), prisec varchar(4), notes varchar(1024), ref varchar(30))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx7 = "CREATE INDEX idx_awards_tconst on awards(tconst)";
    NSLog(@"%s",sqlStatementIdx7);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx7, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_awards_tconst. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementIdx8 = "CREATE INDEX idx_awards_ref on awards(ref)";
    NSLog(@"%s",sqlStatementIdx8);
    if (sqlite3_exec(databaseLocal, sqlStatementIdx8, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating idx_awards_ref. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    const char *sqlStatementAwards1 = "CREATE TABLE awArray (label varchar(100))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards1. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAwards2 = "CREATE TABLE awDictAwardName (label varchar(100),name varchar(100))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards2. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAwards3 = "CREATE TABLE awDictCategoryName (label varchar(100),cat varchar(500))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards3. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAwards4 = "CREATE TABLE awDictEventName (label varchar(100),name varchar(100))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards4. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAwards5 = "CREATE TABLE awDictType (label varchar(100),type varchar(100))";
    if (sqlite3_exec(databaseLocal, sqlStatementAwards5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error creating awards5. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
}
*/

-(void) bindString:(NSString*)myString statement:(sqlite3_stmt*)statement position:(int)position{
    if (myString && ![myString isEqualToString:@"\\N"])
        sqlite3_bind_text(statement,position,[myString UTF8String],-1,SQLITE_TRANSIENT);
    else
        sqlite3_bind_text(statement,position,[@"" UTF8String],-1,SQLITE_TRANSIENT);
        //sqlite3_bind_null(statement,position);
}

//tconst	titleType	primaryTitle	originalTitle	isAdult	startYear	endYear	runtimeMinutes	genres
- (void) insertMovieWithTconst:(NSString*)tconst titleType:(NSString*)titleType primaryTitle:(NSString*)primaryTitle originalTitle:(NSString*)originalTitle isAdult:(NSString*)isAdult startYear:(NSString*)startYear endYear:(NSString*)endYear runtimeMinutes:(NSString*)runtimeMinutes genres:(NSString*)genres {
    if(addStmtMovie == nil) {
        char *insertSQLMovie = "INSERT INTO movies(tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres) VALUES (?,?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovie, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:tconst statement:addStmtMovie position:1];
    [self bindString:titleType statement:addStmtMovie position:2];
    [self bindString:primaryTitle statement:addStmtMovie position:3];
    [self bindString:originalTitle statement:addStmtMovie position:4];
    [self bindString:isAdult statement:addStmtMovie position:5];
    [self bindString:startYear statement:addStmtMovie position:6];
    [self bindString:endYear statement:addStmtMovie position:7];
    [self bindString:runtimeMinutes statement:addStmtMovie position:8];
    [self bindString:genres statement:addStmtMovie position:9];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovie)) {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovie);
}

//titleId    ordering    title    region    language    types    attributes    isOriginalTitle
- (void) insertAkaMovieWithTconst:(NSString*)tconst ordering:(NSString*)ordering title:(NSString*)title region:(NSString*)region language:(NSString*)language types:(NSString*)types attributes:(NSString*)attributes isOriginalTitle:(NSString*)isOriginalTitle{
    if(addStmtAkaMovie == nil) {
        char *insertSQLMovie = "INSERT INTO akamovies(titleId, ordering, title, region, language, types, attributes, isOriginalTitle) VALUES (?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtAkaMovie, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:tconst statement:addStmtAkaMovie position:1];
    [self bindString:ordering statement:addStmtAkaMovie position:2];
    [self bindString:title statement:addStmtAkaMovie position:3];
    [self bindString:region statement:addStmtAkaMovie position:4];
    [self bindString:language statement:addStmtAkaMovie position:5];
    [self bindString:types statement:addStmtAkaMovie position:6];
    [self bindString:attributes statement:addStmtAkaMovie position:7];
    [self bindString:isOriginalTitle statement:addStmtAkaMovie position:8];
    
    if(SQLITE_DONE != sqlite3_step(addStmtAkaMovie)) {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtAkaMovie);
}

//tconst	averageRating	numVotes
- (BOOL) insertMovieRatingWithTconst:(NSString*)tconst averageRating:(NSString*)averageRating numVotes:(NSString*)numVotes {
    BOOL isdup = false;
    if(addStmtMovieRating == nil) {
        char *insertSQLMovieRating = "INSERT INTO ratings(tconst, averageRating, numVotes) VALUES (?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovieRating, -1, &addStmtMovieRating, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:tconst statement:addStmtMovieRating position:1];
    [self bindString:averageRating statement:addStmtMovieRating position:2];
    [self bindString:numVotes statement:addStmtMovieRating position:3];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovieRating)) {
        NSString* err = [NSString stringWithUTF8String:(char *)sqlite3_errmsg(databaseLocal)];
        if ( [err containsString:@"UNIQUE constraint"])
            isdup=true;
        else
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovieRating);
    return isdup;
}

//tconst	parentTconst	seasonNumber	episodeNumber
- (void) insertMovieEpisodeWithTconst:(NSString*)tconst parentTconst:(NSString*)parentTconst seasonNumber:(NSString*)seasonNumber episodeNumber:(NSString*)episodeNumber {
    if(addStmtMovieEpisode == nil) {
        char *insertSQLMovieEpisode = "INSERT INTO episodes(tconst, parentTconst, seasonNumber, episodeNumber) VALUES (?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovieEpisode, -1, &addStmtMovieEpisode, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:tconst statement:addStmtMovieEpisode position:1];
    [self bindString:parentTconst statement:addStmtMovieEpisode position:2];
    [self bindString:seasonNumber statement:addStmtMovieEpisode position:3];
    [self bindString:episodeNumber statement:addStmtMovieEpisode position:4];
    
    if(SQLITE_DONE != sqlite3_step(addStmtMovieEpisode)) {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
    }
    sqlite3_reset(addStmtMovieEpisode);
}

//nconst	primaryName	birthYear	deathYear	primaryProfession//	knownForTitles
- (int) insertNameWithNconst:(NSString*)nconst primaryName:(NSString*)primaryName birthYear:(NSString*)birthYear deathYear:(NSString*)deathYear primaryProfession:(NSString*)primaryProfession {
    int retval=0;
    if(addStmtName == nil) {
        char *insertSQLName = "INSERT INTO names(nconst, primaryName, birthYear, deathYear, primaryProfession) VALUES (?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLName, -1, &addStmtName, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:nconst statement:addStmtName position:1];
    [self bindString:primaryName statement:addStmtName position:2];
    [self bindString:birthYear statement:addStmtName position:3];
    [self bindString:deathYear statement:addStmtName position:4];
    [self bindString:primaryProfession statement:addStmtName position:5];
    
    if(SQLITE_DONE != sqlite3_step(addStmtName)) {
        //NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
        retval=1;
    }
    sqlite3_reset(addStmtName);
    return retval;
}

- (void) insertCharacterWithNconst:(NSString*)nconst tconst:(NSString*)tconst ttype:(NSString*)ttype position:(NSInteger) position category:(NSString*)category job:(NSString*)job characters:(NSString*)characters{
    if(addStmtChar == nil) {
        char *insertSQLChar = "INSERT INTO characters(nconst, tconst, ttype, position, category, job, characters) VALUES (?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLChar, -1, &addStmtChar, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    [self bindString:nconst statement:addStmtChar position:1];
    [self bindString:tconst statement:addStmtChar position:2];
    [self bindString:ttype statement:addStmtChar position:3];
    sqlite3_bind_int (addStmtChar, 4, (int)position);
    [self bindString:category statement:addStmtChar position:5];
    [self bindString:job statement:addStmtChar position:6];
    [self bindString:characters statement:addStmtChar position:7];
    
    if(SQLITE_DONE != sqlite3_step(addStmtChar)) {
        //NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
        countCharFailed++;
    } else {
        countChar++;
    }
    sqlite3_reset(addStmtChar);
    
}

/*
- (void) importAwards {
    
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
    
    char *error;
    const char *sqlStatementAw = "delete from awards";
    NSLog(@"%s",sqlStatementAw);
    if (sqlite3_exec(databaseLocal, sqlStatementAw, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAw1 = "delete from awArray";
    NSLog(@"%s",sqlStatementAw1);
    if (sqlite3_exec(databaseLocal, sqlStatementAw1, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards1. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAw2 = "delete from awDictAwardName";
    NSLog(@"%s",sqlStatementAw2);
    if (sqlite3_exec(databaseLocal, sqlStatementAw2, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards2. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAw3 = "delete from awDictCategoryName";
    NSLog(@"%s",sqlStatementAw3);
    if (sqlite3_exec(databaseLocal, sqlStatementAw3, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards3. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAw4 = "delete from awDictEventName";
    NSLog(@"%s",sqlStatementAw4);
    if (sqlite3_exec(databaseLocal, sqlStatementAw4, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards4. '%s'", sqlite3_errmsg(databaseLocal));
    }
    const char *sqlStatementAw5 = "delete from awDictType";
    NSLog(@"%s",sqlStatementAw5);
    if (sqlite3_exec(databaseLocal, sqlStatementAw5, NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"Error deleting awards5. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    
    sqlite3 *databaseAwards = nil;
    
    if (sqlite3_open([newDbName UTF8String], &databaseAwards) != SQLITE_OK) {
        sqlite3_close(databaseAwards); //Even though the open call failed, close the database connection to release all the memory.
        NSLog(@"Error opening awards db. '%s'", sqlite3_errmsg(databaseLocal));
    }
    
    
    //eventName, eventYear, awardName, categoryName, name, tconst, winner, prisec, notes, ref, eventEditionId
    const char *sql0 = "select ifnull(eventName,''), ifnull(eventYear,''), ifnull(awardName,''), ifnull(categoryName,''), ifnull(name,''), ifnull(tconst,''), ifnull(winner,''), ifnull(prisec,''), ifnull(notes,''), ifnull(ref,''), ifnull(eventEditionId,'') from awards";
    
    sqlite3_stmt *selectstmt;
    sqlite3_stmt *addStmtMovieAward;
    if(sqlite3_prepare_v2(databaseAwards, sql0, -1, &selectstmt, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awards(eventName, eventYear, awardName, categoryName, name, tconst, winner, prisec, notes, ref, eventEditionId) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] statement:addStmtMovieAward position:1];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)] statement:addStmtMovieAward position:2];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)] statement:addStmtMovieAward position:3];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)] statement:addStmtMovieAward position:4];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)] statement:addStmtMovieAward position:5];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] statement:addStmtMovieAward position:6];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 6)] statement:addStmtMovieAward position:7];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 7)] statement:addStmtMovieAward position:8];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 8)] statement:addStmtMovieAward position:9];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 9)] statement:addStmtMovieAward position:10];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 10)] statement:addStmtMovieAward position:11];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awards - commit done");
    }
    
    sqlite3_reset(selectstmt);
    
    
    
    const char *sql1 = "select label from awArray";
    sqlite3_stmt *selectstmt1;
    if(sqlite3_prepare_v2(databaseAwards, sql1, -1, &selectstmt1, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awArray(label) VALUES (?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt1) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt1, 0)] statement:addStmtMovieAward position:1];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awArray - commit done");
    }
    
    sqlite3_reset(selectstmt1);

    
    
    const char *sql2 = "select label, ifnull(name,'') from awDictAwardName";
    sqlite3_stmt *selectstmt2;
    if(sqlite3_prepare_v2(databaseAwards, sql2, -1, &selectstmt2, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awDictAwardName(label,name) VALUES (?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt2, 0)] statement:addStmtMovieAward position:1];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt2, 1)] statement:addStmtMovieAward position:2];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awDictAwardName - commit done");
    }
    
    sqlite3_reset(selectstmt2);
    
    
    
    const char *sql3 = "select label, ifnull(cat,'') from awDictCategoryName";
    sqlite3_stmt *selectstmt3;
    if(sqlite3_prepare_v2(databaseAwards, sql3, -1, &selectstmt3, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awDictCategoryName(label,cat) VALUES (?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt3) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt3, 0)] statement:addStmtMovieAward position:1];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt3, 1)] statement:addStmtMovieAward position:2];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awDictCategoryName - commit done");
    }
    
    sqlite3_reset(selectstmt3);
    
    
    
    const char *sql4 = "select label, ifnull(name,'') from awDictEventName";
    sqlite3_stmt *selectstmt4;
    if(sqlite3_prepare_v2(databaseAwards, sql4, -1, &selectstmt4, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awDictEventName(label,name) VALUES (?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt4) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt4, 0)] statement:addStmtMovieAward position:1];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt4, 1)] statement:addStmtMovieAward position:2];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awDictEventName - commit done");
    }
    
    sqlite3_reset(selectstmt4);
    
    
    
    const char *sql5 = "select label, ifnull(type,'') from awDictType";
    sqlite3_stmt *selectstmt5;
    if(sqlite3_prepare_v2(databaseAwards, sql5, -1, &selectstmt5, NULL) == SQLITE_OK) {
        
        char *insertSQLMovie = "INSERT INTO awDictType(label,type) VALUES (?,?)";
        if(sqlite3_prepare_v2(databaseLocal, insertSQLMovie, -1, &addStmtMovieAward, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databaseLocal));
        
        sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
        
        while(sqlite3_step(selectstmt5) == SQLITE_ROW) {
            
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt5, 0)] statement:addStmtMovieAward position:1];
            [self bindString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt5, 1)] statement:addStmtMovieAward position:2];
            
            if(SQLITE_DONE != sqlite3_step(addStmtMovieAward)) {
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databaseLocal));
            }
            sqlite3_reset(addStmtMovieAward);
            
        }
        sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);

        NSLog(@"finished awDictEventName - commit done");
    }
    
    sqlite3_reset(selectstmt5);

    
    
    
    sqlite3_close(databaseAwards);
    
    NSLog(@"updates imported from awards file");
}
*/

- (void) closeDb {
    sqlite3_finalize(addStmtMovie);
    sqlite3_finalize(addStmtAkaMovie);
    sqlite3_finalize(addStmtMovieRating);
    sqlite3_finalize(addStmtMovieEpisode);
    sqlite3_finalize(addStmtName);
    sqlite3_finalize(addStmtChar);

    sqlite3_close(databaseLocal);
    //[self printChar];
}

- (void) printChar {
    NSLog(@"Characters: %i, Characters failed: %i", countChar, countCharFailed);
}

- (void) begin {
    char *error;
    sqlite3_exec(databaseLocal, "BEGIN TRANSACTION", NULL, NULL, &error);
}

- (void) commit {
    char *error;
    sqlite3_exec(databaseLocal, "END TRANSACTION", NULL, NULL, &error);
}
/*
- (void) begin {
    sqlite3_exec(databaseLocal, "BEGIN", 0, 0, 0);
}
- (void) commit {
    sqlite3_exec(databaseLocal, "COMMIT", 0, 0, 0);
}*/

@end
