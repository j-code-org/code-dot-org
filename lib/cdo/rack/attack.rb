require 'rack/attack'
require 'active_support/core_ext/numeric/time'

class Rack::Attack
  # maximum requests per minute over a 4-minute stretch.
  MAX_TABLE_READS_PER_MIN = 120

  redis_url = CDO.geocoder_redis_url || 'redis://localhost:6379'
  cache.store = StoreProxy::RedisStoreProxy.new(Redis.new(url: redis_url))

  def self.limits(max_per_min)
    # allow 4x the max rate over 15s, 2x the max rate over 60s, and 1x the max rate over 4min.
    # this gives the experience of exponential backoff when limits are exceeded.
    [[max_per_min, 15],
     [2 * max_per_min, 60],
     [4 * max_per_min, 240]]
  end

  limits(MAX_TABLE_READS_PER_MIN).each do |limit, period|
    throttle("shared-tables/reads/#{period}", :limit => limit, :period => period.seconds) do |req|
      # extract the channel id for get requests to shared tables. Only match full
      # table reads, because createRecord commands get redirected to individual row
      # reads and we don't want those reads to count toward these limits.
      req.get? && %r{^/v3/shared-tables/([^/]+)/[^/]+$}.match(req.path).try(:[], 0)
    end
  end
end
