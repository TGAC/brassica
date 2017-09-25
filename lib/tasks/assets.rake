namespace :assets do
  desc "Prepare non-digested versions of assets"
  task non_digested: :environment do
    assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))
    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    manifest_regex = /manifest-.*\.json/
    assets.each do |file|
      next if File.directory?(file) || file !~ regex || file =~ manifest_regex

      source = file.split('/')
      source.push(source.pop.gsub(regex, '.'))

      non_digested = File.join(source)
      FileUtils.cp(file, non_digested)
    end
  end
end
