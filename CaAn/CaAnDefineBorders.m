%Read resolution data
region.image = a;
region.spaceres = str2num(get(inptsr,'string'));
region.timeres = str2num(get(inpttr,'string'));

delete(res_title);
delete(txlabsr);
delete(inptsr);
delete(txlabtr);
delete(inpttr);
delete(bnext);
set(bopenimage,'enable','off');

%Contour functions
bord_title = uicontrol('Style','text','Units','normalized','String','Regions','Position',[.87 .755 .11 0.03],'FontSize',12,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
bord_add = uicontrol('Style','pushbutton','Units','normalized','String','Add','Position',[.90 .595 .05 .03],'FontSize',9, ...
    'Enable','on','Callback','CaAnAddBorder');
bord_delete = uicontrol('Style','pushbutton','Units','normalized','String','Delete','Position',[.90 .555 .05 .03],'FontSize',9, ...
    'Enable','off','Callback','CaAnDeleteBorder');
bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.87 .05 .11 .05],'FontSize',9, ...
    'Enable','on','Callback','CaAnNameRegions');

%Initial info
bord = [];
bhand = [];

CaAnDetermineRegions