%Set up cn array variable equal to the region.contour data that can be passed to HippoCentroid, HippoDrawCells, and HippoManualDelete. Modified from HippoFindCells
cn{num} = region.contours;
centr{num} = [];
areas{num} = [];
for c = 1:length(cn{num})
	centr{num}(c,:) = CaAnCentroid(cn{num}{c});
	areas{num}(c) = polyarea(cn{num}{c}(:,1),cn{num}{c}(:,2));
end

in = inpolygon(centr{num}(:,1),centr{num}(:,2),region.coords{num}(:,1),region.coords{num}(:,2));
for c = 1:length(region.name)
	if polyarea(region.coords{c}(:,1),region.coords{c}(:,2)) < polyarea(region.coords{num}(:,1),region.coords{num}(:,2))
		inoth = inpolygon(centr{num}(:,1),centr{num}(:,2),region.coords{c}(:,1),region.coords{c}(:,2));
		in(find(inoth==1)) = 0;
	end
end    
	
f = find(in);
centr{num} = centr{num}(f,:);
areas{num} = areas{num}(f);
cntemp = [];
for c = 1:length(f)
	cntemp{c} = cn{num}{f(c)};
end
cn{num} = [];
for c = 1:length(cntemp)
	cn{num}{c} = cntemp{c};
end

