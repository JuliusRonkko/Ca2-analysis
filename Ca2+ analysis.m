path='C:\'; %path to the file for analysis (mat file)
pathfilt='C:\filtered';
pathunfilt='C:\Unfiltered';
file='your file 1.mat'; % the file name

plotyesorno=1; %plot the graphs?

bs2=200;
bs1=bs2-100;
peak1=bs2+1;
peak2=peak1+120; %bs1,2 - baseline start and finish, peak1,2 - peak start and finish

%data import
%traces=load(file);
%traces=transpose(traces);
load(fullfile(path,file), 'region');
traces=region.traces; %raw traces of cells in the field of view


% average trace plot
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(mean(traces), '.-');
    title('average trace')
    xlabel('frames, 1s/frame')
    ylabel('intensity (a.u.)')
    
    
    clearvars roi
end
% dF/F traces
base=traces(:, bs1:bs2); %interval where the baseline is taken, 30 seconds
temp1=base<prctile(base,20,2); %logical array true when base is below the perc 20
for i=1:size(base,1)
    temp2=temp1(i,:); % one line of temp1, corresponding to the cell i
    basei=base(i,:); %  one line of base, corresponding to the cell i
    %base_20{i,:}=basei(temp2); % needed for std thresholding
    dF_F(i,:)=(traces(i,:)-mean(basei(temp2)))./abs(mean(basei(temp2)));
end

maxi=max(max(dF_F))+0.2;
mini=min(min(dF_F))-0.2;
clearvars temp1 temp2 basei i

% random trace plot dF_F
if plotyesorno
    for roi=randi(size(dF_F,1))
        figure ('Position', [100,400,1400,600])
        plot(dF_F(roi,:), '.-');
        ylim([mini maxi])
        title(['ROI ', num2str(roi)])
        xlabel('frames, 1s/frame')
        ylabel('intensity (a.u.)')
    end
    
    clearvars roi
end
% plot all dF_F traces
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(dF_F')
    ylim([mini maxi])
    title('all cells')
    xlabel('frames, 1s/frame')
    ylabel('normalized intensity)')
    %legend()
end
% Find peak amplitude (AMP) of the ATP response
t=0; % set the threshold for the peak amplitude

peakrange = peak1:peak2; %120 seconds

%stdev=cellfun(@std,base_20); %std method to threshold
peak=dF_F(:,peakrange); %interval where the peak occures
AMP=max(peak,[],2); % maximum amplitude of the responce in the interval
dF_F_resp=dF_F(find(AMP>t),:); % selection of the dF_F traces with AMP>0.2
dF_F_filt=dF_F_resp(:,peakrange); % selection of the dF_F traces with AMP>0.2

clearvars peak

% plot peaks of responsive cells
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(peak(find(AMP>t),:)');
    ylim([mini maxi])
    title(['responding cells peaks, threshold=', num2str(t)])
    xlabel('frames, 1s/frame')
    ylabel('normalized intensity')
end
% plot peaks of non-responsive cells
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(peak(find(AMP<=t),:)');
    %ylim([mini maxi])
    title(['non-responding cells peaks, threshold=', num2str(t)])
    xlabel('frames, 1s/frame')
    ylabel('normalized intensity')
end
% plot dF_F traces of responsive cells
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(dF_F_resp');
    ylim([mini maxi])
    title(['responding cells peaks, threshold=', num2str(t)])
    xlabel('frames, 1s/frame')
    ylabel('normalized intensity')
end
% plot dF_F traces of non-responsive cells
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(dF_F(find(AMP<=t),:)', '-'); %plot trace with AMP in the interval
    %ylim([mini maxi])
    title(['non-responding cells peaks, threshold=', num2str(t)])
    xlabel('frames, 1s/frame')
    ylabel('normalized intensity')
    
end
% histogram plotting
if plotyesorno
    figure
    histogram (AMP,35)
end
% save tab-delimited file and the mat file
tabfile=[file(1:end-3), 'txt'];
%matfile=[file(1:end-4), '_analysis'];
writetable(array2table(dF_F_filt'), fullfile(pathfilt, tabfile),'Delimiter','\t', 'WriteVariableNames',false);
save(fullfile(pathfilt, file))

tabfile=[file(1:end-3), 'txt'];
%matfile=[file(1:end-4), '_analysis'];
writetable(array2table(dF_F_resp'), fullfile(pathunfilt, tabfile),'Delimiter','\t', 'WriteVariableNames',false);
save(fullfile(pathunfilt, file))

size(dF_F,1)% # of all cells
size(dF_F_resp,1)% # of responding cells
%size(dF_F,1)-size(dF_F_resp,1)



% average trace plot
if plotyesorno
    figure ('Position', [100,400,1400,600])
    plot(mean(dF_F_resp), '.-');
    title('average trace')
    xlabel('frames, 1s/frame')
    ylabel('intensity (a.u.)')
    
    
    clearvars roi
end
