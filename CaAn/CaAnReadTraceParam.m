region.cutoff = thres;
region.lowarea = lowar;
region.higharea = highar;
region.isdetected = isdetected;
region.pilimit = pilim;
region.isadjusted = isadjust;
region.contours = {};
region.location = [];
for c = 1:length(cn)
    for d = 1:length(cn{c})
        if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c)
            region.contours{length(region.contours)+1} = cn{c}{d};
            region.location = [region.location c];
        end
    end
end

delete(bord_title)
delete(regax)
delete(det_tx1)
delete(dpfilters)
delete(det_loc)
delete(det_view)
delete(dummyp)
delete(txlab)
delete(txthres)
delete(txarlow)
delete(txarhigh)
delete(btdetect)
delete(bthide)
delete(txpilim)
delete(btfindbad)
delete(btadjust)
delete(btprev)
delete(btnext)
delete(shaperad)
delete(btadd)
delete(btdelete)
delete(btnextscr)

% halo_hands = [];
% halos = [];
% region.halomode = 0;
% region.haloarea = 1;

trace_title = uicontrol('Style','text','Units','normalized','String','Traces','Position',[.87 .755 .11 0.03],'FontSize',12, ...
    'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);

%halo_check = uicontrol('Style','checkbox','Units','normalized','String','Use halos','Position',[.87 .715 .11 0.025],'FontSize',9,...
%    'BackgroundColor',[.8 .8 .8],'Callback','CaAnHaloCheck');
% dummy(1) = uicontrol('Style','text','Units','normalized','String','Halo area','Position',[.87 0.6875 .11 0.02],'FontSize',9,...
%     'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
% inpthaloar = uicontrol('Style','edit','Units','normalized','String',num2str(region.haloarea),'Position',[.87 0.6625 .11 0.025],'FontSize',9,...
%     'BackgroundColor',[1 1 1],'HorizontalAlignment','left','enable','off');
% btupdate = uicontrol('Style','pushbutton','Units','normalized','String','Update','Position',[.93 .6175 .05 0.03],'FontSize',9,...
%     'Callback','CaAnHaloUpdate','enable','off');

currdir = pwd;
cd(fullfile(path,'tracereaders'));
mt = dir('*.m');
cd(currdir);

st = cell(1,length(mt));
for c = 1:length(mt)
    st{c} = mt(c).name(1:end-2);
    if strcmp(upper(st{c}(1:min([8 length(st{c})]))),'HIPPOTR_')
        st{c} = st{c}(9:end);
    end
end

dummy(2) = uicontrol('Style','text','Units','normalized','String','Trace reader','Position',[.87 0.725 .11 0.02],'FontSize',9,...
    'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
dpreaders = uicontrol('Style','popupmenu','Units','normalized','String',st,'Position',[.87 .7 .11 0.025],'FontSize',9,...
    'BackgroundColor',[1 1 1]);

bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position', [.87 .05 .11 .05],'FontSize',9,'Callback','CaAnReadTraces');