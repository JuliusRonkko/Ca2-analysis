% save('c:\hippobackup.mat')
clear;

versionnum = 1.1;
path = 'Z:\'; %add correct path to the calcium analysis algorithm

fig = figure('Name',['CaA ' num2str(versionnum)],'NumberTitle','off','MenuBar','none','doublebuffer','on',...
    'units','normalized','closerequestfcn','CaAnfigclose','position',[0 .08/3 1 2.86/3]);

%Image functions
uicontrol('Style','text','Units','normalized','String','Image','Position',[.87 .955 .11 0.03],'FontSize',12,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
bopenimage = uicontrol('Style','pushbutton','Units','normalized','String','Open','Position',[.87 .91 .05 .03],'FontSize',9, ...
    'Callback','CaAnOpenImage');
bzoom = uicontrol('Style','pushbutton','Units','normalized','String','Zoom','Position',[.93 .91 .05 .03],'FontSize',9, ...
    'Callback','zoom on','Enable','off');
uicontrol('Style','text','units','normalized','string','Brightness','position',[.87 .88 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bbright = uicontrol('Style','slider','Units','normalized','Position',[.87 .86 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','off','Callback','CaAnContrast');
uicontrol('Style','text','units','normalized','string','Contrast','position',[.87 .83 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bcontrast = uicontrol('Style','slider','Units','normalized','Position',[.87 .81 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','off','Callback','CaAnContrast');

res_title = uicontrol('Style','text','Units','normalized','String','Resolution','Position',[.87 .755 .11 0.03],'FontSize',12,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
txlabsr = uicontrol('Style','text','Units','normalized','String',['Spatial (' char(956) 'm)'],'Position',[.87 .715 .11 0.02],'FontSize',9,...
   'BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
inptsr = uicontrol('Style','edit','Units','normalized','String','1','Position',[.87 .715-0.0275 .11 0.025],'FontSize',9,...
   'BackgroundColor',[1 1 1],'HorizontalAlignment','left','enable','off');
txlabtr = uicontrol('Style','text','Units','normalized','String','Temporal (sec/frame)','Position',[.87 .715-0.0275-0.025 .11 0.02],'FontSize',9,...
   'BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
inpttr = uicontrol('Style','edit','Units','normalized','String','1.2','Position',[.87 .715-2*0.0275-0.025 .11 0.025],'FontSize',9,...
   'BackgroundColor',[1 1 1],'HorizontalAlignment','left','enable','off');

bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.87 .05 .11 .05],'FontSize',9, ...
    'Enable','off','Callback','CaAnDefineBorders');

%logoim = subplot('position',[0.25 0.3 0.4 0.4]);
%a = imread('hippo.bmp');
%imagesc(a);
%axis equal
%axis off
logoname = uicontrol('Style','text','Units','normalized','String',['CaAn ' num2str(versionnum) ' by Anastasia Ludwig (anastasia.ludwig@helsinki.fi)'],'Position',[.25 .7 .4 .05],'HorizontalAlignment','center', ...
    'FontSize',18,'FontWeight','Bold','BackgroundColor',[.8 .8 .8],'foregroundcolor',[1 0 0]);
ref = uicontrol('Style','text','Units','normalized','String','simplified version of Hippo by Dmitriy Aronov (da2006@columbia.edu)','Position',[.25 .2 .4 .05],'HorizontalAlignment','center', ...
   'FontSize',14,'FontWeight','Bold','BackgroundColor',[.8 .8 .8],'foregroundcolor',[1 0 0]);
