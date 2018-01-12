#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'shellwords'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: gwas.rb --phenos PHENOS"

  opts.on("--phenos PHENOS", String, "Phenos/traits to be taken into account") do |phenos|
    options[:phenos] = phenos.split(/\s+/)
  end

  opts.on("--outDir OUTDIR", String, "Output directory") do |outdir|
    options[:outdir] = outdir
  end

  opts.on("--pFile PFILE") { |p_file| }
  opts.on("--gFile GFILE") { |g_file| }
  opts.on("--mFile MFILE") { |m_file| }
  opts.on("--noPlots") { |no_plots| }

  opts.on("--railsRoot RAILS_ROOT", String, "Rails app root directory") do |rails_root|
    options[:rails_root] = rails_root
  end
end.parse!

# NOTE: work around the inability to pass space-separated lists of values for a single arg
options[:phenos] += ARGV.to_a

gwas_results_path = File.join(options[:rails_root], "spec", "fixtures", "files", "gwasser-results.csv")

options[:phenos].each do |pheno|
  target_path = "#{File.join(options[:outdir], "SNPAssociation-Full-#{pheno}.csv")}"
  FileUtils.cp(gwas_results_path, target_path)
end
