st = get(dpreaders,'value');
if isfield(region,'traces')==0 % paolo added
    

[tr, param] = feval(mt(st).name(1:end-2),fnm,region,numframes);

region.traces = tr;
%region.halotraces = trhalo;
region.tracereadername = mt(st).name(1:end-2);
region.tracereaderparam = param;
end % paolo added

delete(get(fig,'children'));
uicontrol('Style','text','units','normalized','string','Brightness','position',[.87 .95 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bbright = uicontrol('Style','slider','Units','normalized','Position',[.87 .92 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','on','Callback','CaAnContrast');
uicontrol('Style','text','units','normalized','string','Contrast','position',[.87 .87 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bcontrast = uicontrol('Style','slider','Units','normalized','Position',[.87 .85 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','on','Callback','CaAnContrast');



% halo_check = uicontrol('Style','checkbox','Units','normalized','String','Show halo traces','Position',[.87 .72 .11 0.025],'FontSize',9,...
%     'BackgroundColor',[.8 .8 .8],'Callback','CaAnPlotTrace');
% if region.halomode == 0
%     set(halo_check,'enable','off');
% end

df_check = uicontrol('Style','checkbox','Units','normalized','String','Calculate DF/F','Position',[.87 .77 .11 0.03],'FontSize',9,...
    'BackgroundColor',[.8 .8 .8],'Callback','CaAnPlotTrace');

numslider = uicontrol('Style','slider','Units','normalized','Position',[0.1 0.05 0.74 0.03],'Callback','CaAnPlotTrace',...
    'Min',1,'Max',length(region.contours),'Sliderstep',[1/length(region.contours) 10/length(region.contours)],'Value',1);

subplot('position',[0.1 0.6 0.74 0.35]);
imagesc(a);
hold on;
cl = hsv(length(region.name));
cnt = zeros(1,length(region.contours));
for c = 1:length(region.contours)
    cnt(c) = patch(region.contours{c}([1:end 1],1),region.contours{c}([1:end 1],2), [1 0 0], 'FaceAlpha',0, 'EdgeColor', [1 0 0]  );
    set(cnt(c),'edgecolor',cl(region.location(c),:));
    set(cnt(c),'ButtonDownFcn',['set(numslider,''value'',' num2str(c) '); CaAnPlotTrace;']);
end
axis equal
imagesize = size(region.image);
xlim([0 imagesize(2)])
ylim([0 imagesize(1)])
set(gca,'ydir','reverse');
box on
set(gca,'color',[0 0 0]);
set(gca,'xtick',[],'ytick',[]);

% currdir = pwd;
% cd(fullfile(path,'signaldetectors'));
% mt = dir('*.m');
% cd(currdir);
% 
% st = cell(1,length(mt));
% for c = 1:length(mt)
%     st{c} = mt(c).name(1:end-2);
%     if strcmp(upper(st{c}(1:min([8 length(st{c})]))),'HIPPOSD_')
%         st{c} = st{c}(9:end);
%     end
% end
% 
% dummy(1) = uicontrol('Style','text','Units','normalized','String','Signal detector','Position',[.87 0.8425 .11 0.02],'FontSize',9,...
%     'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
% dpdetectors = uicontrol('Style','popupmenu','Units','normalized','String',st,'Position',[.87 .8175 .11 0.025],'FontSize',9,...
%     'BackgroundColor',[1 1 1]);
% btdetect = uicontrol('Style','pushbutton','Units','normalized','String','Detect!','Position',[.93 .7725 .05 0.03],'FontSize',9,...
%     'Callback','CaAnDetectSignals');

bdel = uicontrol('Style','pushbutton','Units','normalized','String','Delete ROI','Position',[.87 .32 .11 .05],'FontSize',9, ...
    'Enable','on','Callback','CaAnDelROI');

bnext = uicontrol('Style','pushbutton','Units','normalized','String','Finish','Position',[.87 .05 .11 .05],'FontSize',9, ...
    'Enable','on','Callback','CaAnFinish');

region.onsets = cell(1,length(region.contours));
region.offsets = cell(1,length(region.contours));
th = [];
CaAnPlotTrace;