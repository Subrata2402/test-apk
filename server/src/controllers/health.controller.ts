import { Request, Response, NextFunction } from 'express';

export const getHealth = (req: Request, res: Response, next: NextFunction): void => {
  res.status(200).json({
    status: 'success',
    message: 'Server is healthy and running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
};
