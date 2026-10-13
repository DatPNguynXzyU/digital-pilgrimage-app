const mongoose = require('mongoose');

const PilgrimageVisit = require(
  '../models/pilgrimage-visit.model'
);

const TempleStamp = require(
  '../models/temple-stamp.model'
);

// ======================================================
// GET /api/pilgrimage/history
// Lịch sử viếng chùa
// ======================================================
async function getVisitHistory(req, res) {
  try {
    const userId = req.user._id;

    const {
      sort = 'recent',
    } = req.query;

    let sortOption = {
      visitDate: -1,
    };

    if (sort === 'oldest') {
      sortOption = {
        visitDate: 1,
      };
    }

    const visits =
      await PilgrimageVisit.find({
        userId,
      })
        .populate({
          path: 'templeId',

          select: [
            'name',
            'slug',
            'thumbnail',
            'address',
          ].join(' '),
        })
        .sort(sortOption)
        .lean();

    const data = visits.map(
      (visit) => ({
        id: visit._id,

        temple: visit.templeId,

        visitDate:
          visit.visitDate,

        note:
          visit.note || '',
      })
    );

    return res.status(200).json({
      success: true,
      count: data.length,
      data,
    });
  } catch (error) {
    console.error(
      'Get visit history error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể tải lịch sử viếng chùa.',
    });
  }
}

// ======================================================
// GET /api/pilgrimage/temples
//
// Chùa user đã đi
//
// sort:
// most_visited
// least_visited
// recent
// name_asc
// name_desc
// ======================================================
async function getVisitedTemples(
  req,
  res
) {
  try {
    const userId =
      new mongoose.Types.ObjectId(
        req.user._id
      );

    const {
      sort = 'most_visited',
    } = req.query;

    const pipeline = [
      // Chỉ lấy visit của user
      {
        $match: {
          userId,
        },
      },

      // Gom theo chùa
      {
        $group: {
          _id: '$templeId',

          visitCount: {
            $sum: 1,
          },

          firstVisitedAt: {
            $min: '$visitDate',
          },

          lastVisitedAt: {
            $max: '$visitDate',
          },
        },
      },

      // Lấy thông tin chùa
      {
        $lookup: {
          from: 'temples',

          localField: '_id',

          foreignField: '_id',

          as: 'temple',
        },
      },

      {
        $unwind: '$temple',
      },

      // Chỉ lấy chùa đang active
      {
        $match: {
          'temple.status':
            'active',
        },
      },
    ];

    // ==========================
    // SORT
    // ==========================
    switch (sort) {
      case 'least_visited':
        pipeline.push({
          $sort: {
            visitCount: 1,
            lastVisitedAt: -1,
          },
        });
        break;

      case 'recent':
        pipeline.push({
          $sort: {
            lastVisitedAt: -1,
          },
        });
        break;

      case 'name_asc':
        pipeline.push({
          $sort: {
            'temple.name': 1,
          },
        });
        break;

      case 'name_desc':
        pipeline.push({
          $sort: {
            'temple.name': -1,
          },
        });
        break;

      case 'most_visited':
      default:
        pipeline.push({
          $sort: {
            visitCount: -1,
            lastVisitedAt: -1,
          },
        });
        break;
    }

    // Chỉ trả field cần thiết
    pipeline.push({
      $project: {
        _id: 0,

        temple: {
          id: '$temple._id',
          name: '$temple.name',
          slug: '$temple.slug',

          thumbnail:
            '$temple.thumbnail',

          address:
            '$temple.address',
        },

        visitCount: 1,

        firstVisitedAt: 1,

        lastVisitedAt: 1,
      },
    });

    const data =
      await PilgrimageVisit.aggregate(
        pipeline
      );

    return res.status(200).json({
      success: true,
      count: data.length,
      data,
    });
  } catch (error) {
    console.error(
      'Get visited temples error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Không thể tải danh sách chùa đã viếng.',
    });
  }
}

// ======================================================
// GET /api/pilgrimage/stats
// Thống kê tài khoản
// ======================================================
async function getPilgrimageStats(
  req,
  res
) {
  try {
    const userId =
      new mongoose.Types.ObjectId(
        req.user._id
      );

    const stats =
      await PilgrimageVisit.aggregate([
        {
          $match: {
            userId,
          },
        },

        {
          $group: {
            _id: null,

            totalVisits: {
              $sum: 1,
            },

            temples: {
              $addToSet:
                '$templeId',
            },
          },
        },

        {
          $project: {
            _id: 0,

            totalVisits: 1,

            uniqueTemples: {
              $size: '$temples',
            },
          },
        },
      ]);

    const stampCount =
      await TempleStamp.countDocuments({
        userId,
      });

    // ==========================
    // CHÙA ĐI NHIỀU NHẤT
    // ==========================
    const mostVisited =
      await PilgrimageVisit.aggregate([
        {
          $match: {
            userId,
          },
        },

        {
          $group: {
            _id: '$templeId',

            visitCount: {
              $sum: 1,
            },

            lastVisitedAt: {
              $max: '$visitDate',
            },
          },
        },

        {
          $sort: {
            visitCount: -1,
            lastVisitedAt: -1,
          },
        },

        {
          $limit: 1,
        },

        {
          $lookup: {
            from: 'temples',

            localField: '_id',

            foreignField: '_id',

            as: 'temple',
          },
        },

        {
          $unwind: '$temple',
        },

        {
          $project: {
            _id: 0,

            temple: {
              id:
                '$temple._id',

              name:
                '$temple.name',

              slug:
                '$temple.slug',

              thumbnail:
                '$temple.thumbnail',
            },

            visitCount: 1,

            lastVisitedAt: 1,
          },
        },
      ]);

    const baseStats =
      stats[0] || {
        totalVisits: 0,
        uniqueTemples: 0,
      };

    return res.status(200).json({
      success: true,

      data: {
        totalVisits:
          baseStats.totalVisits,

        uniqueTemples:
          baseStats.uniqueTemples,

        totalStamps:
          stampCount,

        mostVisitedTemple:
          mostVisited[0] ||
          null,
      },
    });
  } catch (error) {
    console.error(
      'Get pilgrimage stats error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Không thể tải thống kê hành hương.',
    });
  }
}
// ======================================================
// GET /api/pilgrimage/stamps
// Sổ tem điện tử của user
// ======================================================
async function getTempleStamps(req, res) {
  try {
    const userId = req.user._id;

    const stamps =
      await TempleStamp.find({
        userId,
      })
        .populate({
          path: 'templeId',
          select: [
            'name',
            'slug',
            'thumbnail',
            'address',
            'description',
          ].join(' '),
        })
        .sort({
          receivedAt: -1,
        })
        .lean();

    const data = stamps
      .filter(
        (stamp) => stamp.templeId
      )
      .map(
        (stamp) => ({
          id: stamp._id,

          receivedAt:
            stamp.receivedAt,

          temple: {
            id:
              stamp.templeId._id,

            name:
              stamp.templeId.name,

            slug:
              stamp.templeId.slug,

            thumbnail:
              stamp.templeId
                  .thumbnail,

            address:
              stamp.templeId.address,

            description:
              stamp.templeId
                  .description,
          },
        })
      );

    return res.status(200).json({
      success: true,
      count: data.length,
      data,
    });
  } catch (error) {
    console.error(
      'Get temple stamps error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Không thể tải sổ tem điện tử.',
    });
  }
}

module.exports = {
  getVisitHistory,
  getVisitedTemples,
  getPilgrimageStats,
  getTempleStamps,
};