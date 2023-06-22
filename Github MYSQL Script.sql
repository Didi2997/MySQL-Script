-- SELECT THE "RECORD_COMPANY" DATABASE.
USE record_company;

-- ONLY DISPLAY ALBUMS RELEASED IN 2018 FROM THE "ALBUMS" TABLE.
SELECT *
FROM albums
WHERE release_year = 2018;

-- FIND THE OLDEST ALBUM
SELECT *
FROM albums
ORDER BY release_year ASC
LIMIT 1;

-- DURATION OF EACH ALBUM RELEASED BY 'VAN CANTO'.
SELECT als.name AS AlbumTitle, SUM(sg.length) AS AlbumDuration
FROM bands AS bs
JOIN albums AS als
ON bs.id = als.band_id
JOIN songs AS sg
ON als.id = sg.album_id
WHERE bs.name = 'Van Canto'
GROUP BY als.name
ORDER BY AlbumDuration DESC;

-- FIND THE BAND(S) WHO HAS YET TO RELEASE AN ALBUM.
SELECT b.name
FROM bands AS b
LEFT OUTER JOIN albums AS al
ON b.id = al.band_id
WHERE al.band_id IS NULL;

-- DISPLAY ALL THE SONGS FROM THE DATABASE RELEASED IN 2010 AS WELL AS THEIR PARENT ALBUMS
SELECT s.name AS SongName, a.name AS AlbumName
FROM albums AS a
JOIN songs AS s
ON a.id = s.album_id
WHERE a.release_year REGEXP 2010;

-- FIND THE 3RD LONGEST ALBUM (CONVERT THE ALBUM LENGTH FROM DECIMAL TO TIME FORMAT)
SELECT als.name, CAST(SEC_TO_TIME(SUM(sg.length)*60) AS TIME) AS AlbumDuration
FROM bands AS bs
JOIN albums AS als
ON bs.id = als.band_id
JOIN songs AS sg
ON als.id = sg.album_id
GROUP BY als.name
ORDER BY AlbumDuration DESC
LIMIT 1
OFFSET 2;

-- AVERAGE DURATION OF EACH ALBUM
SELECT a.name, CAST(SEC_TO_TIME(AVG(s.length)*60) AS TIME) AS AvgDurationInMins
FROM albums AS a
JOIN songs AS s
ON a.id = s.album_id
GROUP BY s.album_id;

-- COUNT AND CATEGORZE THE LIST OF ALBUMS INTO "EPs" AND "ALBUMS" BASED ON DURATION OF EACH ALBUM
-- ('ALBUMS' LESS THAN 30 MINUTES LONG WILL BE CLASSIFIED AS EPs WHILE ALBUMS 30 MINUTES OR LONGER WILL BE CLASSIFIED AS ALBUMS)
SELECT CT.Album_ID, CT.AlbumTitle, CT.LengthInMinutes, CT.Category,
COUNT(CT.Category) OVER(PARTITION BY CT.Category) AS CountOfEPs
FROM (SELECT al.id AS Album_ID, al.name AS AlbumTitle, 
SUM(ss.length) AS LengthInMinutes, 'EP' AS Category
FROM albums AS al
JOIN songs AS ss
ON al.id = ss.album_id
GROUP BY al.id
HAVING SUM(ss.length) < 30) AS CT
UNION ALL
SELECT CT.Album_ID, CT.AlbumTitle, CT.LengthInMinutes, CT.Category,
COUNT(CT.Category) OVER(PARTITION BY CT.Category) AS CountOfEPs
FROM (SELECT al.id AS Album_ID, al.name AS AlbumTitle, 
SUM(ss.length) AS LengthInMinutes, 'Album' AS Category
FROM albums AS al
JOIN songs AS ss
ON al.id = ss.album_id
GROUP BY al.id
HAVING SUM(ss.length) >= 30) AS CT;

-- EXTRACT THE TOP 30 LATEST SONGS FROM THE DATABASE USING THE IMPLICIT SYNTAX TO JOIN BOTH TABLES
SELECT so.name, am.release_year AS Year 
FROM songs AS so, albums AS am
WHERE so.album_id = am.id
ORDER BY Year DESC, so.length DESC
LIMIT 30;

-- RANK THE ALBUMS ACCORDING TO NUMBER OF SONGS ON EACH ALBUM
WITH CTE_AlbumRank AS
(SELECT am.name, COUNT(so.name) AS NumberOfSongs
FROM albums AS am
JOIN songs AS so
ON so.album_id = am.id
GROUP BY am.name)
SELECT *, DENSE_RANK() OVER(ORDER BY NumberOfSongs DESC) AS S_Rank
FROM CTE_AlbumRank;

-- DISPLAY THE LIST OF SONGS BY THE BANDS 'SICARIO' AND 'ALFIE AND THE HOOTERS'
SELECT s.name AS SongsBySicarioAndAATH
FROM songs AS s
JOIN albums AS a
ON s.album_id = a.id
JOIN bands AS b
ON a.band_id = b.id
WHERE b.name REGEXP 'Sicario|Alfie and the Hooters'
ORDER BY SongsBySicarioANdAATH ASC
