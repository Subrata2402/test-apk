import mongoose, { Schema, Document } from 'mongoose';

export interface IDeviceCode extends Document {
  deviceCode: string;
  userCode: string;
  urlToken: string;   // short-lived token embedded in the verification URL
  userId?: mongoose.Types.ObjectId;
  isAuthorized: boolean;
  expiresAt: Date;
}

const deviceCodeSchema = new Schema<IDeviceCode>({
  deviceCode: {
    type: String,
    required: true,
    unique: true,
  },
  userCode: {
    type: String,
    required: true,
    unique: true,
  },
  urlToken: {
    type: String,
    required: true,
    unique: true,
  },
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
  },
  isAuthorized: {
    type: Boolean,
    default: false,
  },
  expiresAt: {
    type: Date,
    required: true,
    index: { expires: 0 }, // TTL index to auto-delete expired documents
  },
}, {
  timestamps: true,
});

export const DeviceCode = mongoose.model<IDeviceCode>('DeviceCode', deviceCodeSchema);
