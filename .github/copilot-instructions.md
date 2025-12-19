# Copilot Instructions for fenton-shiny

## Overview
- This is a single-file R Shiny app (`app.R`) for plotting Fenton preterm growth curves (weight, length, head circumference) using LMS-derived percentile data.
- Data lives in `data/` as CSVs and is precomputed for boys and girls; the app overlays user-provided measurements (via URL query or uploaded Excel) on top of percentile curves.

## Data Flow
- Source CSVs per sex and metric (e.g., `boys_weight.csv`) contain LMS columns (`L`, `M`, `S`) and gestational age (`Time`).
- Generator scripts (`growthcurve_boys.R`, `growthcurve_girls.R`) compute percentiles (`P03`, `P10`, `P50`, `P90`, `P97`) and write two outputs:
  - Long: `data/*_all.csv` with columns: `Time, L, M, S, type, annotation, value`.
  - Wide: `data/*_all_spread.csv` for inspection/debugging.
- The app loads `data/boys_all.csv` or `data/girls_all.csv`, renames `Time` → `PML`, then binds user measurements (`annotation == "measure"`) for plotting and table output.

## Key Files
- `app.R`: Shiny UI/server. Reads `data/*_all.csv`, parses GET params and Excel, renders three plots and a percentile table.
- `growthcurve_boys.R` / `growthcurve_girls.R`: Recompute percentile CSVs from LMS inputs; ensure output column `Time` (not `Compl weeks`).
- `data/`: Required runtime inputs. App expects at least: `boys_all.csv`, `girls_all.csv`; also raw LMS files (e.g., `boys_weight.csv`) if regenerating.
- `Dockerfile`: Rocker Shiny image with required packages; serves app on port 3838.

## Running
- R (local): install R ≥ 4.3 and packages: `shiny`, `tidyverse`, `shinythemes`, `DT`, `readxl`.
  - From repo root with `data/` populated:
    - In R: `shiny::runApp('.')` or `source('app.R')`.
  - App port defaults to RStudio Viewer/your session; with Shiny Server, use 3838.
- Docker (dev): build and run with a bind mount for `data/`:
  - Build: `docker build -t fenton:dev .`
  - Run: `docker run -p 3838:3838 -v %CD%/data:/srv/shiny-server/data fenton:dev`
- Prebuilt (from README example):
  - `docker run -dp 0.0.0.0:3838:3838 -v /data:/srv/shiny-server/data --platform linux/amd64 rmvpaeme/fenton:0.4`

## URL/Excel Inputs
- Toggle "advanced" to accept GET params; otherwise upload the Excel template (see README link).
- Required GET params: `advanced=yes|no`, `sex_GET=M|F`, `PML_GET`, and any of `weight_GET,length_GET,HC_GET` as comma-separated lists; use `NA` for missing values.
- `PML_GET` accepts expressions like `23+1/7` (encode `+` as `%2B` in URLs). All lists must have equal length.

## Conventions & Patterns
- Sex label mapping: `M` → `boys`, `F` → `girls`.
- Types are fixed strings: `weight`, `length`, `HC`. User points are marked with `annotation == 'measure'`.
- Column expectations in `data/*_all.csv`: must include `Time, L, M, S, type, annotation, value` (app renames `Time` to `PML`).
- Plot scales are opinionated (e.g., weight `0–7200g`); adjust in `scale_y_continuous()` in `app.R` if needed.

## Regenerating Data
- Ensure your raw LMS CSVs in `data/` match the scripts’ expected columns.
- Run the appropriate R script to rewrite `data/*_all.csv` and `data/*_all_spread.csv`.
- Important: scripts should output a `Time` column (the app uses it); if your LMS files use `Compl weeks`, rename to `Time` before writing.

## Common Pitfalls
- Missing `readxl`: Excel uploads require `readxl` even though it is not installed in the Dockerfile; add it if needed.
- Mismatched list lengths in GET params cause misaligned rows; the app assumes equal lengths.
- Empty or non-positive values are filtered; `value > 0` is enforced before plotting.
