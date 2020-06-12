function [tr, param] = HippoTR__None_(fname,region,numframes)
% Program used by Hippo
% Does not read traces

param = [];
tr = zeros(length(region.contours),0);
%trhalo = [];