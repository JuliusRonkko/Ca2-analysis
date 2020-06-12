# build averages
lib <- c("openxlsx","pracma","ggplot2", "reshape2","cowplot"); for(i in lib){ require(i, character.only=T) }; rm(lib)
path <- getwd() 
path <- choose.dir(default = "", caption = "Select folder"); setwd(path)
files <- grep("txt$",dir(path),value=T)
dir.create("averages/")
meanPeaks <- c()
meanSmooth <- c()
for(i in files){
  	  raw.data <- read.table(paste0(path,"/",i), sep="\t")
	  # exclude columns that are empty
	  raw.data <- raw.data[,colSums(is.na(raw.data)) != nrow(raw.data)]
	  # exclude rows that are empty
	  raw.data <- raw.data[rowSums(is.na(raw.data))  != ncol(raw.data),]
	  
	  if(sum(is.na(raw.data))!=0){
		  raw.data[is.na(raw.data)] <- mean(unlist(raw.data),na.rm=T)
	  } else {
		  raw.data <- raw.data
	  }
	  smoothed.data <- raw.data
	  for(j in 1:ncol(raw.data)){ smoothed.data[,j] <- whittaker(raw.data[,j], lambda=10) } # smooth a lot less by reducing lambda
	  # combine mean peaks to one file for all samples
	  meanPeaks <- rbind(meanPeaks, data.frame("time" = 1:nrow(raw.data), "intensity" = rowMeans(raw.data),"sample" = gsub(".txt","",i)))
	  # combine smoothed data
	  meanSmooth <- rbind(meanSmooth, data.frame("time" = 1:nrow(smoothed.data), "intensity" = rowMeans(smoothed.data),"sample" = gsub(".txt","",i)))
}
# plot mean peaks with smoothed line (loess with span 0.1)
ggplot(meanPeaks, aes(x=time, y=intensity, color=sample)) + geom_point() + geom_smooth(method="loess", span=0.1, se=FALSE) + theme_classic()

# compare raw and smoothed averages
p <- list()
p[["raw"]] <- ggplot(meanPeaks, aes(x=time, y=intensity, color=sample)) + geom_point(show.legend=F) + geom_line(show.legend=F) + theme_classic() + labs(title="Mean intensities raw data")
p[["smooth"]] <- ggplot(meanSmooth, aes(x=time, y=intensity, color=sample)) + geom_point() + geom_line() + theme_classic() + labs(title="Mean intensities smoothed data")
plot_grid(plotlist=p)

# save mean values
write.table(meanPeaks, file="averages/meanPeaks_allSamples.txt", sep="\t")
write.table(meanSmooth, file="averages/meanSmooth_allSamples.txt", sep="\t")

combined.peaks <- c()
{
# build the new input data from mean values
times <- 1:max(meanPeaks$time)
raw.data <- c()
for(i in levels(meanPeaks$sample)){
	tmp <- meanPeaks[meanPeaks$sample == i,]
	raw.data <- cbind(raw.data, tmp[match(times, tmp$time),"intensity"])
}
colnames(raw.data) <- levels(meanPeaks$sample)

if(sum(is.na(raw.data))!=0){
	raw.data[is.na(raw.data)] <- mean(unlist(raw.data),na.rm=T)
} else {
	raw.data <- raw.data
}

npoints <- 5
# Raw peak identification finds a bunch of "noise peaks", remove them by filtering the raw data
# define the filtering criteria here
peak.filter <- data.frame("min.peak.intensity" = 0,           # a peak needs to exceed this threshold
                          "peak.intensity.delta" = 0,       # difference between peak maximum and intensity at the end of peak
                          "peak.start.time" = 0  ,            # range within which peaks need to occure
                          "peak.end.time" = 121,
                          "minimum.decay.constant" = 0)       # random noise peaks can have negative decays within 20-80% range

smoothed.data <- raw.data
# smooth out the data for peak detection in noisy data	
for(j in 1:ncol(raw.data)){ smoothed.data[,j] <- whittaker(raw.data[,j], lambda=10) } # smooth a lot less by reducing lambda
    
    # combine data across all samples to one data.frame 
    unfiltered.peaks <- c()
    # add zeros to start and end of data for problematic peaks
    smoothed.data <- rbind(matrix(0, ncol=ncol(smoothed.data), nrow=10), smoothed.data)
    smoothed.data <- rbind(smoothed.data, matrix(0, ncol=ncol(smoothed.data), nrow=10))
    
    for(j in colnames(smoothed.data)){
      # Detect peaks (peak denined as continuous increase of 5 measurement points followed by 5 continuously decreasing points)
      peak <- findpeaks(smoothed.data[,j], nups = npoints, ndowns = npoints)[,1:2]
      if(is.null(peak)){
        # If no peaks are detected skip sample
        print(paste0("no peaks in sample: ",j)) 
      } else {
        # If peaks are detected proceed
        
        if(is.null(dim(peak))){
          # with only one peak force data into a matrix
          peak <- matrix(peak, ncol=2)
        } else {
          # otherwise proceed normally
          peak <- peak
        }
        
        # put peaks into a data.frame		
        peak <- data.frame("intensity" = peak[,1], "time" = peak[,2])
        
        # define start of the peak
        peak.start <- findpeaks(-smoothed.data[,j], nups = 0, ndowns = npoints)[,1:2]
        # with only one peak force data into a matrix
        if(is.null(dim(peak.start))){ peak.start <- matrix(peak.start, ncol=2) } else { peak.start <- peak.start }
        peak.start <- data.frame("intensity" = peak.start[,1]*-1, "time" = peak.start[,2])
        # select peak start closest to detected peak
        o <- c(); for(k in 1:nrow(peak)){ o <- c(o, max(which(peak.start[,2]<peak[k,2]))) }; peak.start <- peak.start[o,]
        # define end of the peak
        peak.end <- findpeaks(-smoothed.data[,j], nups = npoints, ndowns = 0)[,1:2]
        # with only one peak force data into a matrix
        if(is.null(dim(peak.end))){ peak.end <- matrix(peak.end, ncol=2) } else { peak.end <- peak.end }
        peak.end <- data.frame("intensity" = peak.end[,1]*-1, "time" = peak.end[,2])
        # select peak end closest to detected peak
        o <- c(); for(k in 1:nrow(peak)){ o <- c(o, min(which(peak.end[,2]>peak[k,2]))) }; peak.end <- peak.end[o,]
        
        # combine peaks, start and end information
        peak.data <- data.frame("sample" = j,                                         # name of the sample (1-n)
                                "start.intensity"  = peak.start$intensity,            # intensity @ start of the peak
                                "peak.intensity" = peak$intensity,                    # intensity @ peak maxima
                                "end.intensity"   = peak.end$intensity,               # intensity @ end of the peak
                                
                                "start.time" = peak.start$time-10,                    # time @ start of the peak
                                "peak.time"  = peak$time-10,                          # time @ peak maxima
                                "end.time"   = peak.end$time-10,                      # time @ end of the peak
                                
                                "AUC" = NA,                                           # area under the curve
                                "max.amplitude" = peak$intensity,                     # maximum intensity
                                "half.amplitude"= NA,                                 # 1/2 of max intensity
                                "peak.width" = peak.end$time - peak.start$time,       # total width (time) of the peak
                                "half.width" = NA,                                    # 1/2 width of the peak
                                "decay.constant" = NA,                                # decay constant
                                "decay.constant.20_80" = NA,                          # decay constant (between 20-80% of peak time)
                                "rise.time" = NA,                                     # duration to peak maxima from peak start
                                "rise.time.20_80" = NA)                               # .. (between 20-80% of peak time)
        # fill in the missing data for AUC etc.
        for(k in 1:nrow(peak.data)){ 
          # add area under the curve (AUC):
          peak.data$AUC[k] <- trapz(smoothed.data[(peak.data$start.time[k]+10):(peak.data$end.time[k]+10),j])
          
          # add decay.constant (assuming 1st order decay):
          # from peak to end
          peak.max <- peak.data$peak.intensity[k]-peak.data$end.intensity[k]+1
          peak.min <- peak.data$end.intensity[k]-peak.data$end.intensity[k]+1
          peak.data$decay.constant[k] <- log(peak.max/peak.min)/ (peak.data$end.time[k]-peak.data$peak.time[k]) 
          # from 20% - 80% time interval of peak to end
          # define 20-80% time interval between peak maximum and peak end
          time.interval <- round(quantile(peak.data$peak.time[k]:peak.data$end.time[k], probs=seq(from=0.2,to=0.8,by=0.6)))
          intensity.interval <- smoothed.data[(time.interval+10),j]
          intensity.interval <- intensity.interval-intensity.interval[2]+1
          peak.data$decay.constant.20_80[k] <- log(intensity.interval[1]/intensity.interval[2]) / (time.interval[2]-time.interval[1])
          # half-amplitude:
          peak.data$half.amplitude[k] <- peak.data$start.intensity[k] + (peak.data$peak.intensity[k] - peak.data$start.intensity[k])/2
          # half-width (duration of peak above half amplitude)
          o <- which(smoothed.data[,j] > peak.data$half.amplitude[k])
          o <- range(o[o > (peak.data$start.time[k]+10) & o < (peak.data$end.time[k]+10)])
          peak.data$half.width[k] <- o[2]-o[1]
          
          # rise time:
          peak.data$rise.time[k] <- peak.data$peak.time[k] - peak.data$start.time[k]
          time.interval <- round(quantile(peak.data$start.time[k]:peak.data$peak.time[k], probs=seq(from=0.2,to=0.8,by=0.6)))
          peak.data$rise.time.20_80[k] <- time.interval[2] - time.interval[1]
          
        }
        unfiltered.peaks <- rbind(unfiltered.peaks, peak.data)
      }
    }
    
    # write down unfiltered data
    write.xlsx(unfiltered.peaks, file=paste0("averages/unfiltered_",gsub("txt","xlsx",i)))
    
    # define criteria for filtering raw peaks
    filtered.peaks <- subset(unfiltered.peaks, peak.intensity > peak.filter$min.peak.intensity & 
                               (peak.intensity - end.intensity) > peak.filter$peak.intensity.delta  &
                               peak.time > peak.filter$peak.start.time& 
                               peak.time < peak.filter$peak.end.time& 
                               decay.constant.20_80 > peak.filter$minimum.decay.constant)

    
    # write down filtered data
    write.xlsx(filtered.peaks, file=paste0("averages/filtered_",gsub("txt","xlsx",i)))
    
    combined.peaks <- rbind(combined.peaks, filtered.peaks)
  
  # write down combined peaks
  write.xlsx(combined.peaks, file="averages/combined_peaks.xlsx")
  
  # order by file, sample and maximum peak intensity
  combined.peaks <- combined.peaks[order(combined.peaks$sample, combined.peaks$peak.intensity, decreasing=T),]
  # give a unique id for each sample (file + sample number)
  combined.peaks$id <- combined.peaks$sample
  # identify the number of peaks per sample
  nro.peaks <- table(combined.peaks$id)
  combined.peaks$nro.peaks <- nro.peaks[match(combined.peaks$id, names(nro.peaks))]
  sum.auc <- tapply(combined.peaks$AUC, combined.peaks$id, sum)
  combined.peaks$sum.auc <- sum.auc[match(combined.peaks$id, names(sum.auc))]
  
  # exclude duplicate peaks (retaining the highest peak only)
  combined.peaks <- combined.peaks[!duplicated(combined.peaks$id),]
  write.xlsx(combined.peaks, file="averages/max.peaks.xlsx")
  
}
rm("i","j","k","o","path","files","peak.data","peak.start","peak","peak.end","time.interval", "intensity.interval", "nro.peaks","sum.auc")

{ ## make a summary pdf figure
p <- list()
# plot peak times, comparing samples
p[[1]] <- ggplot(combined.peaks, aes(y=peak.time, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Peak time (seconds)")
# barplot of peak numbers
p[[2]] <- ggplot(combined.peaks, aes(y=nro.peaks, x=sample, fill=as.factor(nro.peaks))) + geom_bar(stat="identity") + theme_classic() + labs(x="",y="Total number of peaks") + scale_fill_discrete(name = "Number of peaks")
p[[3]] <- ggplot(combined.peaks, aes(y=sum.auc, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Peak time (seconds)")
p[[4]] <- ggplot(combined.peaks, aes(y=peak.intensity, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Peak intensity")
p[[5]] <- ggplot(combined.peaks, aes(y=peak.width, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Peak width")
p[[6]] <- ggplot(combined.peaks, aes(y=decay.constant, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Decay constant")
p[[7]] <- ggplot(combined.peaks, aes(y=decay.constant.20_80, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Decay constant (within 20-80% range)")
p[[8]] <- ggplot(combined.peaks, aes(y=rise.time, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Rise time")
p[[9]] <- ggplot(combined.peaks, aes(y=rise.time.20_80, x=sample, color=sample)) + geom_violin(show.legend=F) + geom_boxplot(width=0.1, show.legend=F) + theme_classic() + labs(x="", y="Rise time (within 20-80% range)")

pdf("averages/figurepanel.pdf", height=10, width=14)
print(cowplot::plot_grid(plotlist=p))
dev.off()
}
