const BuddhistFigure = require(
  '../models/buddhist-figure.model'
);

// Escape ký tự đặc biệt khi search bằng RegExp
function escapeRegex(value) {
  return value.replace(
    /[.*+?^${}()|[\]\\]/g,
    '\\$&'
  );
}

// ======================================================
// GET /api/buddhist-figures
// ======================================================
async function getBuddhistFigures(
  req,
  res
) {
  try {
    const {
      search,
      category,
      sort = 'name_asc',
    } = req.query;

    const filter = {
      status: 'active',
    };

    // Tìm kiếm tên
    if (
      search &&
      search.trim()
    ) {
      const keyword =
        escapeRegex(
          search.trim()
        );

      filter.$or = [
        {
          name: {
            $regex: keyword,
            $options: 'i',
          },
        },

        {
          sanskritName: {
            $regex: keyword,
            $options: 'i',
          },
        },

        {
          otherNames: {
            $regex: keyword,
            $options: 'i',
          },
        },
      ];
    }

    // Lọc category
    if (
      category &&
      category.trim()
    ) {
      filter.category =
        category
          .trim()
          .toLowerCase();
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
        break;
    }

    const figures =
      await BuddhistFigure.find(
        filter
      )
        .sort(sortOption)
        .lean();

    return res.status(200).json({
      success: true,
      count: figures.length,
      data: figures,
    });
  } catch (error) {
    console.error(
      'Get buddhist figures error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể tải danh sách các vị Phật/Bồ Tát.',
    });
  }
}

// ======================================================
// GET /api/buddhist-figures/:slug
// ======================================================
async function getBuddhistFigureBySlug(
  req,
  res
) {
  try {
    const slug =
      req.params.slug
        ?.trim()
        .toLowerCase();

    if (!slug) {
      return res.status(400).json({
        success: false,
        message:
          'Slug không hợp lệ.',
      });
    }

    const figure =
      await BuddhistFigure.findOne({
        slug,
        status: 'active',
      }).lean();

    if (!figure) {
      return res.status(404).json({
        success: false,
        message:
          'Không tìm thấy thông tin.',
      });
    }

    return res.status(200).json({
      success: true,
      data: figure,
    });
  } catch (error) {
    console.error(
      'Get buddhist figure error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể tải thông tin.',
    });
  }
}

module.exports = {
  getBuddhistFigures,
  getBuddhistFigureBySlug,
};