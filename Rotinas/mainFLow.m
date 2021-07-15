%% 0- Imports
clear
clc
close all
format compact
cd('D:/Ivan/OneDrive/Códigos ( Profissional )/ICE/Proj_BSc_Hippocampus_Delta_Analysis');
addpath('Rotinas/Functions/');
srate=1250;
dt=1/srate;
%% Pre process
% Load target attributes and filter noise
% Track: eeg, speed_MMsec, lapID
% Laps: WhlSpeedCCW, WhlSpeedCW
% Spike: cluu, res
% Clu: isIntern
% 1 - Load and filter files

% Files source path
dbPathOne = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/dryad/Wang_et_al_eLife2016_data_part1~/';
dbPathTwo = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/dryad/Wang_et_al_eLife2016_data_part2~/';

% List of paths
filePaths = [dbPathOne; dbPathTwo];
% Number of directories
[numDir, ~ ] = size(filePaths);
% A list that store the number of files in each directory
dataLineCount = zeros(1, size(filePaths, 1));
% Load files
for i=1:numDir
    % List all files in each directory
    absolutFilePath = ls(fullfile(filePaths(i,1:end), '*.mat'));
    % Get the number of files
    [numFil, ~ ] = size(absolutFilePath);
    % Store value
    dataLineCount(i) = numFil;
    
    % Load each .mat in the structure
    for j=1:numFil
        dataFull{i,j} = load(strcat(filePaths(i,1:end),absolutFilePath(j, 1:end)), 'Track', 'Laps', 'Clu', 'Spike');
        
        trackNames = fieldnames(dataFull{i,j}.Track);
        trackNames(find(strcmp(trackNames, 'eeg'))) = [];
        trackNames(find(strcmp(trackNames, 'speed_MMsec'))) = [];
        trackNames(find(strcmp(trackNames, 'lapID'))) = [];
        lapsNames = fieldnames(dataFull{i,j}.Laps);
        lapsNames(find(strcmp(lapsNames, 'WhlSpeedCCW'))) = [];
        lapsNames(find(strcmp(lapsNames, 'WhlSpeedCW'))) = [];
        spikeNames = fieldnames(dataFull{i,j}.Spike);
        spikeNames(find(strcmp(spikeNames, 'totclu'))) = [];
        spikeNames(find(strcmp(spikeNames, 'speed_MMsec'))) = [];
        spikeNames(find(strcmp(spikeNames, 'whlSpeed'))) = [];
        spikeNames(find(strcmp(spikeNames, 'res'))) = [];
        cluNames = fieldnames(dataFull{i,j}.Clu);
        cluNames(find(strcmp(cluNames, 'isIntern'))) = [];
        
        dataFull{i,j}.Track = rmfield(dataFull{i,j}.Track,trackNames);
        dataFull{i,j}.Laps = rmfield(dataFull{i,j}.Laps,lapsNames);        
        dataFull{i,j}.Spike = rmfield(dataFull{i,j}.Spike,spikeNames);  
        dataFull{i,j}.Clu = rmfield(dataFull{i,j}.Clu,cluNames);  
        dataFull{i,j}.Name = absolutFilePath(j, 1:end);
      
        dataFull{i,j}.Track.origEeg = dataFull{i,j}.Track.eeg;
        % Filter noise
        dataFull{i,j} = filterLFP(dataFull{i,j}, srate);
        sprintf('Dir: %d, File: %d', i, j)
    end
end

clearvars -except dt srate dataFull dataLineCount
%% Pre process
% 1.1 - Save loaded files
% savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/preProcessed/';
file = char(strcat(savePath, 'preProcessed.mat'));

% save(file, '-v7.3')
%% Load pre processed file
% 1.2 - Load file

clear
clc
close all
format compact
cd('D:/Ivan/OneDrive/Códigos ( Profissional )/ICE/Proj_BSc_Hippocampus_Delta_Analysis');
addpath('Rotinas/Functions/');

savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/preProcessed/';
file = char(strcat(savePath, 'preProcessed.mat'));

load(file)
sprintf('Loaded file - Pre processed')
%% Auto Save 
% 
% fileNames= ["DeltaProcessed.mat","ThetaProcessed.mat","PwelchProcessed.mat"];
% 
% for nm=1:size(fileNames,2)
%     %Load
%     clearvars -except fileNames nm
%     
%     savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/preProcessed/';
%     file = char(strcat(savePath, 'preProcessed.mat'));
% 
%     load(file)
%     sprintf('Loaded file - Pre processed')
%     %Process
%     aux = zeros(1,3);
%     aux(nm) = 1;
%     
%     % Specifications
%     WindowLength = 1;%in sec
%     WindowLength = WindowLength*srate;
%     Overlap      = 0.9*srate;
%     NFFT         = 2^13;
% 
%     [numReads, numSubReads ] = size(dataFull);
%     for nData=1:numReads
%         for i=1:dataLineCount(nData)
%             dataFull{nData,i} = fillStruct(dt, srate, WindowLength, Overlap, NFFT, dataFull{nData,i}, aux(1), aux(2), aux(3));
%             sprintf('%d %d',nData, i)
%         end
%     end
%     %Save
%     
%     savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/';
%     file = char(strcat(savePath, fileNames(nm)));
% 
%     save(file, '-v7.3')
%     
%     
% end
%% Process file
% 2 - Filter bands and pwelch

% Specifications
WindowLength = 1;%in sec
WindowLength = WindowLength*srate;
Overlap      = 0.9*srate;
NFFT         = 2^13;

[numReads, numSubReads ] = size(dataFull);
for nData=1:numReads
    for i=1:dataLineCount(nData)
        dataFull{nData,i} = fillStruct(dt, srate, WindowLength, Overlap, NFFT, dataFull{nData,i}, 1, 0, 0);
        sprintf('%d %d',nData, i)
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads
%% Process file
% 2.1 - Save loaded files
% savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/';
file = char(strcat(savePath, 'DeltaProcessed.mat'));

% save(file, '-v7.3')
%% Load processed file
% 2.2 - Load file
tic
clear
clc
close all
format compact
cd('D:/Ivan/OneDrive/Códigos ( Profissional )/ICE/Proj_BSc_Hippocampus_Delta_Analysis');
addpath('Rotinas/Functions/');
savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/';
file = char(strcat(savePath, 'PwelchProcessed.mat'));

load(file)
sprintf('Loaded file - Processed')
toc
%% 3 - Analyse
% 3.1 - Statistics
% 3.2 - Graphs

% Save path for results
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow)/';

% 3.1.1 - Load each pwelch array and save in another array for the group
% Save results boolean, 1: YES, 0: NO
save = 0;
pMzPre = [];
pWhPre = [];
pMzPos = [];
pWhPos = [];
for nData=1:numReads
    for i=1:dataLineCount(nData)
        
        if nData == 1
            pMzPre = [pMzPre, dataFull{nData,i}.Pwelch.Px_mz];
            pWhPre = [pWhPre, dataFull{nData,i}.Pwelch.Px_wh];
        else
            pMzPos = [pMzPos, dataFull{nData,i}.Pwelch.Px_mz];
            pWhPos = [pWhPos, dataFull{nData,i}.Pwelch.Px_wh];
        end
    end
 
end

% 3.1.2 - Group t-Test and RankSum
f = dataFull{1,1}.Pwelch.F;
bands = [3,5; 6,10; 35,55; 65,110; 150,250];
filesNames = ["Group_mz_x_wh_pre_pre.txt", "Group_mz_x_wh_pos_pos.txt", "Group_mz_x_mz_n_wh_x_wh_pre_pos.txt"];
tittleLines = ["Group Maze x Wheel -> Pre x Pre - Ttest and RankSum", "Group Maze x Wheel -> Pos x Pos - Ttest and RankSum", "Group Maze x Wheel -> Pre x Pos - Ttest and RankSum" ];
for nData=1:size(filesNames, 2)
    if save
        fileID = fopen(strcat(savePath, filesNames(nData)), 'w');
        fprintf(fileID, strcat('\n', filesNames(nData), {' - '}, tittleLines(nData), '\n'));
    else
        fileID = '';
    end
    
    for i=1:size(bands, 1)
        dt = find( f> bands(i,1) & f <bands(i,2));
        if nData ==3
            % Pre x Pos Mz
            [perc, power, peak] = printStats(pMzPre, pMzPos, dt, bands, i, f,'Pre x Pos Mz');
            pppSave(perc, power, peak, save, fileID);
            
            % Pre x Pos wh
            [perc, power, peak] = printStats(pWhPre, pWhPos, dt, bands, i, f,'Pre x Pos wh');
            pppSave(perc, power, peak, save, fileID);
            
            % Pre Mz x Pos wh
            [perc, power, peak] = printStats(pMzPre, pWhPos, dt, bands, i, f, 'Pre Mz x Pos Wh');
            pppSave(perc, power, peak, save, fileID);
        else
            pMzTemp = {pMzPre, pMzPos};
            pWhTemp = {pWhPre, pWhPos};
            ex = {'Pre Mz x Pre Wh', 'Pos Mz x Pos Wh'};
            [perc, power, peak] = printStats(pMzTemp{nData}, pWhTemp{nData}, dt, bands, i, f, ex{nData});
            pppSave(perc, power, peak, save, fileID);
        end
    end
    if save
        fclose(fileID);
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2 - Graphs
% 3.2.1 - Individual LFP
save = 0;
for nData=1:numReads
    for i=1:dataLineCount(nData)
        if nData == 1
            ttl = strcat('LFP - Pre Muscimol', {' '}, dataFull{nData,i}.Name(1:16));
            fgSpace = 0;
        else
            ttl = strcat('LFP - Pos Muscimol', {' '}, dataFull{nData,i}.Name(1:16));
            fgSpace = numSubReads;
        end
        fig = figure(fgSpace+i);
        plot(dataFull{nData,i}.Track.origEeg, 'k')
        xlabel('Time')
        ylabel('Power')
        hold on
        plot(dataFull{nData,i}.Track.eeg, 'r')
        title(ttl)
        xlabel('Time')
        ylabel('Power')
%         ylim([-25000, 25000])
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        if save
            fileName = char(strcat(savePath, 'Indiv_', strrep(ttl,' ','_')));
            saveas(fig,fileName, 'epsc');
            saveas(fig,fileName, 'png');
        end
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.2 - Group Point plot
% clf
save = 0;
pMzPre = [];
pWhPre = [];
pMzPos = [];
pWhPos = [];
for nData=1:numReads
    for i=1:dataLineCount(nData)
        
        if nData == 1
            pMzPre = [pMzPre, dataFull{nData,i}.Pwelch.Px_mz];
            pWhPre = [pWhPre, dataFull{nData,i}.Pwelch.Px_wh];
        else
            pMzPos = [pMzPos, dataFull{nData,i}.Pwelch.Px_mz];
            pWhPos = [pWhPos, dataFull{nData,i}.Pwelch.Px_wh];
        end
    end
 
end

f = dataFull{1,1}.Pwelch.F;
bands = [3,5; 6,10; 35,55; 65,110; 150,250];
tittleLines = ['Pre Mz x Pre Wh'; 'Pos Mz x Pos Wh'; 'Pre Mz x Pos Mz'; 'Pre Wh x Pos Wh'; 'Pre Mz x Pos Wh'];
for nData=1:3
    for i=1:size(bands, 1)
        dt = find( f> bands(i,1) & f <bands(i,2));
        fig = figure(i);
        fig.Position = [1 1 1900 1000];
        if nData ==3
            
            % Pre x Pos Mz
            ttl = strcat('Group Peak',{' - '},tittleLines(3, :), sprintf(' || Bands: %i - %i Hz', bands(i,1),bands(i,2)));
            plotStatsGroup(pWhPos,pMzPos,dt, 3, ttl, 'Maze Pre', 'Maze Pos', f, bands(i,1),bands(i,2))
            
            % Pre x Pos wh
            ttl = strcat('Group Peak',{' - '},tittleLines(4, :), sprintf(' || Bands: %i - %i Hz', bands(i,1),bands(i,2)));
            plotStatsGroup(pWhPre,pWhPos,dt, 4, ttl, 'Wheel Pre', 'Wheel Pos', f, bands(i,1),bands(i,2))
           
            % Pre Mz x Pos wh
            ttl = strcat('Group Peak',{' - '},tittleLines(5, :), sprintf(' || Bands: %i - %i Hz', bands(i,1),bands(i,2)));
            plotStatsGroup(pMzPre,pWhPos,dt, 5, ttl, 'Maze Pre', 'Wheel Pos', f, bands(i,1),bands(i,2))
        else
            pMzTemp = {pMzPre, pMzPos};
            pWhTemp = {pWhPre, pWhPos};
            ttl = strcat('Group Peak',{' - '}, tittleLines(nData, :), sprintf(' || Bands: %i - %i Hz', bands(i,1),bands(i,2)));
            plotStatsGroup(pMzTemp{nData},pWhTemp{nData},dt, nData, ttl, 'Maze', 'Wheel', f, bands(i,1),bands(i,2))
            
            [maxLeft, idxMz] = max(pMzTemp{nData}(dt, :));
            [maxRight, idxWh] = max(pWhTemp{nData}(dt, :));

            peakLeft = f(dt(idxMz));
            peakRight = f(dt(idxWh));

            left = maxLeft;
            right = maxRight;
            % Error
            errL = std(left)/sqrt(size(left,1));
            errR = std(right)/sqrt(size(right,1));
                       
        end
        if save
            fileName = char(strcat(savePath, 'Group_PEAK_', sprintf('%i_%i_Hz', bands(i,1),bands(i,2))));
            saveas(fig,fileName, 'epsc');
            saveas(fig,fileName, 'png');
        end
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.2b - Individual point plot

% clf
save = 1;
f = dataFull{1,1}.Pwelch.F;
bands = [3,5; 6,10];
tittleLines = ['Pre Mz x Pre Wh'; 'Pos Mz x Pos Wh'; 'Pre Mz x Pos Mz'; 'Pre Wh x Pos Wh'; 'Pre Mz x Pos Wh'];
dodge = [0:2:(size(tittleLines, 1)*2)];
% Pre x Pos
for nData=1:size(tittleLines, 1)
    % Bands   
    for i=1:size(bands, 1)
        % Animals
        dt = find( f> bands(i,1) & f <bands(i,2));
        fig = figure(i+dodge(nData));
        fig.Position = [1 1 1900 1000];
        for j=1:10
            if nData == 1
                leftData = dataFull{nData,j}.Pwelch.Px_mz;
                rightData = dataFull{nData,j}.Pwelch.Px_wh;
                moment = 'Pre';
                xlabel = {'Maze', 'Wheel'};
            elseif nData == 2
                leftData = dataFull{nData,j}.Pwelch.Px_mz;
                rightData = dataFull{nData,j}.Pwelch.Px_wh;
                moment = 'Pos';
                xlabel = {'Maze', 'Wheel'};
            elseif nData == 3
                leftData = dataFull{1,j}.Pwelch.Px_mz;
                rightData = dataFull{2,j}.Pwelch.Px_mz;
                moment = 'Pre x Pos';
                xlabel = {'Maze', 'Maze'};
            elseif nData == 4
                leftData = dataFull{1,j}.Pwelch.Px_wh;
                rightData = dataFull{2,j}.Pwelch.Px_wh;
                moment = 'Pre x Pos';
                xlabel = {'Wheel', 'Wheel'};
            else
                leftData = dataFull{1,j}.Pwelch.Px_mz;
                rightData = dataFull{2,j}.Pwelch.Px_wh;
                moment = 'Pre x Pos';  
                xlabel = {'Maze', 'Wheel'};  
            end

            % P-value
            [maxLeft, idxMz] = max(leftData(dt, :));
            [maxRight, idxWh] = max(rightData(dt, :));

            peakLeft = f(dt(idxMz));
            peakRight = f(dt(idxWh));

            subplot(2,5,j)
            bar([1,2], [peakLeft, peakRight], 'FaceColor', 'none')
            xlim([0.5,2.5]);
            ylim([bands(i,1), bands(i,2)]);
            xticklabels(xlabel)
            title(sprintf('%s: %i Hz - %i Hz (%s)', dataFull{1,j}.Name(1:13), bands(i, 1), bands(i,2), moment))
        end
        if save
            fileName = char(strcat(savePath, 'Indiv_PEAK_', sprintf('Combined_%i_%i_Hz_%i', bands(i,1),bands(i,2), nData)));
            saveas(fig,fileName, 'epsc');
            saveas(fig,fileName, 'png');
        end
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.3 - Individual PSD
save = 0;
for nData=1:numReads
    fig = figure(nData);
    fig.Position = [1 1 1600 1000];
    for i=1:dataLineCount(nData)
        sprintf('%d %d',nData, i)
                
        if nData == 1
            sgtitle('Welch’s power spectral density - Pre Muscimol')
            name = 'pre';
        else
            sgtitle('Welch’s power spectral density - Pos Muscimol')
            name = 'pos';
        end
        
        subplot(3,4,i);
        plot(dataFull{nData,i}.Pwelch.F,dataFull{nData,i}.Pwelch.Px_mz,'k')
        hold on
        plot(dataFull{nData,i}.Pwelch.F,dataFull{nData,i}.Pwelch.Px_wh,'r')
        xlim([0 12])
%         ylim([0 50000])
        box off
        hold off
        label1{1} = 'Maze';
        label1{2} = 'Wheel';
        legend(label1,'location','bestoutside','orientation','horizontal')
        legend('boxoff')
        ylabel('Power')
        xlabel('Frequency(Hz)')
        title(dataFull{nData,i}.Name(1:16))
        % Aesthetics
        set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear') 
    end
    if save
        fileName = char(strcat(savePath, 'Individual_', name, 'PSD_Norm'));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.4 - Group PSD
clf
save = 0;
for nData=1:numReads
    f = [];
    mz = [];
    wh = [];
    for i=1:dataLineCount(nData)
        mz = [mz, dataFull{nData,i}.Pwelch.Px_mz];
        wh = [wh, dataFull{nData,i}.Pwelch.Px_wh];
        f = [f, dataFull{nData,i}.Pwelch.F];
    end

    name = 'Pre';
    if nData == 2
       name = 'Pos';
    end
           
    % Mean
    meanMz = mean(mz, 2);
    meanWh = mean(wh, 2);
    meanF = mean(f, 2);
    % Std  
    stdMz = std(meanMz)/sqrt(dataLineCount(nData));
    stdWh = std(meanWh)/sqrt(dataLineCount(nData));
    
    fig = figure(1);
    subplot(1,2,nData);
    fig.Position = [1 1 1900 1000];
    plot(meanF, meanMz, 'k')
    hold on
    plot(meanF, meanMz+stdMz, 'k--')
    plot(meanF, meanMz-stdMz, 'k-.')
    plot(meanF, meanWh, 'r')
    plot(meanF, meanWh+stdWh, 'r--')
    plot(meanF, meanWh-stdWh, 'r-.')
    title(sprintf('PSD - Group - %s Muscimol', name))
    xlim([0,12])
    ylabel('Power')
    xlabel('Frequency(Hz)')
    ylim([-1000 , 46000])
    label1{1} = 'Maze';
    label1{2} = 'Maze + std';
    label1{3} = 'Maze - std';
    label1{4} = 'Wheel';
    label1{5} = 'Wheel + std';
    label1{6} = 'Wheel - std';
    legend(label1,'location','bestoutside','orientation','horizontal')
    % Aesthetics
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear') 
end
if save
    fileName = char(strcat(savePath, 'Group_Mz_n_Wh_both_PSD_with_std'));
    saveas(fig,fileName, 'epsc');
    saveas(fig,fileName, 'png');
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.5 - InstFreq Corr Indiv
clf
save = 1;
for nData=1:numReads
    fig = figure(nData);
    fig.Position = [1 1 1900 1000];
    for i=1:dataLineCount(nData)
        sprintf('%d %d',nData, i)
                
        if nData == 1
            sgtitle('Instantaneous frequency X Speed - Pre Muscimol')
            name = 'pre';
        else
            sgtitle('Instantaneous frequency X Speed - Pos Muscimol')
            name = 'pos';
        end
        
        SpeedWh = dataFull{nData,i}.Bands.InstSpeedWh;
        DeltaWh = dataFull{nData,i}.Bands.InstDeltaWh;
        SpeedMz = dataFull{nData,i}.Bands.InstSpeedMz;
        DeltaMz = dataFull{nData,i}.Bands.InstDeltaMz;
    
        % Used later
        ampMz = dataFull{nData,i}.Bands.AmpDeltaMz;
        ampWh = dataFull{nData,i}.Bands.AmpDeltaWh;
        ampliMzAvg = [];
        ampliWhAvg = [];
        
        %AVG calc
        DeltaWhAvg = [];
        SpeedWhAvg = [];
        DeltaMzAvg = [];
        SpeedMzAvg = [];
        
        count=1;
        t=1; %1sec

        for j=1:(t*srate):length(SpeedWh)-(t*srate)
            try
                DeltaWhAvg = [DeltaWhAvg, mean(DeltaWh(count:count+(t*srate)))];
                SpeedWhAvg = [SpeedWhAvg, mean(SpeedWh(count:count+(t*srate)))];
                ampliWhAvg = [ampliWhAvg, mean(ampWh(count:count+(t*srate)))];
                count=count+(t*srate);
            end
        end
        count=1;
        for k=1:(t*srate):length(SpeedMz)-(t*srate)
            try
                DeltaMzAvg = [DeltaMzAvg, mean(DeltaMz(count:count+(t*srate)))];
                SpeedMzAvg = [SpeedMzAvg, mean(SpeedMz(count:count+(t*srate)))];
                ampliMzAvg = [ampliMzAvg, mean(ampMz(count:count+(t*srate)))];
                count=count+(t*srate);
            end
        end    

        dataFull{nData,i}.Bands.DeltaWhAvg = DeltaWhAvg;
        dataFull{nData,i}.Bands.DeltaMzAvg = DeltaMzAvg;
        dataFull{nData,i}.Bands.SpeedWhAvg = SpeedWhAvg;
        dataFull{nData,i}.Bands.SpeedMzAvg = SpeedMzAvg;
        
        dataFull{nData,i}.Bands.AmpMzAvg = ampliMzAvg;
        dataFull{nData,i}.Bands.AmpWhAvg = ampliWhAvg;

        %Coef Calc
        [r1, p1] = corrcoef([dataFull{nData,i}.Bands.SpeedMzAvg;dataFull{nData,i}.Bands.DeltaMzAvg]');
        [r2, p2] = corrcoef([dataFull{nData,i}.Bands.SpeedWhAvg;dataFull{nData,i}.Bands.DeltaWhAvg]');
        dataFull{nData,i}.Bands.PearsonMzR = r1(2);
        dataFull{nData,i}.Bands.PearsonMzP = p1(2);
        dataFull{nData,i}.Bands.PearsonWhR = r2(2);
        dataFull{nData,i}.Bands.PearsonWhP = p2(2);
        
        %Plot
        atual = i+(i-1);
        subplot(3,8,atual);
        plot(dataFull{nData,i}.Bands.SpeedWhAvg',dataFull{nData,i}.Bands.DeltaWhAvg, '.')
        xlabel('Speed')
        ylabel('Frequency(Hz)')
        xlim([0,1000])
        title({strcat(dataFull{nData,i}.Name(1:16),sprintf('\nWh R: %f P: %f', r2(2), p2(2)))})
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.3,...
            'LabelFontSizeMultiplier', 1.3,...
            'XScale', 'linear')

        subplot(3,8,atual+1);
        plot(dataFull{nData,i}.Bands.SpeedMzAvg',dataFull{nData,i}.Bands.DeltaMzAvg, '.')
        xlabel('Speed')
        ylabel('Frequency(Hz)')
        xlim([0,1000])
        title({strcat(dataFull{nData,i}.Name(1:16),sprintf('\nWh R: %f P: %f', r1(2), p1(2)))})
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.3,...
            'LabelFontSizeMultiplier', 1.3,...
            'XScale', 'linear') 

    end

    if save
        fileName = char(strcat(savePath, 'Individual_', name,'InstFreqXSpeed'));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end

%% 3.2.6 - InstFreq Corr Group 
clf
save = 0;
for nData=1:numReads
    concatMzSpeed = [];
    concatMzDelta = [];
    concatWhSpeed = [];
    concatWhDelta = [];
    for i=1:dataLineCount(nData)      
        concatMzSpeed = [concatMzSpeed, dataFull{nData,i}.Bands.SpeedMzAvg];
        concatMzDelta = [concatMzDelta, dataFull{nData,i}.Bands.DeltaMzAvg];
        concatWhSpeed = [concatWhSpeed, dataFull{nData,i}.Bands.SpeedWhAvg];
        concatWhDelta = [concatWhDelta, dataFull{nData,i}.Bands.DeltaWhAvg];
    end
    
    [rMz, pMz] = corr(concatMzSpeed',concatMzDelta');
    [rWh, pWh] = corr(concatWhSpeed',concatWhDelta');
    sprintf('MZ R: %.4f P: %.4f WH R: %.4f P: %.4f\n', rMz, pMz, rWh, pWh)
    
    name = 'Pre';
    if nData == 2
       name = 'Pos';
    end
           
    fig = figure(nData);
    fig.Position = [1 1 1900 1000];
    plot(concatMzSpeed, concatMzDelta, 'k.')
    title(sprintf('Inst. frequency X Speed - Group - %s Muscimol', name))
    hold on
    plot(concatWhSpeed, concatWhDelta, 'r.')
    xlim([0,1200])
    ylim([2.5,5.5])
    xlabel('Speed')
    ylabel('Frequency(Hz)')
    title(sprintf('Inst. frequency X Speed - Group - %s Muscimol', name))
    line = lsline;
    for i=1:2
        line(i).LineWidth = 2;
    end
    label1{1} = sprintf('Maze R: %.4f P: %.4f', rMz, pMz);
    label1{2} = sprintf('Wheel R: %.4f P: %.4f', rWh, pWh);
    legend(label1,'location','bestoutside','orientation','horizontal')
    % Aesthetics
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear') 
    if save
        fileName = char(strcat(savePath, 'Group_Mz_n_Wh_', name,'InstFreq_X_Speed_Corr'));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end

end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.7 - Amplitude group
clf
save = 0;
for nData=1:numReads
    concatMzSpeed = [];
    concatMzDelta = [];
    concatWhSpeed = [];
    concatWhDelta = [];
    for i=1:dataLineCount(nData)
       
        concatMzSpeed = [concatMzSpeed, dataFull{nData,i}.Bands.SpeedMzAvg];
        concatMzDelta = [concatMzDelta, dataFull{nData,i}.Bands.AmpMzAvg];
        concatWhSpeed = [concatWhSpeed, dataFull{nData,i}.Bands.SpeedWhAvg];
        concatWhDelta = [concatWhDelta, dataFull{nData,i}.Bands.AmpWhAvg];

    end
    
    [rMz, pMz] = corr(concatMzSpeed',concatMzDelta');
    [rWh, pWh] = corr(concatWhSpeed',concatWhDelta');
    sprintf('MZ R: %.4f P: %.4f WH R: %.4f P: %.4f\n', rMz, pMz, rWh, pWh)
    
    name = 'Pre';
    if nData == 2
       name = 'Pos';
    end
           
    fig = figure(nData);
    fig.Position = [1 1 1900 1000];
    plot(concatMzSpeed, concatMzDelta, 'k.')
    title(sprintf('Instantaneous Speed X Amplitude - Group - %s Muscimol', name))
    hold on
    plot(concatWhSpeed, concatWhDelta, 'r.')
    xlim([90,1200])
    ylim([0,800])
    title(sprintf('Instantaneous Speed X Amplitude - Group - %s Muscimol', name))
    line = lsline;
    for i=1:2
        line(i).LineWidth = 2;
    end
    label1{1} = sprintf('Maze R: %.4f P: %.4f', rMz, pMz);
    label1{2} = sprintf('Wheel R: %.4f P: %.4f', rWh, pWh);
    legend(label1,'location','bestoutside','orientation','horizontal')
    hold off
    % Aesthetics
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear') 
    if save
        fileName = char(strcat(savePath, 'Group_Mz_n_Wh_', name,'Amp_X_Speed_Corr'));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.8 - Auto corr
clf
save = 0;
for nData=1:numReads
    for i=1%:dataLineCount(nData)
        sprintf('%d %d',nData, i)
                
        if nData == 1
            ttl = 'Autocorrelogram - Pre Muscimol';
            name = 'pre';
        else
            ttl = 'Autocorrelogram - Pos Muscimol';
            name = 'pos';
        end
        
        LFPMz = dataFull{nData,i}.Track.LFPMz;
        LFPWh = dataFull{nData,i}.Track.LFPWh;
        
        [mz, mzLags] = xcorr(LFPMz, 'coef', 1000);
        [wh, whLags] = xcorr(LFPWh, 'coef', 1000);
        
        whIdx = dataFull{nData,i}.Laps.WhIdx;
        mzIdx = dataFull{nData,i}.Laps.MzIdx;
        
        deltaMz = dataFull{nData,i}.Bands.Delta(mzIdx);
        deltaWh = dataFull{nData,i}.Bands.Delta(whIdx);
        
        [dtMz, dtMzLags] = xcorr(deltaMz, 'coef', 1000);
        [dtWh, dtWhLags] = xcorr(deltaWh, 'coef', 1000);
        
        %Plot
        fig = figure(i);
        sgtitle(ttl)
        fig.Position = [1 1 1600 1000];
        subplot(1,2,1);
        plot(mzLags, mz)
        ylabel('ACG')
        xlabel('Lag(ms)')
        xlim([-1000,1000])
        ylim([-0.6,1])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG LFP', {' '}, name, ' Mz'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        
        subplot(1,2,2);
        plot(whLags, wh)
        ylabel('ACG')
        xlabel('Lag(ms)')
        xlim([-1000,1000])
        ylim([-0.6,1])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG LFP', {' '}, name, ' Wh'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 

        figg = figure(i+numSubReads);
        figg.Position = [1 1 1900 1000];
        sgtitle(ttl)
%         fig.Position = [1 1 1600 1000];
        subplot(1,2,1);
        plot(dtMzLags, dtMz)
        ylabel('ACG')
        xlabel('Lag(ms)')
        ylim([-1,1])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG Delta', {' '}, name, ' Mz'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        subplot(1,2,2);
        plot(dtWhLags, dtWh)
        ylabel('ACG')
        xlabel('Lag(ms)')
        ylim([-1,1])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG Delta', {' '}, name, ' Wh'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        if save
          fileNameLFP = char(strcat(savePath, 'Individual_', dataFull{nData,i}.Name(1:16),{'_'},name,'_ACG_LFP'));
          fileNameBand = char(strcat(savePath, 'Individual_', dataFull{nData,i}.Name(1:16),{'_'},name,'_ACG_Delta'));
          saveas(fig,fileNameLFP, 'epsc');
          saveas(fig,fileNameLFP, 'png');
          saveas(figg,fileNameBand, 'epsc');
          saveas(figg,fileNameBand, 'png');
        end

    end

end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 3.2.9 - Snippet corr
clf
save = 0;
for nData=1:numReads
    if nData == 1
        ttl = 'ACG snippet - Pre Muscimol';
        name = 'pre';
        fgSpace = 0;
    else
        ttl = 'ACG snippet - Pos Muscimol';
        name = 'pos';
        fgSpace = numSubReads;
    end
    
    for i=1:dataLineCount(nData)
        sprintf('%d %d',nData, i)
        % LFP
        LFPMz = dataFull{nData,i}.Track.LFPMz;
        LFPWh = dataFull{nData,i}.Track.LFPWh;
        
        % Capture snippet
        auxMz = [];
        ms = 10*srate; % Sec
        for idx=[1:ms:size(LFPMz, 2)-ms]
            [acg, lagsMz] = xcorr(LFPMz(idx:idx+ms),'coef', 1000);    
            auxMz = [ auxMz; acg ];
        end    
        
        auxWh = [];
        for idx=[1:ms:size(LFPWh, 2)-ms]
            [acg, lagsWh] = xcorr(LFPWh(idx:idx+ms),'coef', 1000);    
            auxWh = [ auxWh; acg ];
        end    
        
        if nData == 1
            dataFull{nData,i}.Track.MzSnippetPre = auxMz;
            dataFull{nData,i}.Track.WhSnippetPre = auxWh;
        else
            dataFull{nData,i}.Track.MzSnippetPos = auxMz;
            dataFull{nData,i}.Track.WhSnippetPos = auxWh;
        end
        
        fig = figure(fgSpace+i);
        fig.Position = [1 1 1900 1000];
        subplot(1,2,1)
        imagesc(lagsMz, [1:size(auxMz, 1)], auxMz)
        ylabel('Time(s)')
        xlabel('Time(ms)')
        ytks = gca;
        ytks.YTickLabel = ytks.YTick * 10;
        colorbar
        caxis([-0.5,1])
        xlim([-500, 500])
        title(strcat('Mz',{' '}, ttl ))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'LineWidth', 1,...
            'FontSize', 15, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        subplot(1,2,2)
        imagesc(lagsWh, [1:size(auxWh, 1)], auxWh)
        ylabel('Time(s)')
        xlabel('Time(ms)')
        ytks = gca;
        ytks.YTickLabel = ytks.YTick * 10;
        colorbar
        caxis([-0.5,1])
        xlim([-500, 500])
        title(strcat('Wh',{' '}, ttl ))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'LineWidth', 1,...
            'FontSize', 15, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        if save
          fileName = char(strcat(savePath, 'Individual_', dataFull{nData,i}.Name(1:16),{'_'}, name,'_ACG_Imagesc'));
          saveas(fig,fileName, 'epsc');
          saveas(fig,fileName, 'png');
        end
    end
end
%% 3.2.10 - Combined ACG
clf
save = 0;
for nData=1:numReads
    for i=1:dataLineCount(nData)
        sprintf('%d %d',nData, i)
                
        if nData == 1
            ttl = 'Autocorrelogram - Pre Muscimol';
            name = 'pre';
            fgSpace = 0;
        else
            ttl = 'Autocorrelogram - Pos Muscimol';
            name = 'pos';
            fgSpace = numSubReads;
        end
        
        LFPMz = dataFull{nData,i}.Track.LFPMz;
        LFPWh = dataFull{nData,i}.Track.LFPWh;
    
        % Capture snippet
        auxMz = [];
        ms = 10*srate; % Sec
        for idx=[1:ms:size(LFPMz, 2)-ms]
            [acg, lagsMz] = xcorr(LFPMz(idx:idx+ms),'coef', 1000);    
            auxMz = [ auxMz; acg ];
        end    
        
        auxWh = [];
        for idx=[1:ms:size(LFPWh, 2)-ms]
            [acg, lagsWh] = xcorr(LFPWh(idx:idx+ms),'coef', 1000);    
            auxWh = [ auxWh; acg ];
        end
        
        % ACG
        [mz, mzLags] = xcorr(LFPMz, 'coef', 1000);
        [wh, whLags] = xcorr(LFPWh, 'coef', 1000);
        
        whIdx = dataFull{nData,i}.Laps.WhIdx;
        mzIdx = dataFull{nData,i}.Laps.MzIdx;
        
        deltaMz = dataFull{nData,i}.Bands.Delta(mzIdx);
        deltaWh = dataFull{nData,i}.Bands.Delta(whIdx);
        
%         [dtMz, dtMzLags] = xcorr(deltaMz, 'coef', 1000);
%         [dtWh, dtWhLags] = xcorr(deltaWh, 'coef', 1000);
        
        %Plot
        fig = figure(fgSpace+i);
        sgtitle(ttl)
        fig.Position = [1 1 1600 1000];
        subplot(1,2,1);
        yyaxis right
        plot(mzLags, mz, 'w')%, 'LineWidth',1.2)
        ylabel('ACG')
        ylim([-0.6,1])
        hold on
        yyaxis left
        imagesc(lagsMz, [1:size(auxMz, 1)], auxMz)
        ylabel('Time(s)')
        xlabel('Lag(ms)')
        xlim([-500,500])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG LFP', {' '}, name, ' Mz'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 
        
        subplot(1,2,2);
        yyaxis right
        plot(whLags, wh, 'w')%, 'LineWidth',2)
        ylabel('ACG')
        ylim([-0.6,1])
        hold on
        yyaxis left
        imagesc(lagsWh, [1:size(auxWh, 1)], auxWh)
        ylabel('Time(s)')
        xlabel('Lag(ms)')
        xlim([-500,500])
        title(strcat(dataFull{nData,i}.Name(1:16), ' ACG LFP', {' '}, name, ' Wh'))
        % Aesthetics
        set(gca, ...
            'Box',      'off',...
            'FontName', 'Helvetica',...
            'TickDir',  'out', ...
            'TickLength', [.02 .02],...
            'YGrid',     'on',...
            'GridLineStyle', '-.',...
            'XColor',    [.3 .3 .3],...
            'YColor',    [.3 .3 .3],...
            'LineWidth', 1,...
            'FontSize', 8, ...
            'FontWeight', 'bold',...
            'TitleFontSizeMultiplier', 1.6,...
            'LabelFontSizeMultiplier', 1.4,...
            'XScale', 'linear') 

        
        if save
          fileNameLFP = char(strcat(savePath, 'Combined_Individual_', dataFull{nData,i}.Name(1:16),{'_'},name,'_ACG_LFP'));
          saveas(fig,fileNameLFP, 'epsc');
          saveas(fig,fileNameLFP, 'png');
        end

    end

end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos
%% 4.1 - Firing rate
namesLst = [];
valLst = zeros(dataLineCount(1),4);

mzRate = {};
whRate = {};
for nData=1:numReads
    mzRate{nData} = [];
    whRate{nData} = [];
    for i=1:dataLineCount(nData)
        if nData == 1
            namesLst = [namesLst; dataFull{nData,i}.Name(1:13)];
        end
        spktimes = dataFull{nData,i}.Spike.res;
        spkid    = dataFull{nData,i}.Spike.totclu;
        IsInt    = dataFull{nData,i}.Clu.isIntern;
        % idx MZ-WH
        MzSpeed = dataFull{nData,i}.Spike.speed_MMsec;%Track.speed_MMsec;%Speed on maze
        WhSpeed = dataFull{nData,i}.Spike.whlSpeed;%Laps.WhlSpeedCW+Laps.WhlSpeedCCW;%Speed on wheel
        Mzidx   = find(MzSpeed>100);
        Whidx   = find(WhSpeed>100);
        %TIME
        Mzlength = sum(dataFull{nData,i}.Track.speed_MMsec>100)/srate;
        Whlength = sum((dataFull{nData,i}.Laps.WhlSpeedCW+dataFull{nData,i}.Laps.WhlSpeedCCW)>100)/srate;
        
        respM = zeros(2, length(IsInt));
        respW = zeros(2, length(IsInt));
        for j=1:length(IsInt)
            respM(1,j) = length(find(spkid(Mzidx)==j))/Mzlength;           
            respM(2,j) = IsInt(j);
            respW(1,j) = length(find(spkid(Whidx)==j))/Whlength;                       
            respW(2,j) = IsInt(j);
        end
        
        mzRate{nData}  = [mzRate{nData}, respM];
        whRate{nData}  = [whRate{nData}, respW]; 
    end
end

meanIsNoMz = zeros(1,2);
meanIsInMz = zeros(1,2);
meanIsNoWh = zeros(1,2);
meanIsInWh = zeros(1,2);
for i=1:2
    meanIsNoMz(i) = mean(mzRate{i}(1,find(mzRate{i}(2,:) == 0)));
    meanIsInMz(i) = mean(mzRate{i}(1,find(mzRate{i}(2,:) == 1)));
    meanIsNoWh(i) = mean(whRate{i}(1,find(whRate{i}(2,:) == 0)));
    meanIsInWh(i) = mean(whRate{i}(1,find(whRate{i}(2,:) == 1)));
    if i == 1
        sprintf('Pre')
    else
        sprintf('Pos')
    end
    sprintf('Mz IsInt: %f IsNInt: %f\nWh: IsInt: %f IsNInt: %f\n', meanIsInMz(i), meanIsNoMz(i), meanIsInWh(i), meanIsNoWh(i)) 
end


save = 0;
if save
    fileID = fopen(strcat(savePath,'Individual_spike_number.txt'), 'w');
    fprintf(fileID, "Spikes count\n");
else
    fileID = '';
end

% for i=1:length(mzRate)
%     temp = sprintf('Neuron %i: Mz %0.5f, Wh %0.5f\n', i, respM(i), respW(i))
%     if save
%         fprintf(fileID, temp)
%     end
% end
if save
    fclose(fileID)
end
% for nData=1:numReads
%     Mz  = [];
%     Wh  = [];
%     Nn  = [];
%     IsI = [];
%     for i=1:dataLineCount(nData)
%         Mz  = [Mz, FrateMz{nData,i}];
%         Wh  = [Wh, FrateWh{nData,i}];
%         Nn  = [Nn, length(Interneurons{nData,i})];
%         IsI = [IsI, Interneurons{nData,i}];
%     end
%     MzFr{nData}   = Mz;
%     WhFr{nData}   = Wh;
%     Nneur{nData}  = Nn;
%     Intern{nData} = IsI;
% end
% clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos MzFr WhFr Intern
%% 4.2 - Plot fire rate
clf
save = 0;
conditions = [ 1,1,1 ; 2,2,2; 1,2,1; 1,2,1];
titles = ["Pre", "Pos", "Maze", "Wheel"];
xLabels = ["Maze", "Wheel"; "Maze","Wheel"; "Pre","Pos"; "Pre", "Pos"];
pyrList = ["Pyramidal", "Interneuron"];

for pyr=0:1
    for i=1:size(conditions, 1)
        cond = conditions(i,:);

        if i == 1
            left = MzFr{cond(1)};
            right = WhFr{cond(2)};
        elseif i == 2
            left = MzFr{cond(1)};
            right = WhFr{cond(2)};
        elseif i == 3
            left = MzFr{cond(1)};
            right = MzFr{cond(2)};
        else
            left = WhFr{cond(1)};
            right = WhFr{cond(2)};    
        end

        thresh = 0.01;
        FRidx = find(left>thresh & right>thresh & Intern{cond(3)}==pyr);
        FRleft = left(FRidx);
        FRright = right(FRidx);

        fig = figure(pyr+1);
        subplot(2,2,i)
        bar([mean(FRleft),mean(FRright)],'w')
        hold on        
        errorbar([mean(FRleft),mean(FRright)],[std(FRleft)/sqrt(length(FRleft)),std(FRright)/sqrt(length(FRright))],'.k')
        xlim([0, 3])
        xticklabels({xLabels(i,1), xLabels(i,2)})
        title(strcat(pyrList(pyr+1), {' - '}, titles(i)))
        ylabel('Firing rate (Hz)')
        [h, p] = ttest(FRleft,FRright);
%         sprintf("h: %f p: %f", h, p)
        hold on
        if h == 1
            plot(1.5, 0.0, '*')
            text(1.5, 0.5, sprintf('P-value: %0.4f', p), 'Rotation', 90)
        end
        set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear')  
    
    end
    if save
      fileNameLFP = char(strcat(savePath, 'Group_', pyrList(pyr+1), {'_'}, titles(i), '_Fire_Rate'));
      saveas(fig,fileNameLFP, 'epsc');
      saveas(fig,fileNameLFP, 'png');
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath pMzPre pWhPre pMzPos pWhPos MzFr WhFr Intern
%%
