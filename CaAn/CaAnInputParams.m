if strcmp(get(det_view,'enable'),'off')
    for c = 1:length(handl)
        delete(handl{c});
    end
    cn = cell(1,length(region.name));
    centr = cell(1,length(region.name));
    areas = cell(1,length(region.name));
    handl = cell(1,length(region.name));
    set(det_view,'enable','on');
    
    thres = 15*ones(1,length(region.name));
    old_thres = inf*ones(1,length(region.name));
    lowar = 10*ones(1,length(region.name));
    highar = repmat(inf,1,length(region.name));
    pilim = 4*ones(1,length(region.name));
    isadjust = zeros(1,length(region.name));
    isdetected = zeros(1,length(region.name));
    ishid = 1;
    
    if islocal == 0
        txlab = uicontrol('Style','text','Units','normalized','String',region.name{num},'Position',[.87 .49 .11 0.025],'FontSize',10,'FontWeight','Bold',...
            'BackgroundColor',cl(num,:));
        dummyp(1) = uicontrol('Style','text','Units','normalized','String','Cutoff','Position',[.87 .4625 .11 0.02],'FontSize',9,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        txthres = uicontrol('Style','edit','Units','normalized','String',num2str(thres(num)),'Position',[.93 .46 .05 0.025],'FontSize',9,...
            'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        dummyp(2) = uicontrol('Style','text','Units','normalized','String','Min area','Position',[.87 .4325 .11 0.02],'FontSize',9,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        txarlow = uicontrol('Style','edit','Units','normalized','String',num2str(lowar(num)),'Position',[.93 .43 .05 0.025],'FontSize',9,...
            'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        dummyp(3) = uicontrol('Style','text','Units','normalized','String','Max area','Position',[.87 .4025 .11 0.02],'FontSize',9,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        txarhigh = uicontrol('Style','edit','Units','normalized','String',num2str(highar(num)),'Position',[.93 .40 .05 0.025],'FontSize',9,...
            'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        
        cmnd = ['thres(num) = str2num(get(txthres,''string'')); lowar(num) = str2num(get(txarlow,''string'')); highar(num) = str2num(get(txarhigh,''string'')); pilim(num) = str2num(get(txpilim,''string''));'];
        btdetect = uicontrol('Style','pushbutton','Units','normalized','String','Detect!','Position',[.87 .355 .05 0.03],'FontSize',9,...
            'Callback',[cmnd 'CaAnFindCells']);
        bthide = uicontrol('Style','pushbutton','Units','normalized','String','Hide','Position',[.93 .355 .05 0.03],'FontSize',9,...
            'Callback','ishid=1-ishid; CaAnHide');
        
        dummyp(4) = uicontrol('Style','text','Units','normalized','String','Pi limit','Position',[.87 .3075 .11 0.02],'FontSize',9,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        txpilim = uicontrol('Style','edit','Units','normalized','String',num2str(pilim(num)),'Position',[.93 .305 .05 0.025],'FontSize',9,...
            'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        btfindbad = uicontrol('Style','pushbutton','Units','normalized','String','Find','Position',[.87 .26 .05 0.03],'FontSize',9,...
            'Callback','CaAnFindBad');
        btadjust = uicontrol('Style','pushbutton','Units','normalized','String','Adjust','Position',[.93 .26 .05 0.03],'FontSize',9,...
            'Callback','CaAnAdjust');
        
        btprev = uicontrol('Style','pushbutton','Units','normalized','String','<< Prev','Position',[.87 .205 .05 0.03],'FontSize',9,...
            'Callback',[cmnd 'ishid=1; CaAnHide; num=mod(num+length(region.name)-2,length(region.name))+1; CaAnInputParams;']);
        btnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .205 .05 0.03],'FontSize',9,...
            'Callback',[cmnd 'ishid=1; CaAnHide; thres(num) = str2num(get(txthres,''string'')); num=mod(num,length(region.name))+1; CaAnInputParams;']);
        
        dummyp(5) = uicontrol('Style','text','Units','normalized','String','Manual add shape','Position',[.87 .1725 .11 0.02],'FontSize',9,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        shaperad(1) = uicontrol('Style','radiobutton','Units','normalized','String','Circle','Position',[.87 .145 .05 0.025],'FontSize',9,...
            'BackgroundColor',[.8 .8 .8],'Value',1,'Callback','set(shaperad(1),''value'',1); set(shaperad(2),''value'',0);');
        shaperad(2) = uicontrol('Style','radiobutton','Units','normalized','String','Custom','Position',[.925 .145 .055 0.025],'FontSize',9,...
            'BackgroundColor',[.8 .8 .8],'Value',0,'Callback','set(shaperad(1),''value'',0); set(shaperad(2),''value'',1);'); 
        btadd = uicontrol('Style','pushbutton','Units','normalized','String','Add','Position',[.87 .11 .05 0.03],'FontSize',9,...
            'Callback','CaAnManualAdd; zoom on');        
        btdelete = uicontrol('Style','pushbutton','Units','normalized','String','Delete','Position',[.93 .11 .05 0.03],'FontSize',9,...
            'Callback','CaAnManualDelete; zoom on','enable','off');
        
        btnextscr = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.87 .05 .11 .05],'FontSize',9,...
            'Callback','CaAnReadTraceParam','enable','off');
        islocal = 1;
    end    
end

set(txlab,'String',region.name{num},'BackgroundColor',cl(num,:));
set(txthres,'String',num2str(thres(num)));
set(txarlow,'String',num2str(lowar(num)));
set(txarhigh,'String',num2str(highar(num)));
set(txpilim,'String',num2str(pilim(num)));

zoom on