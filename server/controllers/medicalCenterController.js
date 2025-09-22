const MedicalCenter = require("../models/MedicalCenter");

//* Add a new medical center
const addMedicalCenter = async (req, res) => {
  try {
    const {
      name,
      address,
      phoneNumber,
      location,
      acceptedMedicineTypes,
      operatingHours,
      facilityType,
      website,
      email,
      specialServices,
    } = req.body;

    if (!name || !address || !phoneNumber || !location) {
      return res.status(400).json({
        statusCode: 400,
        message:
          "Name, address, phone number, and location coordinates are required",
      });
    }

    //* Convert location format if needed (lat, lng) -> [lng, lat]
    let coordinates;
    if (location.coordinates && Array.isArray(location.coordinates)) {
      coordinates = location.coordinates; //* Already in [lng, lat] format
    } else if (location.latitude && location.longitude) {
      coordinates = [location.longitude, location.latitude]; //* Convert to [lng, lat]
    } else if (
      location.coordinates &&
      location.coordinates.latitude &&
      location.coordinates.longitude
    ) {
      coordinates = [
        location.coordinates.longitude,
        location.coordinates.latitude,
      ];
    } else {
      return res
        .status(400)
        .json({ statusCode: 400, message: "Invalid location format" });
    }

    const medicalCenter = new MedicalCenter({
      name,
      address,
      phoneNumber,
      location: {
        type: "Point",
        coordinates: coordinates,
      },
      acceptedMedicineTypes: acceptedMedicineTypes || ["all"],
      operatingHours: operatingHours || {},
      facilityType: facilityType || "pharmacy",
      website,
      email,
      specialServices: specialServices || [],
    });

    await medicalCenter.save();

    res.status(201).json({
      statusCode: 201,
      message: "Medical center added successfully",
      data: {
        medicalCenter,
      },
    });
  } catch (error) {
    console.error("Add medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get all medical centers with pagination
const getAllMedicalCenters = async (req, res) => {
  try {
    const { page = 1, limit = 10, facilityType } = req.query;

    const query = { isActive: true };
    if (facilityType) {
      query.facilityType = facilityType;
    }

    const skip = (page - 1) * limit;
    const medicalCenters = await MedicalCenter.find(query)
      .sort({ rating: -1, name: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await MedicalCenter.countDocuments(query);

    res.status(200).json({
      statusCode: 200,
      data: {
        medicalCenters,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / limit),
          totalCenters: total,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Get all medical centers error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Find medical centers within specified radius with pagination
const getNearbyMedicalCenters = async (req, res) => {
  try {
    const {
      latitude,
      longitude,
      radius = 10,
      page = 1,
      limit = 10,
    } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({
        statusCode: 400,
        message: "Latitude and longitude are required",
      });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const radiusKm = parseFloat(radius);

    if (isNaN(lat) || isNaN(lng) || isNaN(radiusKm)) {
      return res.status(400).json({
        statusCode: 400,
        message: "Invalid latitude, longitude, or radius values",
      });
    }

    //* Use the updated findNearby method from the model
    const allNearbyMedicalCenters = await MedicalCenter.findNearby(
      lat,
      lng,
      radiusKm
    );

    //* Apply pagination to results
    const skip = (page - 1) * limit;
    const nearbyMedicalCenters = allNearbyMedicalCenters.slice(
      skip,
      skip + parseInt(limit)
    );

    res.status(200).json({
      statusCode: 200,
      data: {
        medicalCenters: nearbyMedicalCenters,
        searchLocation: { latitude: lat, longitude: lng },
        radiusKm,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(allNearbyMedicalCenters.length / limit),
          totalFound: allNearbyMedicalCenters.length,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Find nearby medical centers error:", error);
    res.status(500).json({ statusCode: 200, message: "Server error" });
  }
};

//* Get medical center by ID
const getMedicalCenterById = async (req, res) => {
  try {
    const { id } = req.params;

    const medicalCenter = await MedicalCenter.findById(id);

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    res.status(200).json({
      statusCode: 200,
      message : "Fetched details successfully!",
      data: {

        medicalCenter,
      },
    });
  } catch (error) {
    console.error("Get medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Update medical center details
const updateMedicalCenter = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const medicalCenter = await MedicalCenter.findById(id);

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    //* Handle location updates with proper GeoJSON format
    if (updateData.location) {
      let coordinates;
      if (
        updateData.location.coordinates &&
        Array.isArray(updateData.location.coordinates)
      ) {
        coordinates = updateData.location.coordinates; //* Already in [lng, lat] format
      } else if (
        updateData.location.latitude &&
        updateData.location.longitude
      ) {
        coordinates = [
          updateData.location.longitude,
          updateData.location.latitude,
        ]; //* Convert to [lng, lat]
      } else if (
        updateData.location.coordinates &&
        updateData.location.coordinates.latitude &&
        updateData.location.coordinates.longitude
      ) {
        coordinates = [
          updateData.location.coordinates.longitude,
          updateData.location.coordinates.latitude,
        ];
      }

      if (coordinates) {
        updateData.location = {
          type: "Point",
          coordinates: coordinates,
        };
      }
    }

    //* Update allowed fields
    const allowedFields = [
      "name",
      "address",
      "phoneNumber",
      "location",
      "acceptedMedicineTypes",
      "operatingHours",
      "facilityType",
      "website",
      "email",
      "specialServices",
      "isActive",
      "rating",
    ];

    allowedFields.forEach((field) => {
      if (updateData[field] !== undefined) {
        medicalCenter[field] = updateData[field];
      }
    });

    await medicalCenter.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medical center updated successfully",
      data: {
        medicalCenter,
      },
    });
  } catch (error) {
    console.error("Update medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete (deactivate) medical center ( Soft Delete )
const deleteMedicalCenter = async (req, res) => {
  try {
    const { id } = req.params;

    const medicalCenter = await MedicalCenter.findById(id);

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    //* Instead of deleting, mark as inactive
    medicalCenter.isActive = false;
    await medicalCenter.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medical center deactivated successfully",
    });
  } catch (error) {
    console.error("Delete medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete (deactivate) medical center ( Hard Delete )
const deleteMedicalCenterPermanent = async (req, res) => {
  try {
    const { id } = req.params;

    const medicalCenter = await MedicalCenter.findByIdAndDelete(id);

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    res.status(200).json({
      statusCode: 200,
      message: "Medical center deleted successfully",
    });
  } catch (error) {
    console.error("Delete medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Search medical centers by name or facility type with pagination
const searchMedicalCenters = async (req, res) => {
  try {
    const { query, facilityType, page = 1, limit = 10 } = req.query;

    const searchQuery = { isActive: true };

    if (query) {
      searchQuery.$or = [
        { name: { $regex: query, $options: "i" } },
        { address: { $regex: query, $options: "i" } },
      ];
    }

    if (facilityType) {
      searchQuery.facilityType = facilityType;
    }

    const skip = (page - 1) * limit;
    const medicalCenters = await MedicalCenter.find(searchQuery)
      .sort({ rating: -1, name: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await MedicalCenter.countDocuments(searchQuery);

    res.status(200).json({
      statusCode: 200,
      data: {
        medicalCenters,
        searchQuery: query,
        facilityType,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / limit),
          totalFound: total,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Search medical centers error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  addMedicalCenter,
  getAllMedicalCenters,
  getNearbyMedicalCenters,
  getMedicalCenterById,
  updateMedicalCenter,
  deleteMedicalCenter,
  deleteMedicalCenterPermanent,
  searchMedicalCenters,
};
