const express = require('express');
const cors = require('cors');
const path = require('path');
const scriptureRoutes =
  require('./routes/scripture.routes');

const calendarRoutes =
  require('./routes/calendar.routes');

const authRoutes =
  require('./routes/auth.routes');

const templeRoutes =
  require('./routes/temple.routes');  

const nfcRoutes =
  require('./routes/nfc.routes');

const pilgrimageRoutes =
  require('./routes/pilgrimage.routes');

const buddhistFigureRoutes =
  require('./routes/buddhist-figure.routes');
const app = express();
app.get('/api/health', (req, res) => {
  const ready = require('mongoose').connection.readyState === 1;
  res.status(ready ? 200 : 503).json({ success: ready });
});

app.use(cors());
app.use(express.json());
app.use('/api/quotes', require('./routes/quote.routes'));
app.use(
  '/api/auth',
  authRoutes
);
app.use(
  '/api/temples',
  templeRoutes
);
app.use(
  '/api/nfc',
  nfcRoutes
);
app.use(
  '/api/pilgrimage',
  pilgrimageRoutes
)
app.use(
  '/img',
  express.static(
    path.join(__dirname, '../img')
  )
);


app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Digital Pilgrimage API is running',
  });
});

app.use(
  '/api/scriptures',
  scriptureRoutes
);

app.use(
  '/api/calendar-events',
  calendarRoutes
);

app.use(
  '/api/buddhist-figures',
  buddhistFigureRoutes
);


module.exports = app;
