import { randomBytes } from 'node:crypto'
import { getDb } from './connection.js'

export function getSetting(key: string): string | undefined {
  const row = getDb().prepare('SELECT value FROM settings WHERE key = ?').get(key) as { value: string } | undefined
  return row?.value
}

export function upsertSetting(key: string, value: string): void {
  getDb().prepare('INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value').run(key, value)
}

export function deleteSetting(key: string): void {
  getDb().prepare('DELETE FROM settings WHERE key = ?').run(key)
}

export function getOrCreateJwtSecret(): string {
  const existing = getSetting('system.jwt_secret')
  if (existing) return existing
  const secret = randomBytes(64).toString('base64url')
  upsertSetting('system.jwt_secret', secret)
  console.log('Generated new JWT secret and persisted to database')
  return secret
}
