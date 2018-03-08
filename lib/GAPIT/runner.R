#!/usr/bin/Rscript

suppressMessages(library(multtest))
suppressMessages(library(gplots))
suppressMessages(library(LDheatmap))
suppressMessages(library(genetics))
suppressMessages(library(ape))
suppressMessages(library(EMMREML))
suppressMessages(library(compiler))
suppressMessages(library(scatterplot3d))
suppressMessages(library(argparse))

processArgs <- function(){
  parser <- ArgumentParser(description = "Basic GAPIT runner script")

  parser$add_argument('--Y',
                      dest = 'Y',
                      type = "character",
                      nargs = 1,
                      required = TRUE,
                      help = "Phenotype file")

  parser$add_argument('--G',
                      dest = 'G',
                      type = "character",
                      nargs = 1,
                      help = "Genotype HapMap file")

  parser$add_argument('--GD',
                      dest = 'GD',
                      type = "character",
                      nargs = 1,
                      help = "Genotype CSV file")

  parser$add_argument('--GM',
                      dest = 'GM',
                      type = "character",
                      nargs = 1,
                      help = "Genotype Map file")

  parser$add_argument('--gapitDir',
                      dest = 'gapitDir',
                      type = "character",
                      nargs = 1,
                      help = "Folder with GAPIT source.",
                      required = TRUE)

  parser$add_argument('--outDir',
                      dest = 'outDir',
                      type = "character",
                      nargs = 1,
                      help = "Folder to store output in.",
                      required = TRUE)

  arguments <- parser$parse_args()

  return(arguments)
}

processResults <- function(outDir) {
  if (getwd() == outDir) return

  results = list.files(".", pattern = "^GAPIT\\.")

  file.copy(from = results, to = outDir)
  file.remove(results)
}

if (!interactive()) {
  args <- processArgs()

  source(paste0(args$gapitDir, "/gapit_functions.txt"))
  source(paste0(args$gapitDir, "/emma.txt"))

  G = GM = GD = NULL

  if (is.null(args$G) && (is.null(args$GD) || is.null(args$GM))) {
    warning("Either --G or both --GD and --GM args are required.")
    quit(save = "no", status = 1)
  }

  if (!is.null(args$G)) {
    G <- read.table(args$G, head = FALSE, comment.char = "")
  }
  else {
    GM <- read.csv(args$GM, head = TRUE)
    GD <- read.csv(args$GD, head = TRUE)
  }

  Y <- read.csv(args$Y, head = TRUE)

  GAPIT(Y = Y, G = G, GD = GD, GM = GM, PCA.total = 3)

  processResults(args$outDir)
}

