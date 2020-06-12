cellnum = round(get(numslider,'Value'));
region.contours(cellnum)=[];
region.location(cellnum)=[];
region.traces(cellnum,:)=[];
region.onsets(cellnum)=[];
region.offsets(cellnum)=[];
flag=1;

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

if cellnum>length(region.contours)
    cellnum=length(region.contours);
end
    
delete(numslider)
numslider = uicontrol('Style','slider','Units','normalized','Position',[0.1 0.05 0.74 0.03],'Callback','CaAnPlotTrace',...
    'Min',1,'Max',length(region.contours),'Sliderstep',[1/length(region.contours) 10/length(region.contours)],'Value',cellnum);
CaAnPlotTrace