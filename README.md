# The Great Famine of 1770–72

R scripts for the **Climatology III poster** comparing the Swiss Plateau and Czech Lands.

Figures 1–2 use ModE-RA climate data; Figure 3 shows mortality departures in Bern, Bohemia and Moravia.

## Data Availability

The ModE-RA temperature, precipitation and sea-level pressure files were provided in Climatology III and can be provided on request. The `vik.txt` palette (Crameri, 2023) can be provided with them.

The mortality data were digitised from Pfister and Brázdil (2006, Fig. 6, p. 125). `Plot_Mortality.R` contains the digitised values, so it needs no separate input file.

## Usage

### Setup

Use a recent 64-bit R installation with Cairo graphics support (`capabilities("cairo")` should return `TRUE`). In the R console, install the two packages once:

```r
install.packages(c("ncdf4", "maps"))
```

Use a folder you can write to. Put the three NetCDFs provided in the course in `inputs/`, keeping their original names:

- `ModE-RA_ensmean_temp2_abs_1420-2009.nc`
- `ModE-RA_ensmean_totprec_abs_1420-2009.nc`
- `ModE-RA_ensmean_slp_abs_1420-2009.nc`

Place `vik.txt` in `data/`, alongside the mortality files. The extract script writes the climate subsets to the same folder. On OneDrive, make sure the input files are available locally.

### RStudio

Choose **Session → Set Working Directory → Choose Directory** and select the folder containing this README. Run these lines in the R console:

```r
source("Extract_ModE_RA_Subset.R")
source("Famine_1770_Analysis.R")
source("Plot_Mortality.R")
```

### Terminal

From a terminal in that folder, use:

```sh
Rscript Extract_ModE_RA_Subset.R
Rscript Famine_1770_Analysis.R
Rscript Plot_Mortality.R
```

You can also pass a quoted absolute script path to `Rscript` from another folder. The defaults are relative to the script location. For custom paths, the optional arguments are `[inputs] [data]` for the extract script, `[data] [results]` for the analysis script and `[results]` for the mortality script. Quote any path containing spaces.

### Outputs

The figure scripts write three SVGs and the supporting CSVs to `results/`. The poster outputs were reproduced with R 4.5.0, ncdf4 1.23 and maps 3.4.2.1. Font rendering can vary by system.

For a quick check, the July–August 1771 rainfall departures in `Event_1769_1772.csv` are about −33.2% (Swiss Plateau) and −5.4% (Czech Lands); Figure 3 labels the 1772 Bohemian mortality peak at about +170% above the local mean.

## Citation

If you use this repository, please cite:

Christian Wenger and Silvia (2026). *The Great Famine of 1770–72: Why did the food crisis deepen in the Czech Lands while easing in Bern?* [R scripts, figures and mortality data]. Climatology III, University of Bern. [GitHub repository](https://github.com/chrigell/climatology_III).

### Source references

Crameri, F. (2023) *Scientific colour maps*. Version 8.0.1. Zenodo. doi:10.5281/zenodo.8409685.

Pfister, C. and Brázdil, R. (2006) ‘Social vulnerability to climate in the “Little Ice Age”: an example from Central Europe in the early 1770s’, *Climate of the Past*, 2, pp. 115–129. [doi:10.5194/cp-2-115-2006](https://doi.org/10.5194/cp-2-115-2006).

Valler, V. et al. (2023) *ModE-RA: a global monthly paleo-reanalysis of the modern era (1421 to 2008), Set 1420-3_1850-1*. World Data Center for Climate. doi:10.26050/WDCC/ModE-RA_s14203-18501.

Valler, V. et al. (2024) ‘ModE-RA: a global monthly paleo-reanalysis of the modern era 1421 to 2008’, *Scientific Data*, 11, article 36. [doi:10.1038/s41597-023-02733-8](https://doi.org/10.1038/s41597-023-02733-8).

## Code Overview

### R scripts

- **Extract_ModE_RA_Subset.R**  
  Extracts the three 1737–1800 climate subsets from the course files and writes them to `data/`. If they are already there, skip this step.

- **Famine_1770_Analysis.R**  
  Produces Figures 1–2 and the supporting climate summaries.

- **Plot_Mortality.R**  
  Produces Figure 3 and the mortality summary. It can be run on its own, without any input files.

### Repository folders

- **[plots/](plots/)**  
  Contains the three exported poster figures. After rerunning the scripts, copy the SVGs from `results/` here to update the published figures.

- **[data/](data/)**  
  Contains the [digitised trace](data/Mortality_Fig6_trace.csv) used for Figure 3 and the [derived mortality table](data/Mortality_departure_pct.csv). The trace records positions read from the published curves; the table gives the converted Bern rates and the percentage departures plotted for each region. Keep the ModE-RA files and `vik.txt` local.

### Methods

The climate analysis uses area-weighted regional averages of September–October rain in the preceding year, March–April temperature and July–August rain. Anomalies are relative to 1750–1800 excluding 1768–1772. The script also tests wider regional boxes and an earlier baseline.

The mortality curves show the percentage difference from each region’s own 1760–1780 mean, using the series in the original figure. They compare departures from typical mortality, rather than absolute numbers of deaths between regions.

## License and Disclaimer

The code is provided for academic and reproducibility purposes and accompanies a course poster. No warranty is provided regarding its suitability for operational forecasting or other applications.

<a href="https://example.com">Code</a> © 2026 by <a href="https://example.com">Christian Wenger and Silvia</a> is licensed under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">

| Other material | Licence |
| --- | --- |
| [Figure 3](plots/Figure_3_mortality.svg), the [digitised trace](data/Mortality_Fig6_trace.csv) (also embedded in `Plot_Mortality.R`) and the [derived mortality table](data/Mortality_departure_pct.csv). All are adapted from Pfister and Brázdil (2006, Fig. 6, p. 125). | [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/) |
| ModE-RA source data (Valler et al., 2023). | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) |
| The `vik` palette (Crameri, 2023). | MIT, as stated in the palette distribution. |

### AI Use Disclosure

We used ChatGPT (GPT-6.2) for help with the R code. We checked the scripts and their outputs and take responsibility for the final analysis.
