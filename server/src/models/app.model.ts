import mongoose, { Schema, Document } from 'mongoose';

export interface IRelease {
  version: string;
  buildNumber: number;
  releaseNotes: string;
  date: string;
  size: string;
  apkUrl: string;
  appName?: string;
  minSdkVersion?: string;
  targetSdkVersion?: string;
  sha256?: string;
  permissions?: string[];
  appIcon?: string;
  uploadedByEmail?: string;
  uploadedByName?: string;
}

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
  members: IMember[];
  createdAt: Date;
  updatedAt: Date;
}

const ReleaseSchema = new Schema<IRelease>({
  version: { type: String, required: true },
  buildNumber: { type: Number, required: true },
  releaseNotes: { type: String, required: true },
  date: { type: String, required: true },
  size: { type: String, required: true },
  apkUrl: { type: String, required: true },
  appName: { type: String },
  minSdkVersion: { type: String },
  targetSdkVersion: { type: String },
  sha256: { type: String },
  permissions: { type: [String], default: [] },
  appIcon: { type: String },
  uploadedByEmail: { type: String },
  uploadedByName: { type: String },
});

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
    releases: { type: [ReleaseSchema], default: [] },
    members: { type: [MemberSchema], required: true },
  },
  {
    timestamps: true,
  }
);

export const App = mongoose.model<IApp>('App', AppSchema);
