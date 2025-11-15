import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const options = {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    };

    await mongoose.connect(process.env.MONGO_URI, options);
    console.log("✅ MongoDB Connected");
    console.log("📍 Database:", mongoose.connection.name);
  } catch (error) {
    console.error("❌ MongoDB connection failed:", error.message);
    console.error("\n💡 Suggestions:");
    console.error("   1. Check your internet connection");
    console.error("   2. Verify MongoDB Atlas cluster is running");
    console.error("   3. Check if IP address is whitelisted in MongoDB Atlas");
    console.error("   4. Verify MONGO_URI in .env file");
    console.error("\n🔄 Attempting to continue without database...");
    // Don't exit process, let app run without DB for development
    // process.exit(1);
  }
};

export default connectDB;
