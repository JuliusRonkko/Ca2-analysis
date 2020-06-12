function [s, d] = Detect_current_usual(region,nn,period)



s=[];
d=[];
[s d] = hippodettrial(region.traces(nn,:));
