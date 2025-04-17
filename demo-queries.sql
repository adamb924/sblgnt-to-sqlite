-- These are just some interesting queries to run.
.mode list

-- Get all of the unique parsing codes
SELECT DISTINCT(parsing_code) FROM sblgnt ORDER BY parsing_code ASC;

-- Count the lemmas
SELECT COUNT(DISTINCT lemma) FROM sblgnt;

-- Count the verbs
SELECT COUNT(DISTINCT lemma) FROM sblgnt WHERE part_of_speech='verb';

-- List the verbs
SELECT DISTINCT lemma FROM sblgnt WHERE part_of_speech='verb' ORDER BY lemma ASC;

-- How often the various tenses appear
SELECT tense,COUNT(tense) as occurences FROM sblgnt WHERE part_of_speech='verb' GROUP BY tense ORDER BY occurences DESC;

-- How often the various tenses appear in each lemma
SELECT lemma,tense,COUNT(tense) FROM sblgnt WHERE part_of_speech='verb' GROUP BY lemma,tense ORDER BY lemma ASC;

-- Same as above, but in John
SELECT lemma,tense,COUNT(tense) FROM sblgnt WHERE part_of_speech='verb' AND book_name='John' GROUP BY lemma,tense ORDER BY lemma ASC;

-- All combinations of tenses and moods
SELECT DISTINCT tenses.human_readable AS tense,moods.human_readable AS mood FROM tenses,moods;

-- How often the various tense/mood combinations appear in each lemma
SELECT lemma,mood,tense,COUNT(*) AS ncount FROM sblgnt WHERE part_of_speech='verb' GROUP BY lemma,mood,tense ORDER BY lemma ASC;

-- How often the various tense/mood combinations appear in each lemma, in John
SELECT lemma,mood,tense,COUNT(*) AS ncount FROM sblgnt WHERE part_of_speech='verb' AND book_name='John' GROUP BY lemma,mood,tense ORDER BY lemma ASC;

-- How often the various tense/mood combinations appear in each lemma, including zero counts
SELECT combos.lemma,combos.mood,combos.tense,IFNULL(ncount,0) FROM
	(SELECT DISTINCT tenses.human_readable AS tense,moods.human_readable AS mood,lemma FROM tenses,moods,sblgnt WHERE part_of_speech='verb') combos
		LEFT JOIN
	(SELECT lemma,mood,tense,COUNT(*) AS ncount FROM sblgnt WHERE part_of_speech='verb' GROUP BY lemma,mood,tense ORDER BY lemma ASC) counts
	ON counts.lemma=combos.lemma AND counts.mood=combos.mood AND counts.tense=combos.tense
	ORDER BY combos.lemma,combos.mood,combos.tense;
	
-- How often the various tense/mood combinations appear in each book
SELECT book_name,mood,tense,COUNT(*) AS ncount FROM sblgnt WHERE part_of_speech='verb' GROUP BY book_name,mood,tense ORDER BY book_number ASC;

-- How often the various tenses appear in the indicative
SELECT tense,COUNT(tense) as occurences FROM sblgnt WHERE part_of_speech='verb' AND mood='indicative' GROUP BY tense ORDER BY occurences DESC;

-- Get a report for all the uses of the tenses in the indicative, by lemma
CREATE TEMPORARY TABLE tmp AS SELECT lemma,tense,COUNT(*) AS ncount FROM sblgnt WHERE part_of_speech='verb' AND mood='indicative' GROUP BY lemma,mood,tense ORDER BY lemma ASC;
SELECT lemma,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='aorist') AS aorist,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='present') AS present,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='imperfect') AS imperfect,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='future') AS future,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='perfect') AS perfect,
	(SELECT ncount FROM tmp WHERE lemma=tmpTable.lemma AND tense='pluperfect') AS pluperfect,
	(SELECT SUM(ncount) FROM tmp WHERE lemma=tmpTable.lemma) AS total,
	(SELECT COUNT(*) FROM tmp WHERE lemma=tmpTable.lemma) AS tenses_used
	FROM tmp tmpTable GROUP BY lemma;

-- Number of word forms in the NT
SELECT COUNT(_id) FROM sblgnt;

-- Number of distinct lemmas in the NT
SELECT COUNT(DISTINCT lemma) FROM sblgnt;

-- Number of chapters in the Bible
SELECT COUNT(DISTINCT book_number||','||chapter) FROM sblgnt;

-- Number of words in the NT, by book
SELECT book_name,COUNT(*) AS Words FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Number of distinct lemmas in the NT, by book
SELECT book_name,COUNT(DISTINCT lemma) AS Lemmas FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Number of verses per book
SELECT book_name,COUNT(DISTINCT book_number||','||chapter||','||verse) AS Verses FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Number of chapters per book
SELECT book_name,COUNT(DISTINCT book_number||','||chapter) AS Chapters FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;


-- Average number of words per verse
SELECT book_name,
		COUNT(_id) AS Words,
		COUNT(DISTINCT book_number||','||chapter||','||verse) AS Verses, 
		CAST( COUNT(DISTINCT _id) AS REAL)/CAST(COUNT(DISTINCT book_number||','||chapter||','||verse) AS REAL) AS WordsPerVerse 
	FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;


-- Average number of distinct lemmas per verse
SELECT book_name,
		COUNT(DISTINCT lemma) AS Lemmas,
		COUNT(DISTINCT book_number||','||chapter||','||verse) AS Verses, 
		CAST( COUNT(DISTINCT lemma) AS REAL)/CAST(COUNT(DISTINCT book_number||','||chapter||','||verse) AS REAL) AS DistinctLemmasPerVerse 
	FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Average number of distinct lemmas per word
SELECT book_name,
		COUNT(DISTINCT lemma) AS Lemmas,
		COUNT(_id) AS Words, 
		CAST( COUNT(DISTINCT lemma) AS REAL)/CAST(COUNT(_id) AS REAL) AS DistinctLemmasPerWord 
	FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Total number of hapax legmomena
SELECT COUNT(lemma) as NumberHapax FROM 
	(SELECT lemma,COUNT(lemma) AS cnt,book_name,book_number FROM sblgnt GROUP BY lemma) 
	WHERE cnt=1;

-- Number of hapax legomena per book
SELECT book_name,COUNT(lemma) as NumberHapax FROM 
	(SELECT lemma,COUNT(lemma) AS cnt,book_name,book_number FROM sblgnt GROUP BY lemma) 
	WHERE cnt=1 GROUP BY book_name ORDER BY book_number ASC;


-- Number of words in the book that appear nowhere else
SELECT book_name,COUNT(lemma) as NumberOnlyFoundHere FROM 
	( SELECT lemma,COUNT(book_name) as NumberOfBooks,book_name,book_number FROM
		(SELECT DISTINCT book_name,lemma,book_number FROM sblgnt)
		GROUP BY lemma HAVING NumberOfBooks=1 )
	GROUP BY book_name
	ORDER BY book_number;

-- Number of words in the book that appear nowhere else, as a fraction of words in the book
SELECT tmpB.book_name,COUNT(lemma) as NumberOnlyFoundHere, Lemmas, CAST(COUNT(lemma) AS REAL)/CAST(Lemmas AS REAL) FROM 
	( SELECT lemma,COUNT(book_name) as NumberOfBooks,book_name,book_number FROM
		(SELECT DISTINCT book_name,lemma,book_number FROM sblgnt)
		GROUP BY lemma HAVING NumberOfBooks=1 ) AS tmpA
	LEFT JOIN
		( SELECT book_name,COUNT(DISTINCT lemma) AS Lemmas FROM sblgnt GROUP BY book_name ) AS tmpB
	ON tmpA.book_name=tmpB.book_name
	GROUP BY tmpB.book_name
	ORDER BY book_number ASC;


-- Number of words per book
SELECT book_name,COUNT(_id) AS nWords FROM sblgnt GROUP BY book_name ORDER BY book_number ASC;

-- Number of participles per book
SELECT book_name,COUNT(_id) AS nParticiples FROM sblgnt WHERE part_of_speech='verb' AND gender IS NOT NULL GROUP BY book_name ORDER BY book_number ASC;

-- Number of participles as a fraction of the number of words
SELECT tmpA.book_name,CAST( nParticiples AS REAL)/CAST(nWords AS REAL) as Fraction FROM
	(SELECT book_number,book_name,COUNT(_id) AS nWords FROM sblgnt GROUP BY book_name) AS tmpA
		LEFT JOIN
	(SELECT book_name,COUNT(_id) AS nParticiples FROM sblgnt WHERE part_of_speech='verb' AND gender IS NOT NULL GROUP BY book_name) AS tmpB
	ON tmpA.book_name=tmpB.book_name
	ORDER BY tmpA.book_number ASC;

-- Number of participles as a fraction of the number of relative pronouns
SELECT tmpA.book_name,CAST( nParticiples AS REAL)/CAST(nPronouns AS REAL) as Fraction FROM
	(SELECT book_number,book_name,COUNT(_id) AS nPronouns FROM sblgnt WHERE part_of_speech='relative-pronoun' GROUP BY book_name) AS tmpA
		LEFT JOIN
	(SELECT book_name,COUNT(_id) AS nParticiples FROM sblgnt WHERE part_of_speech='verb' AND gender IS NOT NULL GROUP BY book_name) AS tmpB
	ON tmpA.book_name=tmpB.book_name
	ORDER BY tmpA.book_number ASC;


