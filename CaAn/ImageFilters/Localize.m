function [loca, param] = HippoIFLocalize(fname,region)

answer = inputdlg('Cell diameter (pixels):','Input for the localization filter',1,{'12'});
if isempty(answer)
    loca = region.image;
    param = [];
    return
end
rad = str2num(answer{1});
param = rad;

tfig = figure('Name','Localizing...','NumberTitle','off','MenuBar','none','doublebuffer','on','units','normalized','position',[0.3    0.5    0.4    0.025]);

a = region.image;

aat = [repmat(a(:,1),1,rad) a repmat(a(:,end),1,rad)];
aat = [repmat(aat(1,:),rad,1); aat; repmat(aat(end,:),rad,1)];
loca = zeros(size(a,1),size(a,2));

pr = zeros(1,2*rad+2);
figure(tfig);
subplot('position',[0 0 1 1]);
set(gca,'xtick',[],'ytick',[]);
for c = -rad:rad
    pr(1,sum(pr)+1) = 1;
    figure(tfig);
    imagesc(pr);
    set(gca,'xtick',[],'ytick',[]);
    drawnow
    
    for d = -rad:rad
        loca = loca+aat(c+rad+1:end-rad+c,d+rad+1:end-rad+d);
    end
end
loca = loca/(2*rad+1)^2;
loca = a./(loca+eps);

[x y] = meshgrid(-rad:rad);
gs = exp(-(x.^2+y.^2)/rad);
loca = xcorr2(loca,gs);
loca = loca(rad+1:end-rad,rad+1:end-rad);

delete(tfig);