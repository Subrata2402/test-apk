import { Schema, model, Document, Types } from 'mongoose';

export interface IFeedback extends Document {
  userId: Types.ObjectId;
  category: 'bug' | 'feature_request' | 'other';
  rating: number;
  title: string;
  description: string;
  deviceInfo?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

const feedbackSchema = new Schema<IFeedback>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID is required'],
    },
    category: {
      type: String,
      enum: ['bug', 'feature_request', 'other'],
      required: [true, 'Category is required'],
    },
    rating: {
      type: Number,
      required: [true, 'Rating is required'],
      min: 1,
      max: 5,
    },
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
    },
    deviceInfo: {
      type: Map,
      of: Schema.Types.Mixed,
    },
  },
  {
    timestamps: true,
  }
);

export const Feedback = model<IFeedback>('Feedback', feedbackSchema);
export default Feedback;
