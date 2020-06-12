function [tr, param] = HippoTR_ReadTraces(fname,region,numframes)
%global t1 ff
tr = zeros(length(region.contours),0);
param = [];
% Program used by Hippo
% Reads traces as average fluorescence values inside the contours
if numframes ~= 1
    tfig = figure('Name','Reading traces...','NumberTitle','off','MenuBar','none','doublebuffer','on','units','normalized','position',[0.3    0.5    0.4    0.025]);
    
    inf = imfinfo(fname);
    
    if strcmp(inf(1).ByteOrder,'little-endian');
        readspec='ieee-le';
    elseif strcmp(inf(1).ByteOrder,'big-endian');
        readspec='ieee-be';
    end
    fid = fopen(fname,'rb',readspec);
    
    
    tr = zeros(length(region.contours),length(inf));
    prg = zeros(1,length(region.contours)+1);
    figure(tfig);
    subplot('position',[0 0 1 1]);
    set(gca,'xtick',[],'ytick',[]);
    for c = 1:length(region.contours)
        %c
        prg(c) = 1;
        figure(tfig);
        imagesc(prg);
        set(gca,'xtick',[],'ytick',[]);
        drawnow
        im=imread(fname,1);
        ps = round(region.contours{c});
        [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)),min(ps(:,2)):max(ps(:,2)));
        inp = inpolygon(subx,suby,region.contours{c}(:,1),region.contours{c}(:,2));
        fx = subx(find(inp==1));
        fy = suby(find(inp==1));
        if max(fx)>size(im,2)|| min(fx)<1||max(fy)>size(im,1)|| min(fy)<1
            delete(tfig)
            error (['ROI ', num2str(c), ' is out of range, please correct'])
        else
            f{c} = sub2ind(size(im),fy,fx);
        end
    end
    
    prg = zeros(1,length(inf)+1);
    for d = 1:length(inf)
        prg(d) = 1;
        figure(tfig);
        imagesc(prg);
        % d
        im=imread(fname,d);
        drawnow
        for c = 1:length(region.contours)
            tr(c,d) = mean(im(f{c}));
        end
    end
    
    
    
    
    delete(tfig);
end