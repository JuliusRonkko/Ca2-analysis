if old_thres(num) == thres(num)
    CaAnDrawCells
    return
else
    old_thres(num) = thres(num);
    isadjust(num) = 0;
    isdetected(num) = 1;
end
    
rloc = fliplr(sort(reshape(loca,1,prod(size(loca)))));
ind = round(length(rloc)*thres(num)/100);


% % miaparte
% s1=1.5;
% x=-s1-10:s1+10;
% gg=1/(sqrt(2*pi)*s1)* exp(-(x.^2)/(2*s1^2));
% gg=diff(gg);
% 
% imPrY=[];
% for i=1:size(region.image,2)
%     imPrY=[imPrY conv(gg',region.image(:,i))];
% end
% imPrX=[];
% for i=1:size(region.image,1)
%     imPrX=[imPrX; conv(gg,region.image(i,:))];
% end
% imPr=sqrt(imPrX(:,x(end):end-x(end)).^2+imPrY(x(end):end-x(end),:).^2);
% noiseReg=imPr(450:510,230:270);
% thr=mean(noiseReg(:))+4*std(noiseReg(:));
% loca=imPr;
% %%%%% mia parte

if ind > 0
    thr = rloc(ind);
    
    h = contourc(loca,[thr thr]);
    ind = 1;
    cn{num} = [];
    while 1
        v = h(2,ind);
        coords = [h(1,ind+1:ind+v)' h(2,ind+1:ind+v)'];
        ind = ind+v+1;
        if ind > size(h,2)
            break
        end
        if polyarea(coords(1:end-1,1),coords(1:end-1,2)) > 0
            cn{num}{size(cn{num},2)+1} = coords(1:end-1,:);
        end
    end
    
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
    
else
    cn{num} = [];
    centr{num} = [];
    areas{num} = [];
end

CaAnDrawCells