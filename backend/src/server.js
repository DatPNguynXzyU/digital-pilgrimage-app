require('dotenv').config();

const express = require('express');
const cors = require('cors');

const connectDatabase =
  require('./config/database');

const scriptureRoutes =
  require('./routes/scripture.routes');

const calendarRoutes =
  require('./routes/calendar.routes');

const app = express();

const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

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

async function startServer() {
  await connectDatabase();

  app.listen(PORT, () => {
    console.log(
      `Server running at http://localhost:${PORT}`
    );
  });
}

startServer();