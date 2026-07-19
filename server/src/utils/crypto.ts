import crypto from 'crypto';
import { env } from '../config/env.js';

// Derive a 32-byte key from the JWT_SECRET
const getEncryptionKey = (): Buffer => {
  return crypto.createHash('sha256').update(env.JWT_SECRET).digest();
};

const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

/**
 * Encrypts a plain text string using AES-256-CBC.
 * Returns the result in the format: iv_hex:encrypted_hex
 */
export const encrypt = (text: string): string => {
  if (!text) return text;
  
  const iv = crypto.randomBytes(IV_LENGTH);
  const key = getEncryptionKey();
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  return `${iv.toString('hex')}:${encrypted}`;
};

/**
 * Decrypts an encrypted string in the format iv_hex:encrypted_hex.
 * If the string is not in the expected format or decryption fails,
 * it returns the original string (backwards compatibility).
 */
export const decrypt = (encryptedText: string): string => {
  if (!encryptedText) return encryptedText;

  const parts = encryptedText.split(':');
  if (parts.length !== 2) {
    return encryptedText;
  }

  const [ivHex, encryptedHex] = parts;
  if (ivHex.length !== IV_LENGTH * 2 || !/^[0-9a-fA-F]+$/.test(ivHex)) {
    return encryptedText;
  }

  try {
    const iv = Buffer.from(ivHex, 'hex');
    const key = getEncryptionKey();
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    
    let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    console.error('Decryption failed, returning raw value:', error);
    return encryptedText;
  }
};
