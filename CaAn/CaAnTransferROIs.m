
region.contours = {};
region.location = [];

for c = 1:length(cn)
    for d = 1:length(cn{c})
        if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c)
            region.contours{length(region.contours)+1} = cn{c}{d};
            region.location = [region.location c];
        end
    end
end



for num=1:length(region.name)
    CaAncontourarraysetup;
    CaAnDrawCells;
end
%-----------------------------------------------------------------------------
zoom on
