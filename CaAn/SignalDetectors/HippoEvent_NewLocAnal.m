function [s, d, energ] = HippoEvent_NewLocAnal(region,nn,period,sss,ddd)

i=nn;
y=region.traces(i,:);
y=dfoverf(y)*100;
yOr=y;
% figure
% plot(x,y)
% y=y-myfilter(y,200);
y=myfilter(y,5);%S-myfilter(y,50);
x=1:length(y);
% xx=x(1):diff(x)/4:x(end);
% pp = spline(x,y,xx);
% hold on 
% plot(xx,pp,'r-')
% figure
% plot(diff(y))

pt=5;
newY=[];
for i=1:length(x)-pt
    newY=[newY sum(y(i:i+pt)-y(i))];
end
% hold on
% plot( newY/1-50,'r-')

[spkVet, tempPrec, minSpk]= spk_extract(newY,1:length(newY),0, 2, -inf);
calcEvOn=[];
calcEvOff=[];
calcEvSize=[];
for i=spkVet'
    coni=i;
    while (coni+1<length(newY)) & (newY(coni)<0 | (newY(coni)>0 & newY(coni+1)-newY(coni)>0) ) 
        coni=coni+1;
    end
    if sum(y(i:coni)-y(i))<-(coni-i)*5/5 %& sum(y(coni:coni+10)-y(coni))>5*(coni+10-coni)/2 %& (mean(y(i:coni+5)))-mean([y(i) y(coni) y(coni+5)])<-0.2 %-sum(y(i:coni+5)-y(i))>2*( coni+5-i)
        calcEvOn=[calcEvOn i];
        calcEvOff=[calcEvOff coni];
        calcEvSize=[calcEvSize sum(y(i:coni)-y(i))]; 
    end
end

s=[];
d=[];
energ=[];
pt=5;
newY=[];
for i=1:length(x)-pt
    newY=[newY sum(yOr(i:i+pt)-yOr(i))];
end
cooi=0;
for i=calcEvOn
    cooi=cooi+1;
    [vm,pm]=min(newY(i:calcEvOff(cooi)));
    coni=i;
    while (coni+1<length(newY)) & (newY(coni)<0 | (newY(coni)>0 & newY(coni+1)-newY(coni)>0) ) 
        coni=coni+1;
    end
%     sum(yOr(i:coni)-yOr(i))
%     if sum(yOr(i:coni)-yOr(i))<-(coni-i)*5/2 %& sum(y(coni:coni+10)-y(coni))>5*(coni+10-coni)/2 %& (mean(y(i:coni+5)))-mean([y(i) y(coni) y(coni+5)])<-0.2 %-sum(y(i:coni+5)-y(i))>2*( coni+5-i)
        if i+pm-1<coni
        s=[s i+pm-1];
        d=[d coni];
        energ=[energ sum(yOr(i:coni)-yOr(i))]; 
        end
%     end
end
% plot(calcEvOn(1,:),newY(calcEvOn(1,:))/10-50,'r*')
% plot(calcEvOn,y(calcEvOn),'ro')
% plot(calcEvOff,y(calcEvOff),'go')

% s=calcEvOn;
% d=calcEvOff;
% energ=calcEvSize;




