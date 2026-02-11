import mongoose from "mongoose";

const carSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    year: {
      type: Number,
      required: true,
      min: 1950,
      max: 2100,
    },
    km: {
      type: Number,
      required: true,
      min: 0,
    },
    priceEur: {
      type: Number,
      required: true,
      min: 0,
    },
    city: {
      type: String,
      required: true,
      trim: true,
    },
    fuel: {
      type: String,
      required: true,
      trim: true,
    },
    gearbox: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    imagePaths: {
      type: [String],
      default: [],
    },
    reserved: {
      type: Boolean,
      default: false,
    },
    reservedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    reservedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

const Car = mongoose.model("Car", carSchema);

export default Car;
