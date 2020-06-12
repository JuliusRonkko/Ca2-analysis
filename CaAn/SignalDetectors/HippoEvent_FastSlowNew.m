function [s d]=HippoEvent_FastSlowNew(region,num,gn);
tr = region.traces;
nt = [];
c = num;
nt(c,:) = dfoverf(tr(c,:))*100;

spk(num,:) = 0;
dec(num,:) = 0;
[sF dF energ] = HippoEvent_Fast(region,num,'no',region.onsets{num},region.offsets{num});

i=1;
while i<=length(sF) & dF(i)+3<=size(nt,2)
    if sum( nt(num,sF(i):dF(i)+3) -mean(nt(num,[sF(i)])) ) >-10 & energ(i)>-30
        sF(i)=[];
        dF(i)=[];
        energ(i)=[];
    else
        i=i+1;
    end
end


[sS dS] = HippoEvent_Slow(region,num,'no',region.onsets{num},region.offsets{num});
[sU dU] = hippodettrial(tr(num,:));
s=sF;
d=dF;
actFast=cell(0);
for i=1:length(sF)
    actFast{i}=(sF(i):dF(i));
end
actSlow=cell(0);
for i=1:length(sS)
    actSlow{i}=(sS(i):dS(i));
end
actUsua=cell(0);
for i=1:length(sU)
    actUsua{i}=(sU(i):dU(i));
end
% intersect fast and usual and use usual as onset
for i=1:length(sF)
    for j=1:length(sU)
        if length(intersect(actFast{i},actUsua{j}))>2
            s(i)=sU(j);
        end
    end
end
% % intersect fast and slow and use slow as offset
% for i=1:length(sF)
%     for j=1:length(sS)
%         if length(intersect(actFast{i},actSlow{j}))>2
%             d(i)=dS(j);
%         end
%     end
% end
% % intersect slow and usual and use usual as onset
% for i=1:length(sS)
%     for j=1:length(sU)
%         if length(intersect(actSlow{i},actUsua{j}))>2
%             sS(i)=sU(j);
%         end
%     end
% end
% add slow events if not detected

% intersect slow and usual and use usual as onset
for i=1:length(sS)
    for j=1:length(sU)
        if length(intersect(actSlow{i},actUsua{j}))>2
            sS(i)=sU(j);
        end
    end
end

allFast=[];
for i=1:length(sF)
    allFast=[allFast actFast{i}];
end
for j=1:length(sS)
    if isempty(intersect(actSlow{j},allFast))
        s=[s sS(j)];
        d=[d dS(j)];
    end
end
% s

actAll=cell(0);
for i=1:length(s)
    actAll{i}=(s(i):d(i));
end

ss=[];
dd=[];
if length(s)>1
    for i=1:length(s)-1
        for j=i+1:i+1
            if length(intersect(actAll{i},actAll{j}))>0
                uh=union(actAll{i},actAll{j});
                ss=[ss uh(1)];
                dd=[dd uh(end)];
            else
                ss=[ss s(i)];
                dd=[dd d(i)];
            end
        end
    end
end
% if isempty(actAll)==0
%     if isempty(intersect(actAll{i},actAll{j}))
%         ss=[ss s(j)];
%         dd=[dd d(j)];
%     end
% end
ss=sort(ss);
dd=sort(dd);
s=[];
d=[];
i=1;
while i<length(ss)
    if ss(i)==ss(i+1)
        ss(i+1)=[];
        dd(i)=min([dd(i) dd(i+1)]);
        dd(i+1)=[];
    else
        i=i+1;
    end
end
i=1;
while i<length(ss)
    if dd(i)==dd(i+1)
        dd(i+1)=[];
        ss(i)=max([ss(i) ss(i+1)]);
        ss(i+1)=[];
    else
        i=i+1;
    end
end
s=ss;
d=dd;

% i=1;
% while i<=length(s)
%     if d(i)-s(i)<2
%         s(i)=[];
%         d(i)=[];
%     else
%         i=i+1;
%     end
% end

i=1;
while i<=length(s) & d(i)+5<=size(nt,2)
    if sum( nt(num,s(i):d(i)+5) -mean(nt(num,[s(i)])) ) >-10
        s(i)=[];
        d(i)=[];
    else
        i=i+1;
    end
end

i=1;
% trac=(region.traces(num,:)-mean(region.traces(num,:)))/mean(region.traces(num,:))*100;
while i<=length(s)
    if abs(nt(num,d(i))-nt(num,s(i)))<3 | d(i)-s(i)<3
        s(i)=[];
        d(i)=[];
    else
        i=i+1;
    end
end




