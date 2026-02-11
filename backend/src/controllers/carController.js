import mongoose from "mongoose";
import Car from "../models/Car.js";
import asyncHandler from "../utils/asyncHandler.js";

const toNumber = (value) => {
  if (value === undefined || value === null || value === "") {
    return undefined;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

const buildFilters = (query) => {
  const filters = {};

  if (query.search) {
    filters.title = { $regex: query.search, $options: "i" };
  }
  if (query.city) {
    filters.city = { $regex: query.city, $options: "i" };
  }
  if (query.fuel) {
    filters.fuel = { $regex: query.fuel, $options: "i" };
  }
  if (query.gearbox) {
    filters.gearbox = { $regex: query.gearbox, $options: "i" };
  }

  const reserved = typeof query.reserved === "string" ? query.reserved.toLowerCase() : undefined;
  if (reserved === "true") {
    filters.reserved = true;
  } else if (reserved === "false") {
    filters.reserved = false;
  }

  const minPrice = toNumber(query.minPrice);
  const maxPrice = toNumber(query.maxPrice);
  if (minPrice !== undefined || maxPrice !== undefined) {
    filters.priceEur = {};
    if (minPrice !== undefined) {
      filters.priceEur.$gte = minPrice;
    }
    if (maxPrice !== undefined) {
      filters.priceEur.$lte = maxPrice;
    }
  }

  const yearFrom = toNumber(query.yearFrom);
  const yearTo = toNumber(query.yearTo);
  if (yearFrom !== undefined || yearTo !== undefined) {
    filters.year = {};
    if (yearFrom !== undefined) {
      filters.year.$gte = yearFrom;
    }
    if (yearTo !== undefined) {
      filters.year.$lte = yearTo;
    }
  }

  return filters;
};

const getSort = (sort) => {
  switch (sort) {
    case "price_asc":
      return { priceEur: 1 };
    case "price_desc":
      return { priceEur: -1 };
    case "year_asc":
      return { year: 1 };
    case "year_desc":
      return { year: -1 };
    default:
      return { createdAt: -1 };
  }
};

const validateListingBody = (body) => {
  const requiredFields = [
    "title",
    "year",
    "km",
    "priceEur",
    "city",
    "fuel",
    "gearbox",
    "description",
  ];

  const missing = requiredFields.filter((field) => body[field] === undefined || body[field] === "");
  if (missing.length) {
    return `Missing required fields: ${missing.join(", ")}`;
  }

  return null;
};

export const getCars = asyncHandler(async (req, res) => {
  const filters = buildFilters(req.query);
  const sort = getSort(req.query.sort);
  const cars = await Car.find(filters).populate("owner", "name email role").sort(sort);

  res.json({ count: cars.length, cars });
});

export const getCarById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid car id");
  }

  const car = await Car.findById(id).populate("owner", "name email role");
  if (!car) {
    res.status(404);
    throw new Error("Car listing not found");
  }

  res.json({ car });
});

export const createCar = asyncHandler(async (req, res) => {
  const validationError = validateListingBody(req.body);
  if (validationError) {
    res.status(400);
    throw new Error(validationError);
  }

  const created = await Car.create({
    ...req.body,
    owner: req.user._id,
    reserved: false,
  });

  const car = await Car.findById(created._id).populate("owner", "name email role");
  res.status(201).json({ car });
});

export const updateCar = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid car id");
  }

  const car = await Car.findById(id);
  if (!car) {
    res.status(404);
    throw new Error("Car listing not found");
  }

  const isOwner = car.owner.toString() === req.user._id.toString();
  const isAdmin = req.user.role === "admin";
  if (!isOwner && !isAdmin) {
    res.status(403);
    throw new Error("Not allowed to update this listing");
  }

  const allowedFields = [
    "title",
    "year",
    "km",
    "priceEur",
    "city",
    "fuel",
    "gearbox",
    "description",
    "imagePaths",
  ];

  allowedFields.forEach((field) => {
    if (req.body[field] !== undefined) {
      car[field] = req.body[field];
    }
  });

  const updated = await car.save();
  const populated = await Car.findById(updated._id).populate("owner", "name email role");
  res.json({ car: populated });
});

export const deleteCar = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid car id");
  }

  const car = await Car.findById(id);
  if (!car) {
    res.status(404);
    throw new Error("Car listing not found");
  }

  const isOwner = car.owner.toString() === req.user._id.toString();
  const isAdmin = req.user.role === "admin";
  if (!isOwner && !isAdmin) {
    res.status(403);
    throw new Error("Not allowed to delete this listing");
  }

  await car.deleteOne();
  res.json({ message: "Listing deleted" });
});

export const getMyCars = asyncHandler(async (req, res) => {
  const cars = await Car.find({ owner: req.user._id }).sort({ createdAt: -1 });
  res.json({ count: cars.length, cars });
});
