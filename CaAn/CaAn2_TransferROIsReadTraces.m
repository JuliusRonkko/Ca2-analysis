clear
[filename, pathname] = uigetfile;
fnm=fullfile(pathname,filename);
load(fnm);
%regionOrig=region;

%-----------------------------------------------------------------------------
%Set up figure
%opengl neverselect;
fig = figure('Name','Original image with ROIs','NumberTitle','off','MenuBar','none','doublebuffer','on',...
    'units','normalized','closerequestfcn','CaAnfigclose','position',[0 .08/3 1 2.86/3]);
%-----------------------------------------------------------------------------

islocal=0;
cl = hsv(length(region.name));    %Colors for different regions
num = 2;        %Index for different regions, we start with region 1

cn = cell(1,length(region.name));
centr = cell(1,length(region.name));
areas = cell(1,length(region.name));
handl = cell(1,length(region.name));

thres = 15*ones(1,length(region.name));
old_thres = inf*ones(1,length(region.name));
lowar = 10*ones(1,length(region.name));
highar = repmat(inf,1,length(region.name));
pilim = 4*ones(1,length(region.name));
isadjust = zeros(1,length(region.name));
isdetected = zeros(1,length(region.name));
ishid = 1;

%-----------------------------------------------------------------------------
%Add uicontrols to figure
if islocal == 0
    
    % Brightness contrast controls------------------------------------
    brtxt1 = uicontrol('Style','text','units','normalized','string','Brightness','position',[.87 .88 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
    bbright = uicontrol('Style','slider','Units','normalized','Position',[.87 .86 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
        'Enable','on','Callback','CaAnContrast');
    brtxt2 = uicontrol('Style','text','units','normalized','string','Contrast','position',[.87 .83 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
    bcontrast = uicontrol('Style','slider','Units','normalized','Position',[.87 .81 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
        'Enable','on','Callback','CaAnContrast');
    
    % Resolution input controls------------------------------------
    res_title = uicontrol('Style','text','Units','normalized','String','Resolution','Position',[.87 .755 .11 0.03],'FontSize',11,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
    txlabsr = uicontrol('Style','text','Units','normalized','String','Spatial (µm/pixel)','Position',[.87 .715 .11 0.02],'FontSize',9,...
        'BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
    inptsr = uicontrol('Style','edit','Units','normalized','String',region.spaceres,'Position',[.87 .715-0.0275 .11 0.025],'FontSize',9,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left','enable','on');
    txlabtr = uicontrol('Style','text','Units','normalized','String','Temporal (sec/frame)','Position',[.87 .715-0.0275-0.025 .11 0.02],'FontSize',9,...
        'BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
    inpttr = uicontrol('Style','edit','Units','normalized','String',region.timeres,'Position',[.87 .715-2*0.0275-0.025 .11 0.025],'FontSize',9,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left','enable','on');
    
    
    cmnd = ['thres(num) = str2num(get(txthres,''string'')); lowar(num) = str2num(get(txarlow,''string'')); highar(num) = str2num(get(txarhigh,''string'')); pilim(num) = str2num(get(txpilim,''string''));'];
    
          
    %This button will clear your current contours.
    btclear = uicontrol('Style','pushbutton','Units','normalized','String','Clear all','Position',[.87 .59 .1 0.03],'FontSize',9,...
        'Callback','cn{num} = []; CaAnDrawCells;');
    %This button will import contour data from an existing .mat file.
    btimport = uicontrol('Style','pushbutton','Units','normalized','String','Import Contours','Position',[.87 .55 .1 0.03],'FontSize',9,...
        'Callback','cn{num} = []; CaAnDrawCells; [tfilename, tpathname] = uigetfile; tfnm=fullfile(tpathname,tfilename); tmp = load(tfnm); region.contours=tmp.region.contours; region.name=tmp.region.name; region.coords=tmp.region.coords; cn = cell(1,length(region.name)); centr = cell(1,length(region.name)); areas = cell(1,length(region.name)); handl = cell(1,length(region.name)); CaAncontourarraysetup; CaAnDrawCells;');
    
    %This button will register the contours over the cells. User clicks left-mouse button on desired location then clicks on original location. Will automatically redraw and assign contours to the newly specified location.
    btalign = uicontrol('Style','pushbutton','Units','normalized','String','Align All','Position',[.87 .51 .1 0.03],'FontSize',9,...
        'Callback','[x,y] = my_ginput(2); dx = x(1) - x(2); dy = y(1) - y(2); for c = 1:length(cn{num}); cn{num}{c}(:,1) = cn{num}{c}(:,1) - dx; cn{num}{c}(:,2) = cn{num}{c}(:,2) - dy; end; CaAnDrawCells;');
    
    btalign2 = uicontrol('Style','pushbutton','Units','normalized','String','Align Single','Position',[.87 .47 .1 0.03],'FontSize',9,...
        'Callback','[x,y] = my_ginput(2); matr = []; for c = 1:length(cn); for d = 1:length(cn{c}); if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c); matr = [matr; [CaAnCentroid(cn{c}{d}) c d]]; end; end; end; dst = sum((matr(:,1:2)-repmat([x(1) y(1)],size(matr,1),1)).^2,2); [dummy i] = min(dst); dx = x(1) - x(2); dy = y(1) - y(2); cn{num}{i}(:,1)=cn{num}{i}(:,1)- dx;  cn{num}{i}(:,2)=cn{num}{i}(:,2)- dy; region.contours{i}(:,1) = region.contours{i}(:,1) - dx; region.contours{i}(:,2) = region.contours{i}(:,2) - dy; CaAnDrawCells;');
    
    bthide = uicontrol('Style','pushbutton','Units','normalized','String','Hide','Position',[.93 .355 .05 0.03],'FontSize',9,...
        'Callback','ishid=1-ishid; CaAnHide');
    
    %btprev = uicontrol('Style','pushbutton','Units','normalized','String','<< Prev','Position',[.87 .205 .05 0.03],'FontSize',9,...
    %    'Callback',[cmnd 'ishid=1; CaAnHide; num=mod(num+length(region.name)-2,length(region.name))+1; CaAnInputParams;']);
    %btnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .205 .05 0.03],'FontSize',9,...
    %    'Callback',[cmnd 'ishid=1; CaAnHide; num=mod(num,length(region.name))+1; CaAnInputParams;']);
    txadd = uicontrol('Style','text','Units','normalized','String','Manual add shape','Position',[.87 .300 .11 0.02],'FontSize',9,...
        'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
    shaperad(1) = uicontrol('Style','radiobutton','Units','normalized','String','Circle','Position',[.87 .270 .05 0.025],'FontSize',9,...
        'BackgroundColor',[.8 .8 .8],'Value',1,'Callback','set(shaperad(1),''value'',1); set(shaperad(2),''value'',0);');
    shaperad(2) = uicontrol('Style','radiobutton','Units','normalized','String','Custom','Position',[.925 .270 .055 0.025],'FontSize',9,...
        'BackgroundColor',[.8 .8 .8],'Value',0,'Callback','set(shaperad(1),''value'',0); set(shaperad(2),''value'',1);');
    btadd = uicontrol('Style','pushbutton','Units','normalized','String','Add','Position',[.87 .230 .05 0.03],'FontSize',9,...
        'Callback','CaAnManualAdd');
    btdelete = uicontrol('Style','pushbutton','Units','normalized','String','Delete','Position',[.93 .230 .05 0.03],'FontSize',9,...
        'Callback','size(cn); CaAnManualDelete','enable','on');

    %btnextscr = uicontrol('Style','pushbutton','Units','normalized','String','next >>','Position',[.93 .02 .05 0.03],'FontSize',9,...
    %    'Callback','CaAnOpenImageLater','enable','on');
    
    btDestIm = uicontrol('Style','pushbutton','Units','normalized','String','Transfer ROIs to another image','Position',[.87 .150 .11 0.03],'FontSize',9,...
        'Callback','CaAnOpenImageLater','enable','on');
    
    btReadTr = uicontrol('Style','pushbutton','Units','normalized','String','Read traces','Position',[.87 .09 .11 0.03],'FontSize',9,...
        'Callback','CaAnReadTracesLater','enable','on');
    btnextscr=btReadTr;
    islocal = 1;
end



%-----------------------------------------------------------------------------
%Plot the averaged source image
imgax = subplot('position',[0.02 0.02 0.82 0.96]);
imagesc(region.image);
hold on
colormap(gray);
axis equal
for num=1:length(region.name)
    CaAncontourarraysetup;
    CaAnDrawCells;
end
%-----------------------------------------------------------------------------

zoom on