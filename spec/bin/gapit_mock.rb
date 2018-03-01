#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'shellwords'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: gapit_mock.rb"

  opts.on("--Y PHENO-FILE") { |y_file| options[:y] = y_file }
  opts.on("--G GENO-HAPMAP-FILE") { |g_file| }
  opts.on("--GD GENO-CSV-FILE") { |gd_file| }
  opts.on("--GM MAP-CSV-FILE") { |gm_file| }
  opts.on("--gapitDir GAPIT_DIR", String, "GAPIT source directory") { |gapit_dir| }

  opts.on("--outDir OUTDIR", String, "Output directory") do |outdir|
    options[:outdir] = outdir
  end

  opts.on("--railsRoot RAILS_ROOT", String, "Rails app root directory") do |rails_root|
    options[:rails_root] = rails_root
  end
end.parse!

traits = File.
  open(options[:y], "r") { |f| f.readline }.
  gsub(/[\n\"]/, '').split(",").
  tap { |parts| parts.delete("ID") }

traits.each do |trait|
  filename = "GAPIT..#{trait}.GWAS.Results.csv"
  source_path = File.join(options[:rails_root], "spec", "fixtures", "files", "gapit", filename)
  target_path = File.join(options[:outdir], filename)
  FileUtils.cp(source_path, target_path) if File.exists?(source_path)
end
