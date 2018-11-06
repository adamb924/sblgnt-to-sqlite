sblgnt-to-sqlite
===============

This is simple sqlite3 code to import the MorphGNT data into a sqlite database, and to make the data more human- and machine-readable. Different people will have different ideas about database design, and about what is helpful. Feel free to delete columns you don't wish to use. :-)

MorphGNT is here:
http://morphgnt.org/
Specifically, this repository:
https://github.com/morphgnt/sblgnt

sqlite3 is here:
https://www.sqlite.org/

Usage
-----------
On my Windows computer, I am able to execute the code as follows:

sqlite3 sblgnt.db ".read sblgnt-to-sqlite.sql"

The code assumes that this folder (sblgnt-to-sqlite) is a sister directory to sblgnt (which contains "61-Mt-morphgnt.txt" et al.). If that doesn't describe your situation, you can just change the file path on lines 15 through 41 in "sblgnt-to-sqlite.sql".

"demo-queries.sql" has some sample queries.

Columns
-----------
 * _id
   index to the table; each word is numbered consectively
 * citation
   column 1 of the SBLGNT data
 * part_of_speech_code
   column 2 of the SBLGNT data
 * parsing_code
   column 3 of the SBLGNT data
 * punctuated_text
   column 4 of the SBLGNT data
 * unpunctuated_text
   column 5 of the SBLGNT data
 * normalized_word
   column 6 of the SBLGNT data
 * lemma
   column 7 of the SBLGNT data
 * book_number
   number of the biblical book (extracted from citation field)
 * book_code
   three-letter abbreviation of the book (following UBS's abbreviations)
 * book_name
   English name of the book
 * chapter
   number of the chapter (extracted from citation field)
 * verse
   number of the verse (extracted from citation field)
 * position
   position of the word in the verse (1-indexed)
 * part_of_speech
   English description of part_of_speech_code (from: parts-of-speech.txt)
 * person_code
   character 1 from parsing_code (or null for '-')
 * tense_code
   character 2 from parsing_code (or null for '-')
 * voice_code
   character 3 from parsing_code (or null for '-')
 * mood_code
   character 4 from parsing_code (or null for '-')
 * grammatical_case_code
   character 5 from parsing_code (or null for '-')
 * grammatical_number_code
   character 6 from parsing_code (or null for '-')
 * gender_code
   character 7 from parsing_code (or null for '-')
 * degree_code
   character 8 from parsing_code (or null for '-')
 * person
   English description of person_code (from: persons.txt)
 * tense
   English description of tense_code (from: tenses.txt)
 * voice
   English description of voice_code (from: voices.txt)
 * mood
   English description of mood_code (from: moods.txt)
 * grammatical_case
   English description of grammatical_case_code (from: cases.txt)
   'case' is a reserved sqlite3 word, hence the longer name
 * grammatical_number
   English description of grammatical_number_code (from: numbers.txt)
   'number' is a reserved sqlite3 word, hence the longer name
 * gender
   English description of gender_code (from: genders.txt)
 * degree
   English description of degree_code (from: degrees.txt)