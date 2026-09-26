let calendarEvents = [
  {
    id: '1',
    title: 'Tụng Kinh Phổ Môn',
    date: '2026-09-26',
    time: '19:00',
    location: 'Tại nhà',
    type: 'scripture',
  },
  {
    id: '2',
    title: 'Thiền 15 phút',
    date: '2026-09-26',
    time: '21:00',
    location: 'Cá nhân',
    type: 'meditation',
  },
  {
    id: '3',
    title: 'Viếng chùa',
    date: '2026-09-28',
    time: '08:00',
    location: 'Chùa đã lưu',
    type: 'temple',
  },
];


// GET /api/calendar-events
async function getCalendarEvents(req, res) {
  try {
    const { date } = req.query;

    let result = calendarEvents;

    if (date) {
      result = calendarEvents.filter(
        (event) => event.date === date
      );
    }

    res.status(200).json({
      success: true,
      count: result.length,
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể tải lịch.',
      error: error.message,
    });
  }
}


// GET /api/calendar-events/:id
async function getCalendarEventById(req, res) {
  try {
    const event = calendarEvents.find(
      (item) => item.id === req.params.id
    );

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch.',
      });
    }

    res.status(200).json({
      success: true,
      data: event,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể tải lịch.',
      error: error.message,
    });
  }
}


// POST /api/calendar-events
async function createCalendarEvent(req, res) {
  try {
    const {
      title,
      date,
      time,
      location,
      type,
    } = req.body;

    if (!title || !date) {
      return res.status(400).json({
        success: false,
        message: 'Tên hoạt động và ngày là bắt buộc.',
      });
    }

    const newEvent = {
      id: Date.now().toString(),
      title: title.trim(),
      date,
      time: time || '',
      location: location || '',
      type: type || 'other',
    };

    calendarEvents.push(newEvent);

    res.status(201).json({
      success: true,
      message: 'Thêm lịch thành công.',
      data: newEvent,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể thêm lịch.',
      error: error.message,
    });
  }
}


// PUT /api/calendar-events/:id
async function updateCalendarEvent(req, res) {
  try {
    const index = calendarEvents.findIndex(
      (item) => item.id === req.params.id
    );

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch.',
      });
    }

    const oldEvent = calendarEvents[index];

    calendarEvents[index] = {
      ...oldEvent,
      ...req.body,
      id: oldEvent.id,
    };

    res.status(200).json({
      success: true,
      message: 'Cập nhật lịch thành công.',
      data: calendarEvents[index],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể cập nhật lịch.',
      error: error.message,
    });
  }
}


// DELETE /api/calendar-events/:id
async function deleteCalendarEvent(req, res) {
  try {
    const index = calendarEvents.findIndex(
      (item) => item.id === req.params.id
    );

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch.',
      });
    }

    const deletedEvent = calendarEvents[index];

    calendarEvents.splice(index, 1);

    res.status(200).json({
      success: true,
      message: 'Xóa lịch thành công.',
      data: deletedEvent,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể xóa lịch.',
      error: error.message,
    });
  }
}


module.exports = {
  getCalendarEvents,
  getCalendarEventById,
  createCalendarEvent,
  updateCalendarEvent,
  deleteCalendarEvent,
};