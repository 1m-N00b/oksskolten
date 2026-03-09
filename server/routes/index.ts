import type { FastifyInstance } from 'fastify'
import { requireAuth } from '../auth.js'
import { feedRoutes } from './feeds.js'
import { articleRoutes } from './articles.js'
import { categoryRoutes } from './categories.js'
import { settingsRoutes } from './settings.js'
import { adminRoutes } from './admin.js'

export function registerApi(app: FastifyInstance): void {
  app.register(async function apiRoutes(api) {
    api.addHook('preHandler', requireAuth)

    await api.register(feedRoutes)
    await api.register(articleRoutes)
    await api.register(categoryRoutes)
    await api.register(settingsRoutes)
    await api.register(adminRoutes)
  })
}
