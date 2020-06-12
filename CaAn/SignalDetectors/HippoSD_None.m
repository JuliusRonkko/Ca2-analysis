function [onsets, offsets, param] = HippoSD_None(fname,region)

onsets = cell(1,length(region.contours));
offsets = cell(1,length(region.contours));
param = [];