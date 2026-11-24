# The Great Famine of 1770–72

R scripts and figures for the **Climatology III poster** on the famine in Bern and the Czech Lands.

## Code Overview

- [`scripts/`](scripts/): the three R scripts.
- [`data/`](data/): the mortality CSVs and the [`vik.txt` colour palette](data/vik.txt).
- [`plots/`](plots/): the three poster figures.

## Data Availability

The three ModE-RA NetCDF files were provided in the course and are available on request.

[Figure 3](plots/Figure_3_mortality.svg) and the mortality data are adapted from Pfister and Brázdil (2006, Fig. 6) and shared under [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/).

## Usage

In RStudio, set your working directory to the folder containing `README.md`. Run the commands below in the R console. For SVG export, `capabilities("cairo")` should return `TRUE`.

### Figures 1–2: Climate

1. Create an `inputs/` folder next to `README.md`. Put the three NetCDF files there with their original filenames.
2. Install the packages once: `install.packages(c("ncdf4", "maps"))`.
3. Run the extraction script first, then the analysis script:

   ```r
   source("scripts/Extract_ModE_RA_Subset.R")
   source("scripts/Famine_1770_Analysis.R")
   ```

### Figure 3: Mortality

This script runs on its own. The mortality data are already in the script.

```r
source("scripts/Plot_Mortality.R")
```

Both runs save their figures and tables to `results/`.

## Citation

Christian Wenger and Silvia (2026). *The Great Famine of 1770–72: Why did the food crisis deepen in the Czech Lands while easing in Bern?* [R scripts, figures and mortality data]. Climatology III, University of Bern. [GitHub repository](https://github.com/chrigell/climatology_III).

Source references:

- Crameri, F. (2023) *Scientific colour maps*. Version 8.0.1. Zenodo. doi:10.5281/zenodo.8409685.
- Pfister, C. and Brázdil, R. (2006) ‘Social vulnerability to climate in the “Little Ice Age”: an example from Central Europe in the early 1770s’, *Climate of the Past*, 2, pp. 115–129. [doi:10.5194/cp-2-115-2006](https://doi.org/10.5194/cp-2-115-2006).
- Valler, V. et al. (2023) *ModE-RA: a global monthly paleo-reanalysis of the modern era (1421 to 2008), Set 1420-3_1850-1*. World Data Center for Climate. doi:10.26050/WDCC/ModE-RA_s14203-18501.

## AI Use Disclosure

We used ChatGPT (GPT-6.2) for help with the R code. We checked the scripts and their outputs and take responsibility for the final analysis.

## License and Disclaimer

The code is provided for academic and reproducibility purposes and accompanies a course poster. No warranty is provided regarding its suitability for operational forecasting or other applications.

<a href="https://github.com/chrigell/climatology_III">Code</a> © 2026 by Christian Wenger and Silvia is licensed under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">
