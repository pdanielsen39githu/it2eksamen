const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const session = require('express-session');
const path = require('path');

const app = express();

// ─── DATABASE ───────────────────────────────────────────────
const pool = new Pool({
  host: '10.10.10.20',   // << BYTT TIL DIN POSTGRES VM IP
  port: 5432,
  database: 'vindil',
  user: 'postgres',
  password: 'dittpassord', // << BYTT
});

// ─── MIDDLEWARE ──────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'vindil-super-secret-2026',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 1000 * 60 * 60 * 8 }
}));

// ─── AUTH MIDDLEWARE ─────────────────────────────────────────
function requireAuth(req, res, next) {
  if (!req.session.user) return res.status(401).json({ error: 'Ikke innlogget' });
  next();
}
function requireAdmin(req, res, next) {
  if (!req.session.user || req.session.user.rolle !== 'admin') return res.status(403).json({ error: 'Ingen tilgang' });
  next();
}

// ─── ROUTES: AUTH ────────────────────────────────────────────
app.post('/api/login', async (req, res) => {
  const { brukernavn, passord } = req.body;
  try {
    const r = await pool.query('SELECT * FROM bruker WHERE brukernavn = $1', [brukernavn]);
    if (!r.rows.length) return res.status(401).json({ error: 'Feil brukernavn eller passord' });
    const user = r.rows[0];
    const ok = await bcrypt.compare(passord, user.passord_hash);
    if (!ok) return res.status(401).json({ error: 'Feil brukernavn eller passord' });
    req.session.user = { id: user.bruker_id, brukernavn: user.brukernavn, rolle: user.rolle };
    res.json({ ok: true, rolle: user.rolle });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/logout', (req, res) => {
  req.session.destroy();
  res.json({ ok: true });
});

app.get('/api/me', (req, res) => {
  res.json(req.session.user || null);
});

// ─── ROUTES: PUBLIC (kampoppsett + resultater) ───────────────
app.get('/api/turneringer', async (req, res) => {
  const r = await pool.query('SELECT * FROM turnering ORDER BY startdato DESC');
  res.json(r.rows);
});

app.get('/api/turneringer/:id/kamper', async (req, res) => {
  const r = await pool.query(`
    SELECT k.*, 
      l1.lagnavn AS lag1_navn, l2.lagnavn AS lag2_navn
    FROM kamp k
    JOIN lag l1 ON k.lag1_id = l1.lag_id
    JOIN lag l2 ON k.lag2_id = l2.lag_id
    WHERE k.turnering_id = $1
    ORDER BY k.tidspunkt ASC
  `, [req.params.id]);
  res.json(r.rows);
});

app.get('/api/turneringer/:id/lag', async (req, res) => {
  const r = await pool.query('SELECT * FROM lag WHERE turnering_id = $1', [req.params.id]);
  res.json(r.rows);
});

app.get('/api/lag/:id/deltakere', async (req, res) => {
  const r = await pool.query(
    'SELECT fornavn, etternavn FROM deltaker WHERE lag_id = $1',
    [req.params.id]
  );
  res.json(r.rows);
});

// ─── ROUTES: LAGLEDER ────────────────────────────────────────
app.post('/api/lag', requireAuth, async (req, res) => {
  const { lagnavn, idrett, turnering_id } = req.body;
  try {
    const r = await pool.query(
      'INSERT INTO lag (lagnavn, idrett, lagleder_id, turnering_id) VALUES ($1,$2,$3,$4) RETURNING *',
      [lagnavn, idrett, req.session.user.id, turnering_id]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/deltakere', requireAuth, async (req, res) => {
  const { fornavn, etternavn, fodselsdato, epost, lag_id } = req.body;
  try {
    const r = await pool.query(
      'INSERT INTO deltaker (fornavn, etternavn, fodselsdato, epost, lag_id) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [fornavn, etternavn, fodselsdato, epost, lag_id]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/kamper/:id/resultat', requireAuth, async (req, res) => {
  const { resultat_lag1, resultat_lag2 } = req.body;
  try {
    const r = await pool.query(
      'UPDATE kamp SET resultat_lag1=$1, resultat_lag2=$2, status=$3 WHERE kamp_id=$4 RETURNING *',
      [resultat_lag1, resultat_lag2, 'ferdig', req.params.id]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── ROUTES: ADMIN ───────────────────────────────────────────
app.post('/api/admin/turneringer', requireAdmin, async (req, res) => {
  const { navn, idrett, startdato, sluttdato, beskrivelse } = req.body;
  try {
    const r = await pool.query(
      'INSERT INTO turnering (navn, idrett, startdato, sluttdato, beskrivelse) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [navn, idrett, startdato, sluttdato, beskrivelse]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/admin/kamper', requireAdmin, async (req, res) => {
  const { turnering_id, lag1_id, lag2_id, tidspunkt, sted } = req.body;
  try {
    const r = await pool.query(
      'INSERT INTO kamp (turnering_id, lag1_id, lag2_id, tidspunkt, sted) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [turnering_id, lag1_id, lag2_id, tidspunkt, sted]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/admin/brukere', requireAdmin, async (req, res) => {
  const { brukernavn, passord, rolle, epost } = req.body;
  try {
    const hash = await bcrypt.hash(passord, 10);
    const r = await pool.query(
      'INSERT INTO bruker (brukernavn, passord_hash, rolle, epost) VALUES ($1,$2,$3,$4) RETURNING bruker_id, brukernavn, rolle, epost',
      [brukernavn, hash, rolle, epost]
    );
    res.json(r.rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/admin/brukere', requireAdmin, async (req, res) => {
  const r = await pool.query('SELECT bruker_id, brukernavn, rolle, epost FROM bruker');
  res.json(r.rows);
});

app.get('/api/admin/stats', requireAdmin, async (req, res) => {
  const [t, l, d, k] = await Promise.all([
    pool.query('SELECT COUNT(*) FROM turnering'),
    pool.query('SELECT COUNT(*) FROM lag'),
    pool.query('SELECT COUNT(*) FROM deltaker'),
    pool.query('SELECT COUNT(*) FROM kamp'),
  ]);
  res.json({
    turneringer: t.rows[0].count,
    lag: l.rows[0].count,
    deltakere: d.rows[0].count,
    kamper: k.rows[0].count,
  });
});

// ─── SERVE FRONTEND ──────────────────────────────────────────
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(3000, () => console.log('Vind IL kjører på port 3000'));
