st = get(dpdetectors,'value');
button = questdlg({'More strict detection?','More strict detection? '},'strict detection','yes','no','no');
prg = zeros(1,size(tr,1)+1);
tfigg = figure('Name','spike detection','NumberTitle','off','doublebuffer','on','units','normalized','position',[0.3    0.5    0.4    0.025]);
subplot('position',[0 0 1 1]);
set(gca,'xtick',[],'ytick',[]);
for c = 1:size(tr,1);
    c
    size(tr,1)
    prg(c) = 1;
    figure(tfigg);
    imagesc(prg);
    set(gca,'xtick',[],'ytick',[]);
    drawnow
    [s d] = feval(mt(st).name(1:end-2),region,c,button);
    
    %     [s d] = hippodettrial(tr(c,:));
    %     set(progtx,''String'',[''Detecting '' num2str(c) '' of '' num2str(size(nt,1))]);
    ons{c} = s;
    offs{c} = d;
    
end;
close (tfigg)


region.onsets = ons;
region.offsets = offs;
region.detectorname = mt(st).name(1:end-2);
region.detectorparam = param;

set(bnext,'enable','on');

CaAnPlotTrace;