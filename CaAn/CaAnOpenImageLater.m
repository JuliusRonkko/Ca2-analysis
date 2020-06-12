
[fname, pathname] = uigetfile({'*.tif'}, 'Choose destination image for ROI transfer');

if ~isstr(fname)
    return
end

fnm=fullfile(pathname,fname);
info = imfinfo(fnm);
numframes = length(info);


pr = zeros(1,numframes,3);
%region = [];

if numframes == 1
    a = double(imread(fnm));
    button = questdlg({'The file contains one frame.','How was it obtained?'},'Frame information','Average','Maximum','First frame','Average');
    if strcmp(button,'Average')
        region.frametype = 'average';
    elseif strcmp(button,'Maximum')
        region.frametype = 'maximum';
    elseif strcmp(button,'First frame')
        region.frametype = 'first';
    end
else
    button = questdlg({['The file contains ' num2str(numframes) ' frames.'],'Choose the operation to perform.'},'Frame information',...
        'Average','Maximum','First frame','Average');
    if strcmp(button,'Average')
        button2 = questdlg({['how many frames to average?'],'Choose the operation to perform.'},'Frame information',...
            'All','1/4','1/10','All');
        if strcmp(button2,'All')
            region.frametype = 'average';
            a = zeros(info(1).Height,info(1).Width);
            for c = 1:numframes
                if mod(c,20)==1
                    prg = subplot('position',[.87 .575 .11 0.025]);
                    imagesc(pr);
                    axis off
                    drawnow;
                    delete(prg);
                end
                a = a + double(imread(fnm,c));
                pr(1,c,1) = 1;
            end
            a = a / numframes;
        elseif strcmp(button2,'1/4')
            pr = zeros(1,round(numframes/4),3);
            region.frametype = 'Average 1/4';
            hi=randperm(numframes);
            frRand=hi(1:round(numframes/4));
            a = zeros(info(1).Height,info(1).Width);
            hi=0;
            for c = frRand
                hi=hi+1;
                if mod(c,20)==1
                    prg = subplot('position',[.87 .575 .11 0.025]);
                    imagesc(pr);
                    axis off
                    drawnow;
                    delete(prg);
                end
                a = a + double(imread(fnm,c));
                pr(1,hi,1) = 1;
            end
            a = a / round(numframes/4) ;
        elseif strcmp(button2,'1/10')
            pr = zeros(1,round(numframes/10),3);
            region.frametype = 'Average 1/10';
            hi=randperm(numframes);
            frRand=hi(1:round(numframes/4));
            a = zeros(info(1).Height,info(1).Width);
            hi=0;
            for c = frRand
                hi=hi+1;
                if mod(c,20)==1
                    prg = subplot('position',[.87 .575 .11 0.025]);
                    imagesc(pr);
                    axis off
                    drawnow;
                    delete(prg);
                end
                a = a + double(imread(fnm,c));
                pr(1,hi,1) = 1;
            end
            a = a / round(numframes/10) ;
        end
    elseif strcmp(button,'Maximum')
        region.frametype = 'maximum';
        a = uint16(zeros(info(1).Height,info(1).Width,2));
        for c = 1:numframes
            if mod(c,20)==1
                prg = subplot('position',[.87 .575 .11 0.025]);
                imagesc(pr);
                axis off
                drawnow;
                delete(prg);
            end
            a(:,:,2) = imread(fnm,c);
            a(:,:,1) = max(a,[],3);
            pr(1,c,1) = 1;
        end
        a = double(a(:,:,1));
    elseif strcmp(button,'First frame')
        region.frametype = 'first';
        a = double(imread(fnm,1));
    end
end

%delete(logoim)
%delete(logoname)
%delete(ref)

imgax = subplot('position',[0.02 0.02 0.82 0.96]);
imagesc(a);
hold on

set(gca,'xtick',[],'ytick',[]);
axis equal
axis tight
box on

colormap gray

% set(bzoom,'enable','on');
% set(bbright,'enable','on');
% set(bcontrast,'enable','on');
% set(bnext,'enable','on');
% set(inptsr,'enable','on');
% set(inpttr,'enable','on');


[maxy maxx] = size(a);

zoom on;
CaAnTransferROIs;