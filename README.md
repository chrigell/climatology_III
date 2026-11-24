# The Great Famine of 1770–72

R scripts and figures for the **Climatology III poster** on the famine in Bern and the Czech Lands.

## Data Availability

The three ModE-RA NetCDF files were provided in the course and are available on request. To run the climate analysis, place them in `inputs/` with their original filenames.

The [mortality data](data/) were digitised from Pfister and Brázdil (2006, Fig. 6).

## Usage

In RStudio, set the working directory to the folder containing this README. Use R with Cairo support for SVG export. Install the packages once with `install.packages(c("ncdf4", "maps"))`, then run:

```r
source("scripts/Extract_ModE_RA_Subset.R")
source("scripts/Famine_1770_Analysis.R")
source("scripts/Plot_Mortality.R")
```

Outputs are written to `results/`. The mortality script can also run on its own.

## Citation

Christian Wenger and Silvia (2026). *The Great Famine of 1770–72: Why did the food crisis deepen in the Czech Lands while easing in Bern?* [R scripts, figures and mortality data]. Climatology III, University of Bern. [GitHub repository](https://github.com/chrigell/climatology_III).

Source references:

- Crameri, F. (2023) *Scientific colour maps*. Version 8.0.1. Zenodo. doi:10.5281/zenodo.8409685.
- Pfister, C. and Brázdil, R. (2006) ‘Social vulnerability to climate in the “Little Ice Age”: an example from Central Europe in the early 1770s’, *Climate of the Past*, 2, pp. 115–129. [doi:10.5194/cp-2-115-2006](https://doi.org/10.5194/cp-2-115-2006).
- Valler, V. et al. (2023) *ModE-RA: a global monthly paleo-reanalysis of the modern era (1421 to 2008), Set 1420-3_1850-1*. World Data Center for Climate. doi:10.26050/WDCC/ModE-RA_s14203-18501.

## Code Overview

Put all three R scripts in [`scripts/`](scripts/). That folder sits next to `README.md`, [`plots/`](plots/) and [`data/`](data/).

- [`Extract_ModE_RA_Subset.R`](scripts/Extract_ModE_RA_Subset.R) prepares the climate inputs.
- [`Famine_1770_Analysis.R`](scripts/Famine_1770_Analysis.R) produces Figures 1–2.
- [`Plot_Mortality.R`](scripts/Plot_Mortality.R) produces Figure 3.

`plots/` contains the poster figures. `data/` contains the mortality CSVs and the [`vik.txt` colour palette](data/vik.txt).

## License and Disclaimer

The code is provided for academic and reproducibility purposes and accompanies a course poster. No warranty is provided regarding its suitability for operational forecasting or other applications.

<a href="https://github.com/chrigell/climatology_III">Code</a> © 2026 by Christian Wenger and Silvia is licensed under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">

Figure 3 and the mortality CSVs, including the trace embedded in `Plot_Mortality.R`, are adapted from Pfister and Brázdil (2006, Fig. 6) and shared under [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/).

### AI Use Disclosure

We used ChatGPT (GPT-6.2) for help with the R code. We checked the scripts and their outputs and take responsibility for the final analysis.
