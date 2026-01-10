/*Table: user_content

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| content_id  | int     |
| content_text| varchar |
+-------------+---------+
content_id is the unique key for this table.
Each row contains a unique ID and the corresponding text content.
Write a solution to transform the text in the content_text column by applying the following rules:

Convert the first letter of each word to uppercase and the remaining letters to lowercase
Special handling for words containing special characters:
For words connected with a hyphen -, both parts should be capitalized (e.g., top-rated → Top-Rated)
All other formatting and spacing should remain unchanged
Return the result table that includes both the original content_text and the modified text following the above rules.

The result format is in the following example.

 

Example:

Input:

user_content table:

+------------+---------------------------------+
| content_id | content_text                    |
+------------+---------------------------------+
| 1          | hello world of SQL              |
| 2          | the QUICK-brown fox             |
| 3          | modern-day DATA science         |
| 4          | web-based FRONT-end development |
+------------+---------------------------------+
Output:

+------------+---------------------------------+---------------------------------+
| content_id | original_text                   | converted_text                  |
+------------+---------------------------------+---------------------------------+
| 1          | hello world of SQL              | Hello World Of Sql              |
| 2          | the QUICK-brown fox             | The Quick-Brown Fox             |
| 3          | modern-day DATA science         | Modern-Day Data Science         |
| 4          | web-based FRONT-end development | Web-Based Front-End Development |
+------------+---------------------------------+---------------------------------+
Explanation:

For content_id = 1:
Each word's first letter is capitalized: "Hello World Of Sql"
For content_id = 2:
Contains the hyphenated word "QUICK-brown" which becomes "Quick-Brown"
Other words follow normal capitalization rules
For content_id = 3:
Hyphenated word "modern-day" becomes "Modern-Day"
"DATA" is converted to "Data"
For content_id = 4:
Contains two hyphenated words: "web-based" → "Web-Based"
And "FRONT-end" → "Front-End"
 

Constraints:

context_text contains only English letters, and the characters in the list ['\', ' ', '@', '-', '/', '^', ',']
 */
-- Table Schema
-- CREATE TABLE If not exists user_content (
--     content_id INT,
--     content_text VARCHAR(255)
-- )
-- Truncate table user_content
-- insert into user_content (content_id, content_text) values ('1', 'hello world of SQL')
-- ,('2', 'the QUICK-brown fox')
-- ,('3', 'modern-day DATA science')
-- ,('4', 'web-based FRONT-end development')
-- ,('5', '/abc Def-@ghi')
SELECT
    *,
    array_to_string(array_agg, ' ')
FROM (
    SELECT
        *,
(
            SELECT
                array_agg(overlay(word PLACING UPPER(
                        LEFT (word, 1))
                FROM 1 FOR 1))
            FROM
                unnest(qry.wrd) AS word)
        FROM (
            SELECT
                content_id,
                content_text,
                string_to_array(content_text, ' ') wrd
            FROM
                user_content) AS qry);

SELECT
    content_id,
    content_text,
(
        SELECT
            (overlay(sentence PLACING UPPER(
                    LEFT (sentence, 1))
            FROM 1 FOR 1))
        FROM (
            SELECT
                *
            FROM (
                SELECT
                    unnest(wrd_array) AS dist_sent
                FROM
                    string_to_array(content_text, ' ') AS wrd_array) AS words) AS sentence)
FROM
    user_content;

SELECT
    content_id,
    content_text AS original_text,
(
        SELECT
            string_agg(UPPER(
                LEFT (word, 1)) || LOWER(SUBSTRING(word FROM 2)), ' ')
        FROM
            unnest(string_to_array(content_text, ' ', '-')) AS word) AS converted_text
FROM
    user_content;

-- Using Regex
SELECT
    regexp_split_to_array(content_text, '(?<= )|(?<=-)') AS wrd_array
FROM
    user_content;

-- Solution
SELECT
    content_id,
    content_text AS original_text,
(
        SELECT
            string_agg(UPPER(
                LEFT (word, 1)) || LOWER(SUBSTRING(word FROM 2)), '')
        FROM
            unnest(regexp_split_to_array(content_text, '(?<= )|(?<=-)')) AS word) AS converted_text
FROM
    user_content;




select regexp_split_to_array(content_text, '(?<= )|(?<=-)') AS word
from user_content;