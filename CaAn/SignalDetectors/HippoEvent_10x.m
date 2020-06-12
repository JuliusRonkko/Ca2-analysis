function [s, d, energ] = HippoEvent_10x(region,j,intPt);



% j=663; %703 685 702
tr2a=region.traces(j,:);
tr2a=dfoverf(tr2a);
% tr2a=myfilter(tr2a,2);
% intPt=7;
for i=1:length(tr2a)+1-intPt 
    intTr(i)=sum(tr2a(i:i+intPt-1)-tr2a(i));
end
% intTr=myfilter(intTr,2);

% intTr=-intTr(end:-1:1);
% [s1,d1]=hippodettrial(tr2a);
% [s2,d2]=hippodettrial(intTr);
% s2=length(intTr)-s2;
% intTr=-intTr(end:-1:1);
% [s3,d3]=hippodettrial(diff(intTr));
% difInt=diff(intTr);
% figure
% subplot(2,2,1)
% plot(tr2a)
% hold on
% plot(s1,tr2a(s1),'ro')
% plot(s2,tr2a(s2),'go')
% title(['cell ' num2str(j) ' - points ' num2str(intPt)])

% subplot(2,2,3)
% plot(intTr)
% hold on
% plot(s2,intTr(s2),'go')
% hold on
% plot([1 length(intTr)],[-775 -775],'k-')
% [spkVetHelp, sh, dh, ener]= spk_extract(intTr,1:length(intTr),5,0,300,1);
% [spkVet, ons, offs, energ]= spkCalc_extractProva(data,time,deltaSp,mu,sigma,nStd);
[startTm,endTm,minTm, content, minSpk]=spk_extractStartEndEnerg(intTr,1:length(intTr),-0.1,5,-10);
% plot(sh,intTr(sh),'ro')
% plot(dh,intTr(dh),'go')
minSpk;
endTm;
s2d=find(content>-0.50 | intTr(minSpk)>-0.35);%
startTm(s2d)=[];
endTm(s2d)=[];
minSpk(s2d)=[];
content(s2d)=[];
'after';
s=minSpk;
d=endTm;
energ=[];

if ~isempty(find(s(2:end)-d(1:end-1)<0))
    d2f=find(s(2:end)-d(1:end-1)<0);
    d(d2f)=s(d2f)+3;
end

% s2d=find(sum(tr2a(minSpk-2:minSpk))-tr2a(minSpk)*3>-0.25);
% startTm(s2d)=[];
% endTm(s2d)=[];
% minSpk(s2d)=[];
% s=minSpk;
% d=endTm;
% energ=[];
% plot(minSpk,intTr(minSpk),'ko')

% subplot(2,2,2)
% hist(content,[-3000:50:0])
% % subplot(2,2,2)
% % % plot(diff(intTr))
% % pt2rand=100;
% % conP=1;
% % sigR=zeros(1,length(tr2a));
% % while conP<length(tr2a)
% %     if conP+pt2rand>length(tr2a)
% %         limP=length(tr2a);
% %     else
% %         limP=conP+pt2rand;
% %     end
% %     pr=randperm(limP-conP);
% %     sigR(conP:limP-1)=tr2a(conP-1+pr);
% %     conP=conP+pt2rand;
% % end
% % for i=1:length(tr2a)+1-intPt 
% %     intTrRand(i)=sum(sigR(i:i+intPt-1)-sigR(i));
% % end
% % hist(intTrRand,[-1500:10:1000])
% % title(['mean - 3 std dev ' num2str(mean(intTrRand)-3*std(intTrRand))])
% % hold on
% % plot(s3,difInt(s3),'go')
% 
% 
% subplot(2,2,4)
% hist(intTr,[-1500:10:1000])
% title(['mean - 3 std dev ' num2str(mean(intTr)-3*std(intTr))])
% 
% subplot(2,2,1)
% plot(minSpk,tr2a(minSpk),'ko')





% figure;
% plot(intTr)
% hold on
% plot(intTrRand,'r-')
