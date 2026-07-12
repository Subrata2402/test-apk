import { Request, Response, NextFunction } from 'express';

export const getMe = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(401).json({
      status: 'fail',
      message: 'User not authenticated',
    });
    return;
  }

  res.status(200).json({
    status: 'success',
    data: {
      user: {
        id: req.user._id,
        email: req.user.email,
        name: req.user.name,
        picture: req.user.picture,
        role: req.user.role,
      },
    },
  });
};
