fig=figure('units','normalized','outerposition',[0 0 1 1], 'closerequestfcn', 'clearvars fig bbright bcontrast bzoom handl ionotext kcltext resttext; delete(gcf)'); %

bzoom = uicontrol('Style','pushbutton','Units','normalized','String','Zoom','Position',[.75 .91 .05 .03],'FontSize',9, ...
    'Callback','zoom on','Enable','on');
uicontrol('Style','text','units','normalized','string','Brightness','position',[.75 .88 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bbright = uicontrol('Style','slider','Units','normalized','Position',[.75 .86 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','on','Callback','CaAnContrast');
uicontrol('Style','text','units','normalized','string','Contrast','position',[.75 .83 .11 .02],'FontSize',9,'BackgroundColor',[.8 .8 .8]);
bcontrast = uicontrol('Style','slider','Units','normalized','Position',[.75 .81 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','on','Callback','CaAnContrast');

imgax = subplot('position',[0.02 0.02 0.82 0.96]);
imagesc(region.image);

set(gca,'xtick',[],'ytick',[]);
axis equal
axis tight
box on

colormap gray

zoom on;

flag=exist ('cl');
if flag~=1
    cl = hsv(length(region.name));
end

for num=1:length(region.name)
    
    cn{num} = region.contours(region.location==num);
    handl{num} = [];
    hold on
    for c = 1:length(cn{num})
        h = plot(cn{num}{c}([1:end 1],1),cn{num}{c}([1:end 1],2),'color',cl(num,:),'LineWidth',1);
        handl{num} = [handl{num} h];
    end
    
end

clearvars cn c h num imgax cl flag



   
    

