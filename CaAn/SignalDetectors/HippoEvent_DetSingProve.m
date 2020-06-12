function [s, d] = HippoEvent_DetSingProve(region,nn,period,sss,ddd)



s=[];
d=[];
[ss dd] = hippodettrial(region.traces(nn,:));
region.offsets{nn}=ddd;
region.onsets{nn}=sss;

addedSign=1000;
lowFr=0.002;
freqSampl=1;
[b,a] = butter(2,2*lowFr/freqSampl,'low');
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
% sign2an = sign2an-myfilter(sign2an,150);
% sign2an=myfilter(sign2an,20);

x1=dfoverf(sign2an)*100;
x=myfilter(x1,15)-myfilter(x1,300);
x=smoothNeighbour(x,10);
sign2an=x;
%         trDif=region.traces(nn,:)-sign2an(addedSign+1:end-addedSign);
trDifAll=sign2an(addedSign+1:end-addedSign);

% x1=dfoverf(region.traces(nn,:))*100;
% x=myfilter(x1,2)-myfilter(x1,300);
% trDifAll=x;

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
    stdTh=1; % soglia su derivata
else
    regSiz=size(region.traces,2);
    regNum=[1:regSiz:size(region.traces,2)];
    nstd=3;  % soglia x stimare rumore derivata
    stdTh=1; % soglia su derivata
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

%                                 figure
%                                 [ui,uio]=hist(trDif,intHist);
%                                 bar(uio,ui/(((max(trDif)-min(trDif))/numIntHist)*length(sign2fit)))
%                                 hold on
%                                 ny=normpdf(intHist,mu,sigma);
%                                 plot(intHist,ny,'r-')
%                                 figure
        
        [spkVetHelp, sh, dh, minSpk]= spkCalc_extractProvaVera(trDif,i:i+regSiz-1,3,mu,sigma,(stdTh+addstd));
        %   spkCalc_extract(trDif,i:i+regSiz-2,mu-(stdTh+addstd)*sigma, 3, -inf);
        s=[s sh];
        d=[d dh];
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

i=1;
% trac=(region.traces(num,:)-mean(region.traces(num,:)))/mean(region.traces(num,:))*100;
while i<length(s)
    if d(i)==d(i+1)
        s(i+1)=[];
        d(i+1)=[];
    else
        i=i+1;
    end
end



% s
% d
% s=[];
% d=[];
% for i=1:length(ss)
%     if isempty (find(spkVet>ss(i) & spkVet<dd(i)))==0
%         s=[s ss(i)];
%         d=[d dd(i)];
%     end
% end


% figure
% plot((trDifAll-mean(trDifAll))/max(trDifAll-mean(trDifAll))+3)
% hold on
%
% plot((region.traces(nn,:)-mean(region.traces(nn,:)))/max(region.traces(nn,:)-mean(region.traces(nn,:))));
% plot((s-1),...region.offsets{nn}
%     (region.traces(nn,s)-mean(region.traces(nn,:)))/max(region.traces(nn,:)-mean(region.traces(nn,:)))-0.5,'ro');
% plot((d-1),...
%     (region.traces(nn,d)-mean(region.traces(nn,:)))/max(region.traces(nn,:)-mean(region.traces(nn,:)))-0.5,'go');
% plot(spkVet,(region.traces(nn,spkVet)-mean(region.traces(nn,:)))/max(region.traces(nn,:)-mean(region.traces(nn,:)))-0.5,'k*')
%
% plot((sign2an(addedSign+1:end-addedSign)-mean(sign2an(addedSign+1:end-addedSign)))/...
%     max(sign2an(addedSign+1:end-addedSign)-mean(sign2an(addedSign+1:end-addedSign)))-3)


% %
% subplot(3,1,1)
% plot(trDifAll)
% hold on
% if isempty(spkVet)==0
%     plot(spkVet,mu-stdTh*sigma,'k*')
% end
% set(gca,'xlim',[5 4000])
% subplot(3,1,2)
% plot((0:size(region.traces,2)-1),100*(region.traces(nn,:)-mean(region.traces(nn,:)))/mean(region.traces(nn,:)));
% xlim([0 region.timeres*(size(region.traces,2)-1)])
% hold on
% plot((region.onsets{nn}-1),...region.offsets{nn}
%     100*(region.traces(nn,region.onsets{nn})-mean(region.traces(nn,:)))/mean(region.traces(nn,:)),'ro');
% plot((region.offsets{nn}-1),...
%     100*(region.traces(nn,region.offsets{nn})-mean(region.traces(nn,:)))/mean(region.traces(nn,:)),'go');
% plot(spkVet,100*(region.traces(nn,spkVet)-mean(region.traces(nn,:)))/mean(region.traces(nn,:))-20,'k*')
% set(gca,'xlim',[5 4000])
%
% subplot(3,1,3)
% plot(sign2an(addedSign+1:end-addedSign))
% figure
% plot((0:size(region.traces,2)-1),100*(region.traces(nn,:)-mean(region.traces(nn,:)))/mean(region.traces(nn,:)));
% xlim([0 region.timeres*(size(region.traces,2)-1)])
% hold on
% plot((s-1),...
%     100*(region.traces(nn,s)-mean(region.traces(nn,:)))/mean(region.traces(nn,:)),'ro');
% plot((d-1),...
%     100*(region.traces(nn,d)-mean(region.traces(nn,:)))/mean(region.traces(nn,:)),'go');
% plot(spkVet,100*(region.traces(nn,spkVet)-mean(region.traces(nn,:)))/mean(region.traces(nn,:))-20,'k*')
% plot(spkVet,100*(region.traces(nn,spkVet)-mean(region.traces(nn,:)))/mean(region.traces(nn,:))-25,'r*')
%
% set(gca,'xlim',[5 4000])
% % % figure
% %
% % %
