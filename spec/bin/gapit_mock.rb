#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'shellwords'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: gapit.rb"

  opts.on("--Y PHENO-FILE") { |y_file| options[:y] = y_file }
  opts.on("--G GENO-HAPMAP-FILE") { |g_file| }
  opts.on("--GD GENO-CSV-FILE") { |gd_file| }
  opts.on("--GM MAP-CSV-FILE") { |gm_file| }

  opts.on("--outDir OUTDIR", String, "Output directory") do |outdir|
    options[:outdir] = outdir
  end

  opts.on("--railsRoot RAILS_ROOT", String, "Rails app root directory") do |rails_root|
    options[:rails_root] = rails_root
  end
end.parse!

gwas_results_path = File.join(options[:rails_root], "spec", "fixtures", "files", "gapit-results.csv")

traits = File.
  open(options[:y], "r") { |f| f.readline }.
  gsub(/[\n\"]/, '').split(",").
  tap { |parts| parts.delete("ID") }

traits.each do |trait|
  target_path = "#{File.join(options[:outdir], "GAPIT..#{trait}.GWAS.Results.csv")}"
  FileUtils.cp(gwas_results_path, target_path)
end
