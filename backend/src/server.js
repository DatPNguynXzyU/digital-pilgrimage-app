require('dotenv').config();
const app = require('./app');
const connectDatabase = require('./config/database');
async function startServer() {
  if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET chưa được cấu hình.');
  await connectDatabase();
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log('Server listening on port ' + port));
}
startServer().catch(error => { console.error(error.message); process.exitCode = 1; });
