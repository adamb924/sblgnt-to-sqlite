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

