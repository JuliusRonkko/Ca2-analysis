[filename2, pathname2] = uiputfile([filename(1:end-3) 'mat'], 'Save file as');
if ~isstr(filename2)
    return
end
fnm = [pathname2 filename2];

save temp.mat region fnm
set(gcf,'closerequestfcn','');
delete(gcf)
clear
load temp.mat region fnm
delete temp.mat
save(fnm,'region');
clear fnm

% load('c:\hippobackup.mat')
%delete('c:\hippobackup.mat')