% read traces from multiple files
[mat, matpath] = uigetfile({'*.mat'}, 'Choose mat file with ROI contours');

if ~isstr(mat)
    return
end

fnm=fullfile(matpath,mat);

load(fnm,'region')
region_ori=region;
[tiffs, tiffpath] = uigetfile({'*.tif'}, 'Choose destination images for ROI transfer', 'MultiSelect', 'on');
for f=1:length(tiffs)
    fnm=fullfile(tiffpath,tiffs{f});
    [~,fname,ext] = fileparts(fnm);
    
    if ext(2:end)~='tif'
        error('No image series detected, please select only tif time-lapse files')
    end
end

for f=1:length(tiffs)
    fnm=fullfile(tiffpath,tiffs{f});
    [~,fname,ext] = fileparts(fnm);
    
    info = imfinfo(fnm);
    numframes = length(info);
    
    %         region.contours = {};
    %         region.location = [];
    %         for c = 1:length(cn)
    %             for d = 1:length(cn{c})
    %                 if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c)
    %                     region.contours{length(region.contours)+1} = cn{c}{d};
    %                     region.location = [region.location c];
    %                 end
    %             end
    %         end
    %         region.onsets=cell(1, length(region.contours));
    %         region.offsets=cell(1, length(region.contours));
    [trNew, param] = ReadTracesNew(fnm,region,numframes);
    region.tracereadername='ReadTracesNew';
    region.traces=trNew;
    
    
    %[filename2, pathname2] = uiputfile([fname(1:end-3) 'mat'], 'Save file as');
    fnm1=fullfile(matpath, [fname, '.mat']);
    save(fnm1,'region');
end
    
    

    






