import mongoose, { Schema, Document } from 'mongoose';
import { IRelease } from './release.model.js';

export interface IMember {
  email: string;
  role: 'Owner' | 'Developer' | 'Tester';
  status: 'Pending' | 'Accepted';
  name?: string;
}

export interface IApp extends Document {
  name: string;
  packageName: string;
  description: string;
  category: string;
  icon: string;
  downloads: string;
  rating: string;
  activeUsers: string;
  screenshots: string[];
  releases: IRelease[];
  releasesCount?: number;
  members: IMember[];
  createdAt: Date;
  updatedAt: Date;
}

const MemberSchema = new Schema<IMember>({
  email: { type: String, required: true },
  role: { type: String, enum: ['Owner', 'Developer', 'Tester'], required: true },
  status: { type: String, enum: ['Pending', 'Accepted'], default: 'Pending' },
  name: { type: String },
});

const AppSchema = new Schema<IApp>(
  {
    name: { type: String, required: true, trim: true },
    packageName: { type: String, required: true, unique: true, trim: true },
    description: { type: String, required: true },
    category: { type: String, default: 'Android App' },
    icon: { type: String, default: 'Android' },
    downloads: { type: String, default: '0' },
    rating: { type: String, default: '0.0' },
    activeUsers: { type: String, default: '0' },
    screenshots: {
      type: [String],
      default: [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'linear-gradient(135deg, #2af598 0%, #009efd 100%)',
      ],
    },
    members: { type: [MemberSchema], required: true },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual populate for releases
AppSchema.virtual('releases', {
  ref: 'Release',
  localField: '_id',
  foreignField: 'appId',
  options: { sort: { buildNumber: -1 } },
});

// Virtual populate for releases count
AppSchema.virtual('releasesCount', {
  ref: 'Release',
  localField: '_id',
  foreignField: 'appId',
  count: true,
});

export const App = mongoose.model<IApp>('App', AppSchema);
