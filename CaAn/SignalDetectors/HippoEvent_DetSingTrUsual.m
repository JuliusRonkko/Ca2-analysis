function [s, d] = HippoEvent_DetSingTrUsual(region,nn,period)



s=[];
d=[];
[s d] = hippodettrial(region.traces(nn,:));
