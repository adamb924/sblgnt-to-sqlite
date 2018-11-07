-- These are just some interesting queries to run.
.mode column
.output demo-output.txt

-- Get all of the unique parsing codes
SELECT DISTINCT(parsing_code) FROM sblgnt ORDER BY parsing_code ASC;

-- Count the lemmas
SELECT COUNT(DISTINCT lemma) FROM sblgnt;

-- Count the verbs
SELECT COUNT(DISTINCT lemma) FROM sblgnt WHERE part_of_speech='verb';

-- List the verbs
SELECT DISTINCT lemma FROM sblgnt WHERE part_of_speech='verb' ORDER BY lemma ASC;

-- How often the various tenses appear
SELECT tense,COUNT(tense) FROM sblgnt WHERE part_of_speech='verb' GROUP BY tense ORDER BY lemma ASC;

-- How often the various tenses appear in each lemma
SELECT lemma,tense,COUNT(tense) FROM sblgnt WHERE part_of_speech='verb' GROUP BY lemma,tense ORDER BY lemma ASC;

-- Same as above, but in John
SELECT lemma,tense,COUNT(tense) FROM sblgnt WHERE part_of_speech='verb' AND book_name='John' GROUP BY lemma,tense ORDER BY lemma ASC;
