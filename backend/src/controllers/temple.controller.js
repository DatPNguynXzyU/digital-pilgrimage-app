const Temple = require('../models/temple.model');

// GET /api/temples
async function getTemples(req, res) {
  try {
    const {
      search,
      sort = 'name_asc',
      featured,
    } = req.query;

    const filter = {
      status: 'active',
    };

    if (search) {
      filter.$text = {
        $search: search,
      };
    }

    if (featured === 'true') {
      filter.isFeatured = true;
    }

    let sortOption = {
      name: 1,
    };

    switch (sort) {
      case 'name_desc':
        sortOption = {
          name: -1,
        };
        break;

      case 'newest':
        sortOption = {
          createdAt: -1,
        };
        break;

      case 'name_asc':
      default:
        sortOption = {
          name: 1,
        };
    }

    const temples = await Temple.find(filter)
      .sort(sortOption)
      .lean();

    return res.json({
      success: true,
      total: temples.length,
      data: temples,
    });
  } catch (error) {
    console.error(
      'Get temples error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể lấy danh sách chùa.',
    });
  }
}

async function getTempleById(req, res) {
  try {
    const temple = await Temple.findOne({
      _id: req.params.id,
      status: 'active',
    }).lean();

    if (!temple) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chùa.',
      });
    }

    return res.status(200).json({
      success: true,
      data: temple,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: 'ID chùa không hợp lệ.',
    });
  }
}

// GET /api/temples/:slug
async function getTempleBySlug(req, res) {
  try {
    const temple =
      await Temple.findOne({
        slug: req.params.slug,
        status: 'active',
      }).lean();

    if (!temple) {
      return res.status(404).json({
        success: false,
        message:
          'Không tìm thấy chùa.',
      });
    }

    return res.json({
      success: true,
      data: temple,
    });
  } catch (error) {
    console.error(
      'Get temple detail error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể lấy thông tin chùa.',
    });
  }
}


module.exports = {
  getTemples,
  getTempleBySlug,
  getTempleById,
};