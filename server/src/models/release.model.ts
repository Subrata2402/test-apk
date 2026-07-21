import mongoose, { Schema, Document } from 'mongoose';

export interface IRelease extends Document {
  appId: mongoose.Types.ObjectId;
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
  createdAt: Date;
  updatedAt: Date;
}

const ReleaseSchema = new Schema<IRelease>(
  {
    appId: { type: Schema.Types.ObjectId, ref: 'App', required: true },
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
  },
  {
    timestamps: true,
  }
);

// Compound index to ensure buildNumber is unique per app
ReleaseSchema.index({ appId: 1, buildNumber: 1 }, { unique: true });

export const Release = mongoose.model<IRelease>('Release', ReleaseSchema);
