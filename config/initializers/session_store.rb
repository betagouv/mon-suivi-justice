# Server-side session store so that logging out actually invalidates the
# session (Devise/Warden's sign_out calls reset_session, which destroys the
# cache entry here). With the default cookie store the whole session lives
# in the cookie itself, so a captured/replayed cookie stays valid after logout.
session_cache = if Rails.env.production?
                  ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
                                                            namespace: 'session')
                else
                  ActiveSupport::Cache::MemoryStore.new
                end

Rails.application.config.session_store :cache_store,
                                       key: '_msj_session',
                                       cache: session_cache,
                                       expire_after: 1.hour # aligned with devise.rb's config.timeout_in
