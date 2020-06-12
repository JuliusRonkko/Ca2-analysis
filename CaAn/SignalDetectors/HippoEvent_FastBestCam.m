function [s, d, energ] = HippoEvent_FastBestCam(region,nn,period,sss,ddd)



s=[];
d=[];
energ=[];
[ss dd] = hippodettrial(region.traces(nn,:));
% region.offsets{nn}=ddd;
% region.onsets{nn}=sss;
if size(region.traces,2)<999
    addedSign=size(region.traces,2);
else
    addedSign=999;
end

lowFr=0.005;
freqSampl=1;
% [b,a] = butter(2,2*lowFr/freqSampl,'high');
if size(region.traces,2)<2000
    regSiz=size(region.traces,2);
    regNum=[1:regSiz:size(region.traces,2)];
else
    regSiz=1000;
    regNum=[1:regSiz:size(region.traces,2)];
end
% nstd=3;  % soglia x stimare rumore derivata
% stdTh=5; % soglia su derivata
spkVet=[];

sign2an=[region.traces(nn,addedSign:-1:1) region.traces(nn,:) region.traces(nn,end:-1:end-addedSign+1)];
%         sign2an = filter(b,a,sign2an);
sign2an = myfilter(sign2an,2)-myfilter(sign2an,100);
%         trDif=region.traces(nn,:)-sign2an(addedSign+1:end-addedSign);
trDifAll=sign2an(addedSign+1:end-addedSign);

stdDevTm=[];
for i=regNum
    if i+regSiz-1>size(region.traces,2)
        addReg=size(region.traces,2);
    else
        addReg=i+regSiz-1;
    end
    hhu=diff(trDifAll(i:addReg),1);
    avDer=mean(hhu);
    stdDer=std(hhu);
    ok=find(hhu>avDer-(1)*stdDer & hhu<avDer+(1)*stdDer);
    stdDevTm=[stdDevTm std(hhu(ok))];
    %                     figure
    %                 [ui,uio]=hist(diff(trDifAll(i:i+regSiz-1),1),[-20:0.05:20]);
    %                 bar(uio,ui)

end

if max(stdDevTm)>min(stdDevTm)*1.5 & size(region.traces,2)>=2000
    regSiz=1000;
    regNum=[1:regSiz:size(region.traces,2)];
    nstd=3;  % soglia x stimare rumore derivata
    stdTh=5; % soglia su derivata
else
    regSiz=size(region.traces,2);
    regNum=[1:regSiz:size(region.traces,2)];
    nstd=3;  % soglia x stimare rumore derivata
    stdTh=3; % soglia su derivata
end

for i=regNum
    addstd=-1;
    periodic='yes';
    while strcmp(periodic,'yes')
        periodic=period;
        addstd=addstd+1;%
        if i+regSiz-1>size(region.traces,2)
            addReg=size(region.traces,2);
        else
            addReg=i+regSiz-1;
        end
        trDif=diff(trDifAll(i:addReg));
        %         [trDif,r] = deconv(trDif,exp(-(1:30)/0.0));
        %         size(trDif)
        %         trDif=trDif+r(1:4000);

        %         trDif=smoothNeighbour(trDif,20);
        %         trDif=diff(trDif,2);
        % fit distribution
        numIntHist=200;
        %         if round((max(trDif)-min(trDif))/numIntHist)<20
        %             intHist=[min(trDif)-10:round((max(trDif)-min(trDif))/20):max(trDif)+10];
        %         else
        intHist=[min(trDif)-1:((max(trDif)-min(trDif))/numIntHist):max(trDif)+1];
        %         end
        [hcont,hx]=hist(trDif,intHist);
        intFit=hx(find(hcont>max(hcont)/4));
        avDer=mean(trDif(find(trDif>intFit(1) & trDif<intFit(end))));
        stdDer=std(trDif(find(trDif>intFit(1) & trDif<intFit(end))));
        sign2fit=trDif(  find(trDif>avDer-(nstd)*stdDer & trDif<avDer+(nstd)*stdDer) ); % sum(matAttOnOff)/numCell;
        [mu,sigma]=normfit(sign2fit);
        % end fit

%                         figure
%                         [ui,uio]=hist(trDif,intHist);
%                         bar(uio,ui/(((max(trDif)-min(trDif))/numIntHist)*length(sign2fit)))
%                         hold on
%                         ny=normpdf(intHist,mu,sigma);
%                         plot(intHist,ny,'r-')
        %
        [spkVetHelp, sh, dh, ener]= spkCalc_extractCam(trDif,i:i+length(trDif)-1,3,mu,sigma,(stdTh+addstd));
        fg=get(gcf)
%         figure
%         subplot(2,1,1)
%         plot(trDifAll)
%         subplot(2,1,2)
%         plot(trDif)
%         hold on
%         plot([1 length(trDif)],[mu-3*sigma mu-3*sigma])
%         plot([1 length(trDif)],[mu+1*sigma mu+1*sigma])
%         figure(fg)
        
        
        %   spkCalc_extract(trDif,i:i+regSiz-2,mu-(stdTh+addstd)*sigma, 3, -inf);
        s=[s sh];
        d=[d dh];
        energ=[energ ener];
        %         [spkVetHelp2, tempPrec, minSpk]= spk_extract(-trDif,1:length(trDif),-mu-(stdTh+addstd)*sigma, 3, -inf);
        %         spkVetHelp=[spkVetHelp' spkVetHelp2'];
        %         spkVetHelp=sort(spkVetHelp);

        % periodic analysis
        [cont,x]=hist(diff(spkVetHelp),[0:5:30000]);
        warning off 
        [histSpk, tempPrec, minSpk]= spk_extract(-cont,1:length(cont),-(mean(cont(find(cont>0)))+1*std(cont(find(cont>0)))), 1, -inf);
        warning on
        %         figure
        %         bar(x,cont)
        if isempty(histSpk)
            periodic='no';
        elseif histSpk(1)>15
            periodic='no';
        end
    end
    spkVet=[spkVet spkVetHelp' ];
end
spkVet=spkVet+1;
trDifAll=diff(trDifAll);



% i=1;
% % trac=(region.traces(num,:)-mean(region.traces(num,:)))/mean(region.traces(num,:))*100;
% while i<length(s)
%     if d(i)==d(i+1)
%         s(i+1)=[];
%         d(i+1)=[];
% %         energ(i+1)=[];
%     else
%         i=i+1;
%     end
% end


% actFast=cell(0);
% for i=1:length(s)
%     actFast{i}=(s(i):d(i));
% end
% actUsua=cell(0);
% for i=1:length(ss)
%     actUsua{i}=(ss(i):dd(i));
% end

% % intersect fast and usual and use usual as onset
% for i=1:length(s)
%     for j=1:length(ss)
%         if length(intersect(actFast{i},actUsua{j}))>2
%             s(i)=ss(j);
%         end
%     end
% end

% intersect fast and usual and use usual as onset
hhh=zeros(1,length(sign2an));
for i=1:length(ss)
    hhh(ss(i):dd(i))=1;
end
for i=1:length(s)
    iii=zeros(1,length(sign2an));
    iii(s(i):d(i))=1;
    if sum(iii.*hhh)>2
        [i1,i2]=min(abs(ss-s(i)));
        s(i)=ss(i2);
    end
end

% i=1;
% % trac=(region.traces(num,:)-mean(region.traces(num,:)))/mean(region.traces(num,:))*100;
% while i<length(s)
%     if s(i)==s(i+1)
%         s(i+1)=[];
%         d(i+1)=[];
% %         energ(i+1)=[];
%     else
%         i=i+1;
%     end
% end

i=1;
% trac=(region.traces(num,:)-mean(region.traces(num,:)))/mean(region.traces(num,:))*100;
while i<length(s)
    if s(i)>=d(i)
        s(i)=[];
        d(i)=[];
%         energ(i+1)=[];
    else
        i=i+1;
    end
end

dc=[];
for i=2:length(d)
    if isempty (find(s>d(i-1) & s<d(i)))
        dc=[dc i];
    end
end
d(dc)=[];


sc=[];
for i=2:length(s)
    if isempty (find(d>s(i-1) & d<s(i)))
        sc=[sc i];
    end
end
s(dc)=[];

