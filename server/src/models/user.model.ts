import { Schema, model, Document } from 'mongoose';
import { encrypt, decrypt } from '../utils/crypto.js';

export interface IUser extends Document {
  email: string;
  name: string;
  picture?: string;
  googleId?: string;
  googleRefreshToken?: string;
  googleDriveFolderId?: string;
  role: 'user' | 'admin';
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
    },
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
    },
    picture: {
      type: String,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true,
    },
    googleRefreshToken: {
      type: String,
      get: decrypt,
      set: encrypt,
    },
    googleDriveFolderId: {
      type: String,
      get: decrypt,
      set: encrypt,
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  {
    timestamps: true,
    toObject: { getters: true },
    toJSON: { getters: true },
  }
);

export const User = model<IUser>('User', userSchema);
export default User;
