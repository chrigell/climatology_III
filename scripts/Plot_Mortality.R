# Mortality during the famine, from Pfister and Brazdil (2006), Figure 6.
args <- if (sys.nframe() == 0L) commandArgs(trailingOnly = TRUE) else character()
script_dir <- "."
if (sys.nframe() == 0L) {
  script <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(script)) script_dir <- dirname(normalizePath(sub("^--file=", "", script[1L]),
                                                        winslash = "/"))
}
out_dir <- if (length(args)) args[1L] else file.path(script_dir, "results")
if (!capabilities("cairo")) stop("Use an R build with Cairo support for SVG export.", call. = FALSE)
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
# Approximate values digitised from the curves in Figure 6, p. 125.
# Pfister and Brazdil (2006): https://doi.org/10.5194/cp-2-115-2006
# The digitised trace and adapted figure are CC BY-NC-SA 2.5:
# https://creativecommons.org/licenses/by-nc-sa/2.5/
trace <- read.csv(text = "Year,Bern_y_px,Bohemia_y_px,Moravia_y_px
1760,342,772,762
1761,279,771,762
1762,271,754,756
1763,255,754,760
1764,235,777,766
1765,236,778,768
1766,245,773,770
1767,271,773,770
1768,245,777,763
1769,286,774,761
1770,315,773,766
1771,260.5,705,747
1772,273.5,584,707
1773,329,782,756
1774,326,799,782
1775,322,778,762
1776,347,773,763
1777,286,788,777
1778,243.5,772,753
1779,319.5,763,740
1780,326,781,781")
stopifnot(identical(trace$Year, 1760:1780), !anyNA(trace))

# Upper axis: 40 deaths/1000 at y = 152 and 10 at y = 472.
# Lower axis: index 300 at y = 548 and 0 at y = 868.
bern_rate <- 40 - 30 * (trace$Bern_y_px - 152) / (472 - 152)
# Express each series as a percentage departure from its own 1760-1780 mean.
# The source already sets the mean to 100 for the Czech series.
count_departure <- function(y) 300 * (868 - y) / (868 - 548) - 100
departure <- cbind(Bohemia = count_departure(trace$Bohemia_y_px),
                   Moravia = count_departure(trace$Moravia_y_px),
                   Bern = 100 * (bern_rate / mean(bern_rate) - 1))
yr <- trace$Year
csv <- data.frame(year = yr, bern_deaths_per_1000 = round(bern_rate, 1),
                  bern_departure_pct = round(departure[, "Bern"]),
                  bohemia_departure_pct = round(departure[, "Bohemia"]),
                  moravia_departure_pct = round(departure[, "Moravia"]))
write.csv(csv, file.path(out_dir, "Mortality_departure_pct.csv"), row.names = FALSE)

fig <- function() {
  ink <- "#172D39"
  cl <- c("#95501C", "#5D6770", "#153F58")
  line_type <- c(1, 2, 4)
  line_size <- c(3.6, 2.6, 2.6)
  bohemian_peak <- which.max(departure[, "Bohemia"])
  xticks <- c(1760, 1765, 1770, 1772, 1775, 1780)
  yticks <- seq(-50, 150, by = 50)
  ylabels <- ifelse(yticks == 0, "0%", sprintf("%+d%%", yticks))
  ylabels <- sub("^-", "\u2212", ylabels)
  svg(file.path(out_dir, "Figure_3_mortality.svg"),
      width = 9.15, height = 3.04, pointsize = 14.5, family = "Arial", bg = "white")
  on.exit(dev.off())
  par(mar = c(1.82, 3.16, 1.60, 0.55), mgp = c(1.65, 0.43, 0),
      xaxs = "i", yaxs = "i", tcl = -0.24, fg = ink)
  plot(yr, departure[, "Bohemia"], xlim = c(1759.65, 1780.5), ylim = c(-54, 190),
       xlab = "", ylab = "", axes = FALSE, type = "n")
  abline(h = yticks, col = "#D4E0E5", lwd = 1)
  abline(v = yr[bohemian_peak], col = "#AFBAC0", lwd = 1.1, lty = 3)
  abline(h = 0, col = "#92A5AE", lwd = 1.45)
  for (j in c(2L, 3L, 1L)) {
    lines(yr, departure[, j], col = cl[j], lty = line_type[j], lwd = line_size[j])
  }
  peak <- departure[bohemian_peak, "Bohemia"]
  points(yr[bohemian_peak], peak, pch = 21,
         cex = 1.17, lwd = 1.4, col = "white", bg = cl[1])
  label <- sprintf("\u2248%d%% above average", round(peak, -1L))
  text(yr[bohemian_peak] + 0.58, peak, label,
       adj = c(0, 0.5), col = cl[1], font = 2, cex = 1.02)
  axis(1, at = xticks, cex.axis = 0.95, col.axis = ink, lwd = 1.1)
  axis(2, at = yticks, labels = ylabels, las = 1, cex.axis = 0.95,
       col.axis = ink, lwd = 1.1)
  mtext("Departure from each region\u2019s 1760\u20131780 mean", side = 3,
        line = 0.28, adj = 0, cex = 1.06, col = ink)
  legend("topleft", inset = c(0.018, 0.018),
         legend = c("Bohemia", "Moravia", "Canton of Bern"),
         col = cl, lty = line_type, lwd = line_size, bty = "n",
         text.col = ink, cex = 0.98, seg.len = 2.3, y.intersp = 0.88)
}
fig()
