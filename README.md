# ImportNewImdb

IMDB dataset importer for data taken from http://www.imdb.com/interfaces/ (new format with tsv files)

For those interested, pick up "ImportNewImdb" on GitHub, it's my code to import the new datasets into a sqlite database, with some post processing to create a kind-of old-style name-movie link.
It's written in ObjC because I am in iOS programming, but it's quite straight forward to follow.
It reads the dataset and generates a 5gb sqlite db in about ten minutes.

In the final db there is a "characters" table searchable by tconst or nconst with data taken both from "principal cast" or "known for", as well as director/writers links taken from "title.crew"
Maybe there will be some intersection in the data (between "known for" and "principals" for example), but it depends on how you will use the data.

To give an idea, with last dataset I have these numbers:

select ttype, count(*) from characters group by ttype

"d"	"3,330,550"
"w"	"5,172,706"
"k"	"14,158,036"
"p"	"26,520,981"

where "d" stands for director,  "w" for writers, "k" for "known for", "p" from "principals".

It's not like the data available in old datasets, but it's a start.

Just to give the context, I use this db in my personal iOS app I use since many years to track and vote the movies/series/episodes I watch (I have a bad memory, so I never know if I have already seen a movie or not...) and using a colored icon on filmography/cast I can visually answer questions like "where have I seen this guy, he/she seems familiar to me".

I also used to write some funny queries to answer questions like "who is my favorite actor/actress/director" based on the votes I give, and many other queries like "which is my favorite genre or country of origin", but this will be no more accurate or possible not having a full database, so bad: I will have to rely on my sensations instead that on pure numbers...

I cannot wait to see if I will be eligible to the promised new full exports, even if I think I will not since I am more a data user than a real contributor.

Best regards
