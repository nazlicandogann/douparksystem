INSERT INTO parking (location, total_spots)
SELECT 'A Blok', 100
WHERE NOT EXISTS (SELECT 1 FROM parking WHERE location = 'A Blok');

INSERT INTO parking (location, total_spots)
SELECT 'B Blok', 75
WHERE NOT EXISTS (SELECT 1 FROM parking WHERE location = 'B Blok');

INSERT INTO parking (location, total_spots)
SELECT 'Misafir', 35
WHERE NOT EXISTS (SELECT 1 FROM parking WHERE location = 'Misafir');