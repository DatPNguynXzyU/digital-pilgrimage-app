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
const { cache, rateLimit } = require('./middleware/redis.middleware');
const proxyHops = Number(process.env.TRUST_PROXY_HOPS || 0);
if (!Number.isInteger(proxyHops) || proxyHops < 0 || proxyHops > 5) throw new Error('Invalid TRUST_PROXY_HOPS');
app.set('trust proxy', proxyHops);
app.get('/api/health', (req, res) => {
  const ready = require('mongoose').connection.readyState === 1;
  res.status(ready ? 200 : 503).json({ success: ready });
});

app.use(cors());
const swaggerUi = require('swagger-ui-express');
const openapi = require('./config/openapi');
app.get('/api-docs.json', (req, res) => res.json(openapi));
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(openapi, {
  customSiteTitle: 'Hành Trình An Nhiên — API',
  swaggerOptions: { validatorUrl: null, persistAuthorization: false },
}));
app.use('/api', rateLimit('api', 120, 60));
app.use('/api/auth', (req, res, next) => {
  if (['POST', 'PUT'].includes(req.method) &&
      ['/login', '/register', '/firebase', '/change-password', '/firebase/change-password'].includes(req.path.toLowerCase().replace(/\/+$/, ''))) {
    return rateLimit('auth', 20, 300)(req, res, next);
  }
  next();
});
app.use('/api/temples', cache(60));
app.use('/api/scriptures', cache(60));
app.use(express.json());
app.use('/api/admin/nfc', require('./routes/nfc-admin.routes'));
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
