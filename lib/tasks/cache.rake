namespace :cache do
  desc "Remove expired cache entries"
  task cleanup: :environment do
    Rails.cache.cleanup
  end
end
