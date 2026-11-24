# Extract the ModE-RA subset from the Climatology III course files.
# Rscript Extract_ModE_RA_Subset.R [inputs] [data]

if (!requireNamespace("ncdf4", quietly = TRUE)) {
  stop("Install ncdf4 first: install.packages('ncdf4')", call. = FALSE)
}
library(ncdf4)

args <- if (sys.nframe() == 0L) commandArgs(trailingOnly = TRUE) else character()
script_dir <- "."
if (sys.nframe() == 0L) {
  script <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(script)) script_dir <- dirname(normalizePath(sub("^--file=", "", script[1L]),
                                                        winslash = "/"))
}
input_dir <- if (length(args)) args[1L] else file.path(script_dir, "inputs")
output_dir <- if (length(args) >= 2L) args[2L] else file.path(script_dir, "data")

units <- c(temp2 = "K", totprec = "kg m-2 s-1", slp = "Pa")
files <- setNames(file.path(input_dir, paste0("ModE-RA_ensmean_", names(units),
                                           "_abs_1420-2009.nc")), names(units))
missing <- files[!file.exists(files)]
if (length(missing)) {
  stop("Missing ModE-RA course files:\n", paste(missing, collapse = "\n"), call. = FALSE)
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

extract <- function(variable) {
  path <- files[[variable]]
  f <- nc_open(path)
  on.exit(nc_close(f))
  v <- f$var[[variable]]
  dims <- vapply(v$dim, function(d) d$name, "")
  lon <- f$dim$longitude$vals
  lat <- f$dim$latitude$vals
  time <- f$dim$time$vals
  time_units <- f$dim$time$units
  calendar <- ncatt_get(f, "time", "calendar")
  calendar <- if (calendar$hasatt) calendar$value else "standard"
  stopifnot(identical(dims, c("longitude", "latitude", "time")),
            identical(v$units, units[[variable]]),
            grepl("^months since [0-9]{4}-01-", time_units),
            all(time == round(time)), all(diff(time) == 1L))

  origin <- as.integer(sub("^months since ([0-9]{4}).*", "\\1", time_units))
  it <- match((1737L - origin) * 12L + 0:(64L * 12L - 1L), time)
  ix <- which(lon >= -32 & lon <= 39)
  iy <- which(lat >= 30 & lat <= 68)
  stopifnot(!anyNA(it), all(diff(it) == 1L),
            length(ix) > 1L, all(diff(ix) == 1L),
            length(iy) > 1L, all(diff(iy) == 1L))
  vals <- ncvar_get(f, variable, start = c(ix[1L], iy[1L], it[1L]),
                    count = c(length(ix), length(iy), length(it)))
  stopifnot(all(is.finite(vals)))

  dx <- ncdim_def("longitude", "degrees_east", lon[ix])
  dy <- ncdim_def("latitude", "degrees_north", lat[iy])
  dt <- ncdim_def("time", time_units, time[it], unlim = TRUE, calendar = calendar)
  out_var <- ncvar_def(variable, units[[variable]], list(dx, dy, dt),
                       longname = v$longname, prec = "float")
  out <- file.path(output_dir, paste0("ModE-RA_", variable, "_1737-1800.nc"))
  g <- nc_create(out, out_var)
  on.exit(nc_close(g), add = TRUE)
  ncvar_put(g, variable, vals)
  ncatt_put(g, 0, "Conventions", "CF-1.6")
  ncatt_put(g, 0, "source_file", basename(path))
  ncatt_put(g, 0, "reference", "https://doi.org/10.1038/s41597-023-02733-8")
  ncatt_put(g, 0, "data_doi", "https://doi.org/10.26050/WDCC/ModE-RA_s14203-18501")
  ncatt_put(g, 0, "license", "CC BY 4.0: https://creativecommons.org/licenses/by/4.0/")
  ncatt_put(g, 0, "history", "Subset of absolute fields from the course; values and units unchanged.")
  message(out, " (", paste(dim(vals), collapse = " x "), ")")
}

for (variable in names(units)) extract(variable)
