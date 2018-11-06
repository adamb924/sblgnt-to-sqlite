-- make sure we're starting from an empty table
DROP TABLE IF EXISTS sblgnt;
-- create a temporary table to receive the text data, and import that data
CREATE TEMP TABLE _csv_import ( 
																	citation TEXT,
																	part_of_speech_code TEXT,
																	parsing_code TEXT,
																	punctuated_text TEXT,
																	unpunctuated_text TEXT,
																	 normalized_word TEXT,
																	lemma TEXT
																);
-- import the text data into _csv_import
.separator " "
.import ../sblgnt/61-Mt-morphgnt.txt _csv_import
.import ../sblgnt/62-Mk-morphgnt.txt _csv_import
.import ../sblgnt/63-Lk-morphgnt.txt _csv_import
.import ../sblgnt/64-Jn-morphgnt.txt _csv_import
.import ../sblgnt/65-Ac-morphgnt.txt _csv_import
.import ../sblgnt/66-Ro-morphgnt.txt _csv_import
.import ../sblgnt/67-1Co-morphgnt.txt _csv_import
.import ../sblgnt/68-2Co-morphgnt.txt _csv_import
.import ../sblgnt/69-Ga-morphgnt.txt _csv_import
.import ../sblgnt/70-Eph-morphgnt.txt _csv_import
.import ../sblgnt/71-Php-morphgnt.txt _csv_import
.import ../sblgnt/72-Col-morphgnt.txt _csv_import
.import ../sblgnt/73-1Th-morphgnt.txt _csv_import
.import ../sblgnt/74-2Th-morphgnt.txt _csv_import
.import ../sblgnt/75-1Ti-morphgnt.txt _csv_import
.import ../sblgnt/76-2Ti-morphgnt.txt _csv_import
.import ../sblgnt/77-Tit-morphgnt.txt _csv_import
.import ../sblgnt/78-Phm-morphgnt.txt _csv_import
.import ../sblgnt/79-Heb-morphgnt.txt _csv_import
.import ../sblgnt/80-Jas-morphgnt.txt _csv_import
.import ../sblgnt/81-1Pe-morphgnt.txt _csv_import
.import ../sblgnt/82-2Pe-morphgnt.txt _csv_import
.import ../sblgnt/83-1Jn-morphgnt.txt _csv_import
.import ../sblgnt/84-2Jn-morphgnt.txt _csv_import
.import ../sblgnt/85-3Jn-morphgnt.txt _csv_import
.import ../sblgnt/86-Jud-morphgnt.txt _csv_import
.import ../sblgnt/87-Re-morphgnt.txt _csv_import

-- load the book name data from a text file
-- I'm creating this as a permanent table because it may be generally useful
DROP TABLE IF EXISTS book_names;
CREATE TABLE book_names ( _id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT );
.separator "	"
.import book-names.txt book_names

-- wrap the whole business in a single transaction so sqlite doesn't do commits all the time
BEGIN TRANSACTION;

-- create the final table
CREATE TABLE sblgnt (	
											_id INTEGER PRIMARY KEY AUTOINCREMENT,
											citation TEXT,
											part_of_speech_code TEXT,
											parsing_code TEXT,
											punctuated_text TEXT,
											unpunctuated_text TEXT,
											 normalized_word TEXT,
											lemma TEXT,
											book_number INTEGER,
											book_code TEXT,
											book_name TEXT,
											chapter INTEGER,
											verse INTEGER,
											position INTEGER,
											part_of_speech TEXT,
											person_code text DEFAULT NULL,
											tense_code text DEFAULT NULL,
											voice_code text DEFAULT NULL,
											mood_code text DEFAULT NULL,
											grammatical_case_code text DEFAULT NULL,
											grammatical_number_code text DEFAULT NULL,
											gender_code text DEFAULT NULL,
											degree_code text DEFAULT NULL,
											person text DEFAULT NULL,
											tense text DEFAULT NULL,
											voice text DEFAULT NULL,
											mood text DEFAULT NULL,
											grammatical_case text DEFAULT NULL,
											grammatical_number text DEFAULT NULL,
											gender text DEFAULT NULL,
											degree text DEFAULT NULL
										);
-- insert the imported data from _csv_import into sblgnt
INSERT INTO sblgnt (citation, part_of_speech_code, parsing_code, punctuated_text, unpunctuated_text,  normalized_word, lemma) 
					SELECT citation, part_of_speech_code, parsing_code, punctuated_text, unpunctuated_text,  normalized_word, lemma
					FROM _csv_import WHERE 1;
-- get rid of the temporary table
DROP TABLE _csv_import;

-- divide the book/chapter/verse codes into columns
UPDATE sblgnt SET book_number=SUBSTR(citation,1,2);
UPDATE sblgnt SET chapter=SUBSTR(citation,3,2);
UPDATE sblgnt SET verse=SUBSTR(citation,5,2);
UPDATE sblgnt SET book_code=(select code from book_names where book_number=_id);
UPDATE sblgnt SET book_name=(select name from book_names where book_number=_id);

-- set values for 'position' — the position of the word in the verse in which it occurs (1-indexed)
CREATE TEMPORARY TABLE _minimum_ids ( least_id INTEGER,  book_number INTEGER, chapter INTEGER, verse INTEGER);
INSERT INTO _minimum_ids ( least_id, book_number, chapter, verse ) SELECT MIN(_id),book_number,chapter,verse FROM sblgnt GROUP BY book_number,chapter,verse;
UPDATE sblgnt SET position=(_id - (SELECT least_id FROM _minimum_ids WHERE _minimum_ids.book_number=sblgnt.book_number AND _minimum_ids.chapter=sblgnt.chapter AND _minimum_ids.verse=sblgnt.verse) + 1);
DROP TABLE _minimum_ids;

-- pull apart parsing codes into columns
UPDATE sblgnt SET person_code=SUBSTR(parsing_code,1,1);
UPDATE sblgnt SET tense_code=SUBSTR(parsing_code,2,1);
UPDATE sblgnt SET voice_code=SUBSTR(parsing_code,3,1);
UPDATE sblgnt SET mood_code=SUBSTR(parsing_code,4,1);
UPDATE sblgnt SET grammatical_case_code=SUBSTR(parsing_code,5,1);
UPDATE sblgnt SET grammatical_number_code=SUBSTR(parsing_code,6,1);
UPDATE sblgnt SET gender_code=SUBSTR(parsing_code,7,1);
UPDATE sblgnt SET degree_code=SUBSTR(parsing_code,8,1);

COMMIT TRANSACTION;

-- produce human-readable parts of speech
CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.separator "	"
.import parts-of-speech.txt _codes
UPDATE sblgnt SET part_of_speech=(SELECT human_readable FROM _codes WHERE part_of_speech_code=code);
DROP TABLE _codes;

-- produce human-readable grammatical parsings
.separator "	"
CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import persons.txt _codes
UPDATE sblgnt SET person=(SELECT human_readable FROM _codes WHERE code=person_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import tenses.txt _codes
UPDATE sblgnt SET tense=(SELECT human_readable FROM _codes WHERE code=tense_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import voices.txt _codes
UPDATE sblgnt SET voice=(SELECT human_readable FROM _codes WHERE code=voice_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import moods.txt _codes
UPDATE sblgnt SET mood=(SELECT human_readable FROM _codes WHERE code=mood_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import cases.txt _codes
UPDATE sblgnt SET grammatical_case=(SELECT human_readable FROM _codes WHERE code=grammatical_case_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import numbers.txt _codes
UPDATE sblgnt SET grammatical_number=(SELECT human_readable FROM _codes WHERE code=grammatical_number_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import genders.txt _codes
UPDATE sblgnt SET gender=(SELECT human_readable FROM _codes WHERE code=gender_code);
DROP TABLE _codes;

CREATE TEMPORARY TABLE _codes ( code TEXT,  human_readable TEXT);
.import degrees.txt _codes
UPDATE sblgnt SET degree=(SELECT human_readable FROM _codes WHERE code=degree_code);
DROP TABLE _codes;
