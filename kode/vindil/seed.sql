-- ═══════════════════════════════════════════
-- VIND IL – TESTDATA
-- Kjør i psql: \i seed.sql
-- ═══════════════════════════════════════════

-- Brukere (passord er 'passord123' for alle)
INSERT INTO bruker (brukernavn, passord_hash, rolle, epost) VALUES
('admin',     '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',    'admin@vindil.no'),
('lagleder1', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'lagleder', 'lag1@vindil.no'),
('lagleder2', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'lagleder', 'lag2@vindil.no'),
('lagleder3', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'lagleder', 'lag3@vindil.no');

-- OBS: passordet over er "password" (bcrypt). Bytt til ekte hash ved produksjon.
-- Generer riktig hash med: node -e "const b=require('bcrypt');b.hash('passord123',10).then(console.log)"

-- Turneringer
INSERT INTO turnering (navn, idrett, startdato, sluttdato, beskrivelse) VALUES
('Vårturneringen 2026',    'Fotball',   '2026-05-10', '2026-05-12', 'Årets store fotballturnering på Jessheim'),
('Sommercup Håndball',     'Håndball',  '2026-06-01', '2026-06-03', 'Håndballturnering for alle aldersgrupper'),
('Ungdomscup 2026',        'Volleyball','2026-07-15', '2026-07-17', 'Turnering for spillere under 18 år');

-- Lag (fotball)
INSERT INTO lag (lagnavn, idrett, lagleder_id, turnering_id) VALUES
('Jessheim FK A',     'Fotball', 2, 1),
('Jessheim FK B',     'Fotball', 2, 1),
('Kløfta IL',         'Fotball', 3, 1),
('Nannestad SK',      'Fotball', 3, 1),
('Gardermoen FK',     'Fotball', 4, 1),
('Dal IL',            'Fotball', 4, 1);

-- Lag (håndball)
INSERT INTO lag (lagnavn, idrett, lagleder_id, turnering_id) VALUES
('Jessheim HK A',     'Håndball', 2, 2),
('Jessheim HK B',     'Håndball', 3, 2),
('Kløfta HK',         'Håndball', 4, 2),
('Nannestad HK',      'Håndball', 2, 2);

-- Lag (volleyball)
INSERT INTO lag (lagnavn, idrett, lagleder_id, turnering_id) VALUES
('Jessheim VK',       'Volleyball', 3, 3),
('Kløfta Spikes',     'Volleyball', 4, 3),
('Gardermoen Aces',   'Volleyball', 2, 3);

-- Deltakere (fotball lag 1 - Jessheim FK A)
INSERT INTO deltaker (fornavn, etternavn, fodselsdato, epost, lag_id) VALUES
('Magnus',   'Olsen',    '2005-03-12', 'magnus@mail.no',   1),
('Erik',     'Hansen',   '2006-07-22', 'erik@mail.no',     1),
('Tobias',   'Johansen', '2005-11-08', 'tobias@mail.no',   1),
('Lars',     'Nilsen',   '2006-02-14', 'lars@mail.no',     1),
('Henrik',   'Andersen', '2005-09-30', 'henrik@mail.no',   1),
('Mats',     'Pedersen', '2006-04-17', 'mats@mail.no',     1),
('Jonas',    'Kristiansen','2005-01-25','jonas@mail.no',   1),
('Sander',   'Berg',     '2006-08-11', 'sander@mail.no',   1),
('Oliver',   'Dahl',     '2005-06-03', 'oliver@mail.no',   1),
('Markus',   'Halvorsen','2006-12-19', 'markus@mail.no',   1),
('Andreas',  'Lund',     '2005-05-28', 'andreas@mail.no',  1);

-- Deltakere (fotball lag 2 - Jessheim FK B)
INSERT INTO deltaker (fornavn, etternavn, fodselsdato, epost, lag_id) VALUES
('Nora',     'Eriksen',  '2007-04-15', 'nora@mail.no',     2),
('Emma',     'Haugen',   '2007-08-22', 'emma@mail.no',     2),
('Sofie',    'Moen',     '2008-01-09', 'sofie@mail.no',    2),
('Ida',      'Strom',    '2007-11-30', 'ida@mail.no',      2),
('Sara',     'Bakke',    '2008-03-17', 'sara@mail.no',     2);

-- Kamper fotball (gruppe + ferdigspilte)
INSERT INTO kamp (turnering_id, lag1_id, lag2_id, tidspunkt, sted, resultat_lag1, resultat_lag2, status) VALUES
-- Ferdigspilte
(1, 1, 2, '2026-05-10 10:00:00', 'Jessheim Stadion', 3, 1, 'ferdig'),
(1, 3, 4, '2026-05-10 10:00:00', 'Kløfta Idrettsplass', 2, 2, 'ferdig'),
(1, 5, 6, '2026-05-10 10:00:00', 'Gardermoen Bane', 4, 0, 'ferdig'),
(1, 1, 3, '2026-05-10 13:00:00', 'Jessheim Stadion', 1, 1, 'ferdig'),
(1, 2, 5, '2026-05-10 13:00:00', 'Kløfta Idrettsplass', 0, 2, 'ferdig'),
(1, 4, 6, '2026-05-10 13:00:00', 'Gardermoen Bane', 3, 1, 'ferdig'),
(1, 1, 4, '2026-05-11 10:00:00', 'Jessheim Stadion', 2, 0, 'ferdig'),
(1, 2, 6, '2026-05-11 10:00:00', 'Kløfta Idrettsplass', 1, 1, 'ferdig'),
(1, 3, 5, '2026-05-11 10:00:00', 'Gardermoen Bane', 0, 3, 'ferdig'),
-- Planlagte (semifinaler og finale)
(1, 1, 5, '2026-05-11 14:00:00', 'Jessheim Stadion', 0, 0, 'planlagt'),
(1, 4, 2, '2026-05-11 14:00:00', 'Jessheim Stadion', 0, 0, 'planlagt'),
(1, 1, 4, '2026-05-12 12:00:00', 'Jessheim Stadion', 0, 0, 'planlagt');

-- Kamper håndball
INSERT INTO kamp (turnering_id, lag1_id, lag2_id, tidspunkt, sted, resultat_lag1, resultat_lag2, status) VALUES
(2, 7,  8,  '2026-06-01 10:00:00', 'Jessheim Idrettshall', 24, 19, 'ferdig'),
(2, 9,  10, '2026-06-01 10:00:00', 'Kløfta Idrettshall',   21, 23, 'ferdig'),
(2, 7,  9,  '2026-06-01 13:00:00', 'Jessheim Idrettshall', 28, 22, 'ferdig'),
(2, 8,  10, '2026-06-01 13:00:00', 'Kløfta Idrettshall',   17, 20, 'ferdig'),
(2, 7,  10, '2026-06-02 11:00:00', 'Jessheim Idrettshall', 0,  0,  'planlagt'),
(2, 8,  9,  '2026-06-02 11:00:00', 'Kløfta Idrettshall',   0,  0,  'planlagt');

-- Kamper volleyball
INSERT INTO kamp (turnering_id, lag1_id, lag2_id, tidspunkt, sted, resultat_lag1, resultat_lag2, status) VALUES
(3, 11, 12, '2026-07-15 10:00:00', 'Jessheim Sportssenter', 3, 1, 'ferdig'),
(3, 12, 13, '2026-07-15 12:00:00', 'Jessheim Sportssenter', 2, 3, 'ferdig'),
(3, 11, 13, '2026-07-15 14:00:00', 'Jessheim Sportssenter', 3, 0, 'ferdig'),
(3, 11, 12, '2026-07-16 11:00:00', 'Jessheim Sportssenter', 0, 0, 'planlagt');

-- Verifiser:
SELECT 'Brukere:' AS type, COUNT(*) FROM bruker
UNION ALL SELECT 'Turneringer:', COUNT(*) FROM turnering
UNION ALL SELECT 'Lag:', COUNT(*) FROM lag
UNION ALL SELECT 'Deltakere:', COUNT(*) FROM deltaker
UNION ALL SELECT 'Kamper:', COUNT(*) FROM kamp;
