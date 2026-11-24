# The Great Famine of 1770–72

[R scripts](scripts/) and [figures](plots/) for the **Climatology III poster** on the famine in Bern and the Czech Lands.

## Data Availability

The three ModE-RA NetCDF files ([Valler et al., 2023](https://doi.org/10.26050/WDCC/ModE-RA_s14203-18501)) were provided in the course and are available on request.

[Figure 3](plots/Figure_3_mortality.svg) and the [mortality data](data/Mortality_departure_pct.csv) are adapted from [Pfister and Brázdil (2006, Fig. 6)](https://doi.org/10.5194/cp-2-115-2006) and shared under [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/).

The [vik colour palette](data/vik.txt) by [Crameri (2023)](https://doi.org/10.5281/zenodo.8409685) is included with its [MIT licence](data/vik_LICENCE.pdf).

## Usage

In RStudio, set the working directory to the folder containing `README.md`.

**Figures 1–2 (climate):** Put the three NetCDF files in `inputs/` next to `README.md`, keeping their original names. Run these commands in the R console:

```r
install.packages(c("ncdf4", "maps"))  # first time only
source("scripts/Extract_ModE_RA_Subset.R")
source("scripts/Famine_1770_Analysis.R")
```

**Figure 3 (mortality):** Run `source("scripts/Plot_Mortality.R")` in the R console. No extra files or packages are needed.

New figures and tables go to `results/`.

## Citation

Christian Wenger and Silvia (2026). *The Great Famine of 1770–72: Why did the food crisis deepen in the Czech Lands while easing in Bern?* [R scripts, figures and mortality data]. Climatology III, University of Bern. [GitHub repository](https://github.com/chrigell/climatology_III).

## License and Disclaimer

The code is provided for academic and reproducibility purposes and accompanies a course poster. No warranty is provided regarding its suitability for operational forecasting or other applications.

**AI use disclosure:** We used ChatGPT (GPT-6.2) for help with the R code. We checked the scripts and their outputs and take responsibility for the final analysis.

<a href="https://github.com/chrigell/climatology_III">Code</a> © 2026 by Christian Wenger and Silvia is licensed under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">
