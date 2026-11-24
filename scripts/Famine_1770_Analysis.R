# Climatology III: The Great Famine of 1770-72
# Rscript Famine_1770_Analysis.R [data] [results]

for (pkg in c("ncdf4", "maps")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Install the R packages first: install.packages(c('ncdf4', 'maps'))", call. = FALSE)
  }
}
library(ncdf4)
library(maps)
if (!capabilities("cairo")) stop("Use an R build with Cairo support for SVG export.", call. = FALSE)

args <- if (sys.nframe() == 0L) commandArgs(trailingOnly = TRUE) else character()
script_dir <- "."
if (sys.nframe() == 0L) {
  script <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(script)) script_dir <- dirname(normalizePath(sub("^--file=", "", script[1L]),
                                                        winslash = "/"))
}
input_dir <- if (length(args)) args[1] else file.path(script_dir, "data")
output_dir <- if (length(args) >= 2) args[2] else file.path(script_dir, "results")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

read_field <- function(variable, expected_units) {
  path <- file.path(input_dir, paste0("ModE-RA_", variable, "_1737-1800.nc"))
  if (!file.exists(path)) stop("Missing input file: ", path)
  f <- nc_open(path)
  on.exit(nc_close(f))
  lon <- ncvar_get(f, "longitude")
  lat <- ncvar_get(f, "latitude")
  time <- ncvar_get(f, "time")
  time_units <- ncatt_get(f, "time", "units")$value
  dims <- vapply(f$var[[variable]]$dim, function(x) x$name, "")
  stopifnot(identical(dims, c("longitude", "latitude", "time")),
            ncatt_get(f, variable, "units")$value == expected_units,
            grepl("^months since [0-9]{4}-01-", time_units),
            all(time == round(time)), all(diff(time) == 1))
  origin <- as.integer(sub("^months since ([0-9]{4}).*", "\\1", time_units))
  year <- origin + time %/% 12
  month <- time %% 12 + 1
  next_year <- year + (month == 12)
  next_month <- month %% 12 + 1
  days <- as.integer(as.Date(sprintf("%04d-%02d-01", next_year, next_month)) -
                       as.Date(sprintf("%04d-%02d-01", year, month)))
  vals <- ncvar_get(f, variable)
  stopifnot(all(is.finite(vals)), length(days) == dim(vals)[3],
            length(unique(paste(year, month))) == length(days))
  list(lon = lon, lat = lat, year = year, month = month, days = days, value = vals)
}

temp <- read_field("temp2", "K")
prec <- read_field("totprec", "kg m-2 s-1")
slp <- read_field("slp", "Pa")
for (v in list(prec, slp)) {
  stopifnot(identical(temp$lon, v$lon), identical(temp$lat, v$lat),
            identical(temp$year, v$year), identical(temp$month, v$month))
}
temp$value <- temp$value - 273.15
# 1 kg m^-2 of water is 1 mm; integrate the monthly mean flux over the month.
prec$value <- sweep(prec$value, 3, prec$days * 86400, "*")
slp$value <- slp$value / 100

# Boxes sample the vicinity of the historical regions on a coarse grid.
regions <- data.frame(region = c("Swiss Plateau", "Czech Lands"),
                      xmin = c(5, 12), xmax = c(10, 19),
                      ymin = c(46.5, 48), ymax = c(48.5, 51))
wider <- data.frame(region = regions$region, xmin = c(5, 11), xmax = c(11, 20),
                    ymin = c(45, 47.5), ymax = c(49.5, 52))
reference <- setdiff(1750:1800, 1768:1772)
early_reference <- 1738:1767
event <- 1769:1772
years <- 1738:1800

regional_series <- function(d, box) {
  x <- which(d$lon >= box$xmin & d$lon <= box$xmax)
  y <- which(d$lat >= box$ymin & d$lat <= box$ymax)
  if (!length(x) || !length(y)) stop("No grid cells in ", box$region)
  w <- rep(cos(d$lat[y] * pi / 180), each = length(x))
  mat <- matrix(d$value[x, y, , drop = FALSE], nrow = length(w))
  as.numeric(crossprod(w / sum(w), mat))
}

season_value <- function(d, series, year, months, weighted_mean = FALSE) {
  ix <- which(d$year == year & d$month %in% months)
  stopifnot(length(ix) == length(months))
  if (weighted_mean) weighted.mean(series[ix], d$days[ix]) else sum(series[ix])
}

seasonal_results <- function(boxes, baseline, scenario) {
  do.call(rbind, lapply(seq_len(nrow(boxes)), function(i) {
    box <- boxes[i, ]
    t <- regional_series(temp, box)
    p <- regional_series(prec, box)
    autumn <- vapply(years - 1L, function(y) season_value(prec, p, y, 9:10), 0)
    spring <- vapply(years, function(y) season_value(temp, t, y, 3:4, TRUE), 0)
    summer <- vapply(years, function(y) season_value(prec, p, y, 7:8), 0)
    base <- years %in% baseline
    stopifnot(sum(base) == length(baseline))
    a0 <- mean(autumn[base]); t0 <- mean(spring[base]); p0 <- mean(summer[base])
    stopifnot(a0 > 0, p0 > 0)
    data.frame(scenario, region = box$region, harvest_year = years,
               autumn_mm = autumn, autumn_reference_mm = a0,
               autumn_anomaly_pct = 100 * (autumn / a0 - 1),
               spring_c = spring, spring_reference_c = t0, spring_anomaly_c = spring - t0,
               harvest_mm = summer, harvest_reference_mm = p0,
               harvest_anomaly_pct = 100 * (summer / p0 - 1))
  }))
}

seasons <- seasonal_results(regions, reference, "Main")
events <- seasons[seasons$harvest_year %in% event, ]
sensitivity <- rbind(events, seasonal_results(wider, reference, "Wider boxes"),
                     seasonal_results(regions, early_reference, "1738-1767 reference"),
                     seasonal_results(wider, early_reference, "Both changes"))
sensitivity <- sensitivity[sensitivity$harvest_year %in% event, ]
write.csv(seasons, file.path(output_dir, "Seasonal_regional_series.csv"), row.names = FALSE)
write.csv(events, file.path(output_dir, "Event_1769_1772.csv"), row.names = FALSE)
write.csv(sensitivity, file.path(output_dir, "Sensitivity.csv"), row.names = FALSE)

month_stats <- function(d, values, year, month, base) {
  i <- which(d$year == year & d$month == month)
  j <- which(d$year %in% base & d$month == month)
  stopifnot(length(i) == 1, length(j) == length(base))
  c(value = values[i], reference = mean(values[j]))
}

monthly_results <- function(boxes, base) {
  do.call(rbind, lapply(seq_len(nrow(boxes)), function(i) {
    box <- boxes[i, ]
    p <- regional_series(prec, box)
    s <- regional_series(slp, box)
    do.call(rbind, lapply(7:8, function(m) {
      ps <- month_stats(prec, p, 1771, m, base)
      ss <- month_stats(slp, s, 1771, m, base)
      data.frame(region = box$region, month = m, precipitation_mm = ps[1],
                 reference_mm = ps[2], precip_anomaly_pct = 100 * (ps[1] / ps[2] - 1),
                 slp_hpa = ss[1], reference_slp_hpa = ss[2], slp_anomaly_hpa = ss[1] - ss[2],
                 row.names = NULL)
    }))
  }))
}

monthly <- monthly_results(regions, reference)
write.csv(monthly, file.path(output_dir, "July_August_1771_regions.csv"), row.names = FALSE)
monthly_checks <- rbind(
  data.frame(scenario = "Main", monthly),
  data.frame(scenario = "Wider boxes", monthly_results(wider, reference)),
  data.frame(scenario = "1738-1767 reference", monthly_results(regions, early_reference)),
  data.frame(scenario = "Both changes", monthly_results(wider, early_reference)))
write.csv(monthly_checks, file.path(output_dir, "July_August_1771_sensitivity.csv"), row.names = FALSE)

region_cells <- do.call(rbind, lapply(seq_len(nrow(regions)), function(i) {
  box <- regions[i, ]
  cells <- expand.grid(longitude = temp$lon[temp$lon >= box$xmin & temp$lon <= box$xmax],
                       latitude = temp$lat[temp$lat >= box$ymin & temp$lat <= box$ymax])
  transform(cells, region = box$region,
            weight = cos(latitude * pi / 180) / sum(cos(latitude * pi / 180)))
}))
write.csv(region_cells, file.path(output_dir, "Region_grid_cells.csv"), row.names = FALSE)

# Figure 1: cumulative rain as bars and seasonal temperature as lines.
pal <- c("Swiss Plateau" = "#153F58", "Czech Lands" = "#95501C")
ink <- "#172D39"
muted <- "#435A63"
rule <- "#DCE4E6"
fig <- function(name, w, h, draw) {
  svg(file.path(output_dir, paste0(name, ".svg")), width = w, height = h,
      pointsize = 14, family = "sans", bg = "white")
  tryCatch(draw(), finally = dev.off())
}

plot_crop_windows <- function() {
  layout(rbind(c(1, 1, 1), c(2, 3, 4)), heights = c(0.55, 3.55))
  par(mar = rep(0, 4), family = "sans", col = ink, fg = ink)
  plot.new()
  legend("center", legend = c("Swiss Plateau", "Czech Lands"), pch = c(16, 0),
         col = unname(pal), pt.cex = 1.2, horiz = TRUE, bty = "n",
         cex = 1.2, x.intersp = 0.6, text.col = ink)
  columns <- c("autumn_anomaly_pct", "spring_anomaly_c", "harvest_anomaly_pct")
  titles <- c("Sowing rain", "Spring temperature", "Harvest rain")
  units <- c("Previous Sep\u2013Oct (%)", "Mar\u2013Apr (\u00b0C)", "Jul\u2013Aug (%)")
  for (i in seq_along(columns)) {
    val <- sapply(names(pal), function(r) events[events$region == r, columns[i]])
    y_ticks <- if (i == 2) -3:2 else seq(-40, 60, 20)
    ylim <- range(y_ticks) + c(-0.04, 0.06) * diff(range(y_ticks))
    stopifnot(all(val > ylim[1] & val < ylim[2]))
    par(mar = c(2.8, 3.05, 3.12, 0.58), cex = 1, mgp = c(1.7, 0.42, 0),
        tcl = -0.24, xaxs = "i", yaxs = "i")
    plot(NA, xlim = c(0.58, 4.42), ylim = ylim, axes = FALSE, xlab = "", ylab = "")
    abline(h = y_ticks, col = rule, lwd = 0.8)
    abline(h = 0, col = muted, lwd = 1.2)
    for (j in 1:2) {
      if (i == 2) {
        lines(seq_along(event), val[,j], lty = j, lwd = 2.5, col = pal[j])
        points(seq_along(event), val[,j], pch = c(21,22)[j], lwd = 2,
               bg = c(pal[1], "white")[j], col = pal[j], cex = 1.0)
      } else {
        xpos <- seq_along(event) + c(-0.16, 0.16)[j]
        rect(xpos - 0.13, pmin(0, val[,j]), xpos + 0.13, pmax(0, val[,j]),
             col = c(pal[1], "white")[j], border = pal[j], lwd = 1.8)
      }
    }
    axis(1, at = seq_along(event), labels = event, col = NA, col.axis = ink, cex.axis = 1)
    axis(2, at = y_ticks, las = 1, col = NA, col.axis = ink, cex.axis = 1)
    mtext(titles[i], side = 3, line = 1.68, cex = 1.27, font = 2, col = ink)
    mtext(units[i], side = 3, line = 0.35, cex = 1.0, col = muted)
    mtext("Harvest year", side = 1, line = 1.5, cex = 0.86, col = muted)
  }
}
fig("Figure_1_crop_windows", 15, 3.92, plot_crop_windows)

# Figure 2: original rain grid cells and sea-level pressure contours.
period_map <- function(month) {
  target <- which(prec$year == 1771 & prec$month == month)
  base <- which(prec$year %in% reference & prec$month == month)
  stopifnot(length(target) == 1, length(base) == length(reference))
  p <- prec$value[, , target]
  p0 <- apply(prec$value[, , base, drop = FALSE], c(1, 2), mean)
  # A tiny denominator produces unstable percentages; a few totals are negative.
  # Mask those cells for display only; no values are zeroed or replaced.
  pct <- matrix(NA_real_, nrow = nrow(p), ncol = ncol(p))
  valid <- p0 >= 5 & p >= 0
  pct[valid] <- 100 * (p[valid] / p0[valid] - 1)
  list(pct = pct, pressure = slp$value[, , target])
}
map_panels <- list(July = period_map(7), August = period_map(8))
palette_file <- file.path(input_dir, "vik.txt")
if (!file.exists(palette_file)) stop("Missing colour table: ", palette_file)
vik <- as.matrix(read.table(palette_file))
stopifnot(nrow(vik) == 256, ncol(vik) == 3, all(is.finite(vik)), all(vik >= 0 & vik <= 1))
map_cols <- rev(rgb(vik[,1], vik[,2], vik[,3]))
rain_lim <- 100
rain_colour <- function(pct) {
  n <- length(map_cols)
  idx <- round((pmax(-rain_lim, pmin(rain_lim, pct)) + rain_lim) / (2 * rain_lim) * (n - 1L)) + 1L
  map_cols[idx]
}

# Spherical Lambert conformal conic, 40 deg N and 60 deg N standard parallels.
# Projection is for display only; diagnostics are evaluated on the ModE-RA grid.
rad <- pi / 180
rho_t <- function(phi) tan(pi/4 + phi/2)
phi_p <- c(40,60) * rad
cone_n <- log(cos(phi_p[1])/cos(phi_p[2])) / log(rho_t(phi_p[2])/rho_t(phi_p[1]))
cone_F <- cos(phi_p[1]) * rho_t(phi_p[1])^cone_n / cone_n
rho_0 <- cone_F / rho_t(50 * rad)^cone_n
project <- function(lon, lat) {
  rho <- cone_F / rho_t(lat * rad)^cone_n
  theta <- cone_n * (lon - 2) * rad
  cbind(x = rho * sin(theta), y = rho_0 - rho * cos(theta))
}
lon_lim <- c(-28, 32)
lat_lim <- c(35, 63)
ring <- function(x1, x2, y1, y2, n = 12) {
  project(c(seq(x1,x2,length.out=n),rep(x2,n),seq(x2,x1,length.out=n),rep(x1,n)),
          c(rep(y1,n),seq(y1,y2,length.out=n),rep(y2,n),seq(y2,y1,length.out=n)))
}
frame <- ring(lon_lim[1],lon_lim[2],lat_lim[1],lat_lim[2],n=120)
edges <- function(x) c(x[1] - diff(x)[1]/2, head(x,-1) + diff(x)/2, tail(x,1) + tail(diff(x),1)/2)
identifiers <- c("CH", "CZ")
pressure_levels <- seq(995,1035,5)
shore <- map("world", plot = FALSE, interior = FALSE, xlim = lon_lim, ylim = lat_lim)

draw_path <- function(lon, lat, ...) {
  # Interpolate line vertices before clipping the lon/lat paths at the map edge.
  split_ids <- cumsum(!is.finite(lon) | !is.finite(lat))
  for (ii in split(seq_along(lon),split_ids)) {
    ii <- ii[is.finite(lon[ii]) & is.finite(lat[ii])]
    if (length(ii) < 2) next
    distance <- c(0,cumsum(sqrt(diff(lon[ii])^2 + diff(lat[ii])^2)))
    distance_end <- tail(distance,1)
    if (distance_end == 0) next
    k <- sort(unique(c(distance,seq(0,distance_end,length.out=max(2,ceiling(distance_end/0.09))))))
    xx <- approx(distance,lon[ii],k,ties="ordered")$y
    yy <- approx(distance,lat[ii],k,ties="ordered")$y
    ok <- xx >= lon_lim[1] & xx <= lon_lim[2] & yy >= lat_lim[1] & yy <= lat_lim[2]
    xy <- project(xx,yy)
    xy[!ok,] <- NA_real_
    lines(xy,...)
  }
}

tag <- function(xy, label, cex = 0.92, bold = FALSE) {
  px <- xy[1]; py <- xy[2]
  hw <- strwidth(label,cex=cex,font=1+bold)/2 + 0.0023
  hh <- strheight(label,cex=cex,font=1+bold)/2 + 0.0027
  rect(px-hw,py-hh,px+hw,py+hh,col="#F9FBFC",border=NA)
  text(px,py,label,cex=cex,font=1+bold,col=ink)
}

plot_weather <- function() {
  x <- order(prec$lon); y <- order(prec$lat)
  xgrid <- prec$lon[x]; ygrid <- prec$lat[y]
  xe <- edges(xgrid); ye <- edges(ygrid)
  p <- vector("list",length(xgrid)*length(ygrid))
  for (i in seq_along(xgrid)) for (j in seq_along(ygrid)) {
    x1 <- max(xe[i],lon_lim[1]); x2 <- min(xe[i+1],lon_lim[2])
    y1 <- max(ye[j],lat_lim[1]); y2 <- min(ye[j+1],lat_lim[2])
    if (x1 < x2 && y1 < y2) p[[(j-1)*length(xgrid)+i]] <- ring(x1, x2, y1, y2, n=4)
  }
  layout(rbind(c(1,2),c(3,3)),heights=c(4.63,1.04))
  for (m in names(map_panels)) {
    panel <- map_panels[[m]]
    par(mar=c(0.36,0.38,1.86,0.38),xaxs="i",yaxs="i",cex=1,fg=ink)
    plot.new()
    plot.window(range(frame[,"x"])+c(-0.021,0.009), range(frame[,"y"])+c(-0.015,0.005), asp=1)
    rain <- panel$pct[x,y]
    for (i in seq_along(p)) if (!is.null(p[[i]])) {
      col <- if (is.na(rain[i])) "#F5F6F6" else rain_colour(rain[i])
      polygon(p[[i]],col=col,border=col,lwd=0.45)
      if (is.na(rain[i])) polygon(p[[i]],density=14,angle=45,col="#A0AAAD",border=NA)
    }
    for (v in c(-20,0,20)) lines(project(v,seq(lat_lim[1],lat_lim[2],length.out=120)),
                                  lty=3,col="#59717E",lwd=0.7)
    for (v in c(40,50,60)) lines(project(seq(lon_lim[1],lon_lim[2],length.out=120),v),
                                 lty=3,col="#59717E",lwd=0.7)
    draw_path(shore$x,shore$y,col="#53636A",lwd=1.0)
    isobars <- contourLines(xgrid,ygrid,panel$pressure[x,y],levels=pressure_levels)
    for (line in isobars) {
      draw_path(line$x,line$y,col="#F4F7F8",lwd=2.15)
      draw_path(line$x,line$y,col="#20333C",lwd=0.85)
    }
    for (level in c(1010,1015,1020,1025)) {
      ll <- Filter(function(q) q$level == level,isobars)
      xx <- unlist(lapply(ll,function(q) q$x))
      yy <- unlist(lapply(ll,function(q) q$y))
      ii <- which(xx > -25 & xx < 25 & yy > 37 & yy < 61)
      if (length(ii)) {
        k <- ii[which.min(abs(xx[ii]+17))]
        tag(project(xx[k],yy[k]), as.character(level),cex=0.88)
      }
    }
    for (j in seq_len(nrow(regions))) {
      b <- regions[j, ]
      region <- ring(b$xmin,b$xmax,b$ymin,b$ymax)
      polygon(region,border="white",lwd=4.0)
      polygon(region,border=ink,lwd=2.1,lty=j)
      tag(project((b$xmin+b$xmax)/2,b$ymin-1.1),identifiers[j],cex=0.95,bold=TRUE)
    }
    polygon(frame,border=muted,lwd=0.95)
    for (v in c(40,50,60)) {
      xy <- project(lon_lim[1],v)
      text(xy[1]-0.012,xy[2],paste0(v,"\u00b0N"),adj=1,cex=0.85,col=ink,xpd=NA)
    }
    for (v in c(-20,0,20)) {
      xy <- project(v,lat_lim[1])
      text(xy[1],xy[2]-0.012,c("20\u00b0W","0\u00b0","20\u00b0E")[match(v,c(-20,0,20))],
           adj=0.5,cex=0.85,col=ink,xpd=NA)
    }
    mtext(paste(m,"1771"),side=3,line=0.42,font=2,cex=1.4,col=ink)
  }
  par(mar=c(2.26,1.5,0.28,1.5),mgp=c(1.4,0.32,0),xaxs="i",yaxs="i",tcl=-0.2)
  plot.new()
  plot.window(xlim=c(-166,166),ylim=c(0,1))
  levels <- seq(-rain_lim,rain_lim,length.out=length(map_cols)+1)
  rect(head(levels,-1),0,pmin(tail(levels,-1)+0.50,rain_lim),1,col=map_cols,border=NA)
  rect(-rain_lim,0,rain_lim,1,border=muted,lwd=0.85)
  axis(1,at=c(-100,-50,0,50,100),labels=c("\u2264\u2212100","\u221250","0","+50","\u2265+100"),
       col=muted,col.axis=ink,cex.axis=0.92)
  text(-110,0.5,"Drier",adj=1,cex=0.95,col=ink)
  text(110,0.5,"Wetter",adj=0,cex=0.95,col=ink)
  mtext("Monthly rainfall anomaly (%)",side=1,line=1.34,cex=0.92,col=muted)
}
fig("Figure_2_weather_1771", 14, 6.02, plot_weather)

writeLines(capture.output(sessionInfo()), file.path(output_dir, "R_session.txt"))
print(events[, c("region", "harvest_year", "autumn_anomaly_pct", "spring_anomaly_c", "harvest_anomaly_pct")],
      row.names = FALSE, digits = 4)
print(monthly, row.names = FALSE, digits = 4)
