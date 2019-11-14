# Data

This directory contains data files, along with scripts to generate those data files.

Descriptions of the main subdirectories:

## Static data

Some data is static (i.e. not generated from online sources and APIs via scripts).

An example is the Hofstede Index data for different countries.

## Raw data

Files of raw data downloaded from various sources without any processing/cleaning. Scripts for generating these files should reside in this level.

## Transformed

Data files ready for use in analyses and visualizations, created from data sources in the `static` and `raw` directories.

Scripts for running transformations should reside in this level.