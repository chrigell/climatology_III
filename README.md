# The Great Famine of 1770–72

R scripts for the **Climatology III poster** comparing the Swiss Plateau and Czech Lands.

Figures 1–2 use ModE-RA climate data; Figure 3 shows mortality departures in Bern, Bohemia and Moravia. The ModE-RA files and map palette are downloaded separately.

## Data Availability

### ModE-RA climate fields

Use one of these sets in `inputs/`. Replace `<var>` with each of `temp2`, `totprec`, and `slp` in the filenames below. Keep the original filenames.

| Input set | Files | Where to get them |
| --- | --- | --- |
| Course files (used for the poster) | `ModE-RA_ensmean_<var>_abs_1420-2009.nc` | Climatology III course materials |
| Archived ensemble mean anomalies | `ModE-RA_ensmean_<var>_anom_wrt_1901-2000_1421-2008_mon.nc` | [NOAA NCEI](https://www.ncei.noaa.gov/pub/data/paleo/gcmoutput/ModE/ModE-RA/ensstat/) or [WDCC](https://www.wdc-climate.de/ui/entry?acronym=ModE-RA_s14203-18501_ensanom) |
| Archived ensemble mean climatology (needed with the anomalies) | `ModE-RA_ensmean_<var>_clim_wrt_1901-2000.nc` | [WDCC](https://www.wdc-climate.de/ui/entry?acronym=ModE-RA_s14203-18501_climbias); sign in with a registered account to download |

The course route takes three files; the archive route takes six. The script uses the course set if all three are present. With the archive set it adds the corresponding 1901–2000 monthly climatology to each anomaly to recover absolute fields, including the original model bias (see the [ModE-RA data guide](https://www.wdc-climate.de/ui/cerarest/addinfoDownload/ModE-RA_info/Dataset_description_WDC_ModE-RA_v5.pdf)). ModE-RA is distributed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

### Map palette

Download [Scientific Colour Maps 8.0.1](https://doi.org/10.5281/zenodo.8409685), unzip it and copy `vik/vik.txt` to `data/vik.txt`. The palette is distributed under the MIT licence.

### Mortality data

`Plot_Mortality.R` includes the approximate values digitised from Pfister and Brázdil (2006, Fig. 6, p. 125). No download is needed to run the script. The trace, derived values and adapted figure are under [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/).

## Usage

### Setup

Use a recent 64-bit R installation with Cairo graphics support (`capabilities("cairo")` should return `TRUE`). In the R console, install the two packages once:

```r
install.packages(c("ncdf4", "maps"))
```

Use a folder you can write to. Create an `inputs` folder for the original NetCDFs, and put the palette in `data` alongside the mortality files. The extract script writes its subsets to the same `data` folder. On OneDrive, make sure any downloaded inputs are available locally.

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

## Code Overview

### R scripts

- **Extract_ModE_RA_Subset.R**  
  Writes the three 1737–1800 climate subsets to `data/`. If they are already there, skip this step.

- **Famine_1770_Analysis.R**  
  Produces Figures 1–2 and the supporting climate summaries.

- **Plot_Mortality.R**  
  Produces Figure 3 and the mortality summary. It can be run on its own, without any input files.

### Repository folders

- **[plots/](plots/)**  
  Contains the three exported poster figures. After rerunning the scripts, copy the SVGs from `results/` here to update the published figures.

- **[data/](data/)**  
  Contains the [digitised trace](data/Mortality_Fig6_trace.csv) used for Figure 3 and the [derived mortality table](data/Mortality_departure_pct.csv). The trace records positions read from the published curves; the table gives the converted Bern rates and the percentage departures plotted for each region. Keep the ModE-RA files and `vik.txt` local.

## Methods

The climate analysis uses area-weighted regional averages of September–October rain in the preceding year, March–April temperature and July–August rain. Anomalies are relative to 1750–1800 excluding 1768–1772. The script also tests wider regional boxes and an earlier baseline.

The mortality curves show the percentage difference from each region’s own 1760–1780 mean, using the series in the original figure. They compare departures from typical mortality, rather than absolute numbers of deaths between regions.

## References

Crameri, F. (2023) *Scientific colour maps*. Version 8.0.1. Zenodo. [doi:10.5281/zenodo.8409685](https://doi.org/10.5281/zenodo.8409685).

Pfister, C. and Brázdil, R. (2006) ‘Social vulnerability to climate in the “Little Ice Age”: an example from Central Europe in the early 1770s’, *Climate of the Past*, 2, pp. 115–129. [doi:10.5194/cp-2-115-2006](https://doi.org/10.5194/cp-2-115-2006).

Valler, V. et al. (2023) *ModE-RA: a global monthly paleo-reanalysis of the modern era (1421 to 2008), Set 1420-3_1850-1*. World Data Center for Climate. [doi:10.26050/WDCC/ModE-RA_s14203-18501](https://doi.org/10.26050/WDCC/ModE-RA_s14203-18501).

Valler, V. et al. (2024) ‘ModE-RA: a global monthly paleo-reanalysis of the modern era 1421 to 2008’, *Scientific Data*, 11, article 36. [doi:10.1038/s41597-023-02733-8](https://doi.org/10.1038/s41597-023-02733-8).

## AI Use Disclosure

We used ChatGPT (GPT-6.2) for help with the R code. We checked the scripts and their outputs and take responsibility for the final analysis.

