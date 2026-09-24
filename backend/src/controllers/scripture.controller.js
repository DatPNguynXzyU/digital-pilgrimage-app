const Scripture = require('../models/scripture.model');

async function getScriptures(req, res) {
  try {
    const scriptures = await Scripture.find()
      .sort({
        order: 1,
        title: 1,
      });

    res.status(200).json({
      success: true,
      count: scriptures.length,
      data: scriptures,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể tải kinh sách.',
      error: error.message,
    });
  }
}

async function getScriptureBySlug(req, res) {
  try {
    const scripture = await Scripture.findOne({
      slug: req.params.slug,
    });

    if (!scripture) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy kinh sách.',
      });
    }

    res.status(200).json({
      success: true,
      data: scripture,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Không thể tải kinh sách.',
      error: error.message,
    });
  }
}

module.exports = {
  getScriptures,
  getScriptureBySlug,
};