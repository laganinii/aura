// Aura Server — privacy-first local backend
//
// Design principles:
//  - Local-first: runs on your own machine, stores everything in a single
//    JSON file under ./data. No external services, no telemetry.
//  - Minimal data: only what you check in. No raw device signals.
//  - Token auth: a bearer token is minted on first "handshake" and stored
//    client-side. No passwords, no accounts.
//
// Endpoints:
//   POST /api/handshake            -> { token, profile }        (mint or reuse)
//   GET  /api/profile              -> profile                   (auth)
//   PUT  /api/profile              -> profile                   (auth)
//   POST /api/checkins             -> checkin                   (auth)
//   GET  /api/checkins?days=30     -> [checkins]                (auth)
//   GET  /api/summary?days=7       -> life-weather summary      (auth)
//   GET  /api/export               -> full JSON export          (auth)
//   DELETE /api/data               -> wipe everything for token (auth)

import express from 'express';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = path.join(__dirname, 'data');
const DATA_FILE = path.join(DATA_DIR, 'aura.json');
const PORT = process.env.PORT || 8741;

// ---------------------------------------------------------------- storage

function loadStore() {
  try {
    return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  } catch {
    return { users: {} };
  }
}

function saveStore(store) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  const tmp = DATA_FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(store, null, 2));
  fs.renameSync(tmp, DATA_FILE);
}

const store = loadStore();

function getUser(token) {
  return store.users[token];
}

function createUser(name) {
  const token = 'aura_' + crypto.randomBytes(24).toString('hex');
  store.users[token] = {
    profile: {
      name: name || 'friend',
      createdAt: new Date().toISOString(),
      settings: {
        reminderTime: '21:00',
        theme: 'auto',
        shareAggregates: false
      }
    },
    checkins: []
  };
  saveStore(store);
  return token;
}

// ------------------------------------------------------- weather inference

const STATES = ['flowing', 'settled', 'stirring', 'hushed', 'drifting'];

function inferState({ mood, energy, sleep }) {
  if (sleep >= 7.5 && energy <= 4 && mood <= 5) return 'hushed';
  if (energy >= 7 && mood >= 7) return 'flowing';
  if (energy >= 6 && mood < 7) return 'stirring';
  if (sleep >= 7 && energy < 6 && mood >= 5) return 'settled';
  if (energy < 4) return 'hushed';
  return 'drifting';
}

const STATE_DESCRIPTIONS = {
  flowing: 'A warm, creative current. Good for deep work.',
  settled: 'Grounded and clear. Gentle productivity.',
  stirring: 'Energy rising. Ideas are close to the surface.',
  hushed: 'Quiet, restorative. Protect this space.',
  drifting: 'Diffuse attention. Good for wandering and noticing.'
};

function buildSummary(checkins, days) {
  const cutoff = Date.now() - days * 86400000;
  const recent = checkins.filter(c => new Date(c.date).getTime() >= cutoff);

  if (recent.length === 0) {
    return {
      days,
      count: 0,
      state: 'drifting',
      headline: 'The ecosystem is quiet.',
      body: 'No check-ins yet in this window. A single gentle note each day is enough for the weather to form.',
      averages: null,
      streak: computeStreak(checkins),
      distribution: {}
    };
  }

  const avg = key => recent.reduce((s, c) => s + (c[key] || 0), 0) / recent.length;
  const averages = {
    mood: round1(avg('mood')),
    energy: round1(avg('energy')),
    sleep: round1(avg('sleep'))
  };

  const distribution = {};
  for (const c of recent) {
    distribution[c.state] = (distribution[c.state] || 0) + 1;
  }

  const dominant = Object.entries(distribution).sort((a, b) => b[1] - a[1])[0][0];
  const streak = computeStreak(checkins);

  const headline = streak >= 7
    ? `Mostly ${dominant}, with a ${streak}-day streak of tending to yourself.`
    : `Mostly ${dominant} lately.`;

  const sleepNote = averages.sleep < 6.5
    ? ' Sleep has been light — the ecosystem is asking for an earlier dusk.'
    : averages.sleep >= 7.5
      ? ' Sleep has been deep and restorative.'
      : '';

  const energyNote = averages.energy >= 7
    ? ' Energy is running warm; good days for deep work.'
    : averages.energy < 5
      ? ' Energy is low — protect slow mornings where you can.'
      : '';

  return {
    days,
    count: recent.length,
    state: dominant,
    headline,
    body: (STATE_DESCRIPTIONS[dominant] || '') + sleepNote + energyNote,
    averages,
    streak,
    distribution
  };
}

function computeStreak(checkins) {
  const days = new Set(checkins.map(c => c.date.slice(0, 10)));
  let streak = 0;
  const d = new Date();
  // allow the streak to start today or yesterday
  if (!days.has(isoDay(d))) d.setDate(d.getDate() - 1);
  while (days.has(isoDay(d))) {
    streak++;
    d.setDate(d.getDate() - 1);
  }
  return streak;
}

function isoDay(d) {
  return d.toISOString().slice(0, 10);
}

function round1(n) {
  return Math.round(n * 10) / 10;
}

// ------------------------------------------------------------------- app

const app = express();
app.use(express.json({ limit: '256kb' }));

// Tiny CORS for local-first usage (web app opened from file:// or localhost)
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token || !getUser(token)) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  req.token = token;
  req.user = getUser(token);
  next();
}

app.get('/api/health', (req, res) => {
  res.json({ ok: true, service: 'aura-server', time: new Date().toISOString() });
});

app.post('/api/handshake', (req, res) => {
  const { token, name } = req.body || {};
  if (token && getUser(token)) {
    return res.json({ token, profile: getUser(token).profile });
  }
  const newToken = createUser(name);
  res.status(201).json({ token: newToken, profile: getUser(newToken).profile });
});

app.get('/api/profile', auth, (req, res) => {
  res.json(req.user.profile);
});

app.put('/api/profile', auth, (req, res) => {
  const body = req.body || {};
  req.user.profile = {
    ...req.user.profile,
    ...(body.name ? { name: String(body.name).slice(0, 80) } : {}),
    settings: { ...req.user.profile.settings, ...(body.settings || {}) }
  };
  saveStore(store);
  res.json(req.user.profile);
});

app.post('/api/checkins', auth, (req, res) => {
  const { mood, energy, sleep, note } = req.body || {};
  const m = clamp(mood, 1, 10);
  const e = clamp(energy, 1, 10);
  const s = clamp(sleep, 0, 16);
  if (m === null || e === null || s === null) {
    return res.status(400).json({ error: 'mood (1-10), energy (1-10) and sleep (0-16 hours) are required' });
  }

  const checkin = {
    id: crypto.randomUUID(),
    date: new Date().toISOString(),
    mood: m,
    energy: e,
    sleep: s,
    note: typeof note === 'string' ? note.slice(0, 500) : '',
    state: inferState({ mood: m, energy: e, sleep: s })
  };

  // one check-in per day — replace today's if it exists
  const today = checkin.date.slice(0, 10);
  req.user.checkins = req.user.checkins.filter(c => c.date.slice(0, 10) !== today);
  req.user.checkins.push(checkin);
  req.user.checkins.sort((a, b) => a.date.localeCompare(b.date));
  saveStore(store);
  res.status(201).json(checkin);
});

app.get('/api/checkins', auth, (req, res) => {
  const days = Math.min(parseInt(req.query.days, 10) || 90, 730);
  const cutoff = Date.now() - days * 86400000;
  res.json(req.user.checkins.filter(c => new Date(c.date).getTime() >= cutoff));
});

app.get('/api/summary', auth, (req, res) => {
  const days = Math.min(parseInt(req.query.days, 10) || 7, 365);
  res.json(buildSummary(req.user.checkins, days));
});

app.get('/api/export', auth, (req, res) => {
  res.setHeader('Content-Disposition', 'attachment; filename="aura-export.json"');
  res.json({
    exportedAt: new Date().toISOString(),
    profile: req.user.profile,
    checkins: req.user.checkins
  });
});

app.delete('/api/data', auth, (req, res) => {
  delete store.users[req.token];
  saveStore(store);
  res.json({ ok: true, deleted: true });
});

function clamp(v, min, max) {
  const n = Number(v);
  if (!Number.isFinite(n)) return null;
  return Math.max(min, Math.min(max, n));
}

// Web demo (marketing UI) — default port 8741 so it doesn't collide with
// moodboard (3000) or Contractor OS (3001)
const WEB_DIR = path.join(__dirname, '..', 'web');
app.use(express.static(WEB_DIR));
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api/')) return next();
  res.sendFile(path.join(WEB_DIR, 'index.html'), (err) => {
    if (err) next();
  });
});

app.listen(PORT, () => {
  console.log(`Aura server listening on http://localhost:${PORT}`);
  console.log('Local-first. No telemetry. Data lives in ./data/aura.json');
});
