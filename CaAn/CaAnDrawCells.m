set(bthide,'string','Hide');
ishid = 1;
centr{num} = [];
areas{num} = [];
for c = 1:length(cn{num})
    centr{num}(c,:) = CaAnCentroid(cn{num}{c});
    areas{num}(c) = polyarea(cn{num}{c}(:,1),cn{num}{c}(:,2));
end
delete(handl{num});
handl{num} = [];
subplot('position',[0.02 0.02 0.82 0.96])
for c = 1:length(cn{num})
    h = plot(cn{num}{c}([1:end 1],1),cn{num}{c}([1:end 1],2),'color',cl(num,:),'LineWidth',1);
    handl{num} = [handl{num} h];
end
set(handl{num}(find(areas{num} < lowar(num) | areas{num} > highar(num))),'visible','off');

f = findobj('Type','line','Visible','on');
if isempty(f)
    set(btdelete,'enable','off');
    set(btnextscr,'enable','off');
else
    set(btdelete,'enable','on');
    set(btnextscr,'enable','on');
end
% zoom on