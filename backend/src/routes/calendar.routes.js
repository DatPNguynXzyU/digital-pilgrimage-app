const express = require('express');

const {
  getCalendarEvents,
  getCalendarEventById,
  createCalendarEvent,
  updateCalendarEvent,
  deleteCalendarEvent,
} = require('../controllers/calendar.controller');

const router = express.Router();

router.get('/', getCalendarEvents);
router.get('/:id', getCalendarEventById);
router.post('/', createCalendarEvent);
router.put('/:id', updateCalendarEvent);
router.delete('/:id', deleteCalendarEvent);

module.exports = router;