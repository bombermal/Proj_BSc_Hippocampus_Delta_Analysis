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
        trackNames(find(strcmp(trackNames, 'corrChoice'))) = [];
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
        % Pre x Pos   
        key = "Pre";
        if nData == 2
            key = "Pos";
        end
        dataFull{nData,i} = fillStruct(key, srate, WindowLength, Overlap, NFFT, dataFull{nData,i}, 100, 100);
        sprintf('%d %d',nData, i)
    end
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads
%% Process file
% 2.1 - Save loaded files
% savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/';
file = char(strcat(savePath, 'PwelchProcessed.mat'));

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
% 3.1 - Error proportion
prop = {};
prop{1}.Hit = [];
prop{1}.Err = [];
prop{2}.Hit = [];
prop{2}.Err = [];
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';

if save
    fileID = fopen(strcat(savePath,'Individual_hits_proportion.txt'), 'w');
else
    fileID = '';
end

for nData=1:numReads
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    sprintf('%s', key)
    for i=1:dataLineCount(nData)
        
        dataTemp = dataFull{nData, i};
        lap = dataTemp.Track.lapID;
        uniqueLap = unique(lap);
        
        aux = zeros(length(uniqueLap));
        for lp=1:length(uniqueLap)
            lapMask = lap == uniqueLap(lp);
            cChoice = dataTemp.Track.corrChoice(lapMask);
            aux(lp) = cChoice(1);
        end
        
        [count, value] = groupcounts(aux);
        
        err = (count(1)/sum(count))*100;
        hit = (count(2)/sum(count))*100;
        temp = sprintf('%s: Hits Freq: %i/%i = %.2f - Miss Freq: %i/%i = %.2f\n', dataTemp.Name(1:13), count(2), sum(count), hit, count(1), sum(count), err)
        fprintf(fileID, temp);
        prop{nData}.Hit = [prop{nData}.Hit; hit];
        prop{nData}.Err = [prop{nData}.Err; err];
        
    end
end
if save
    fclose(fileID)
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath prop
%% 3.1.1 Plot proportion
% Save path for results
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';

save = 0;
fig = figure(1);
boxplot([prop{1}.Hit, prop{2}.Hit, prop{1}.Err, prop{2}.Err] )

xticklabels(["Hits","Hits","Miss","Miss"])
xlabel("Pre - Pos")
ylabel("Proportion(%)")
title("Miss and hits proportion - Pre x Pos Muscimol")
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
    fileName = char(strcat(savePath, 'Miss_n_hits_proportion'));
    saveas(fig,fileName, 'epsc');
    saveas(fig,fileName, 'png');
end
clearvars -except dataFull srate dt dataLineCount numReads numSubReads savePath prop
%%
% 3.1.2 - Load each pwelch array and concat each trial
% Save results boolean, 1: YES, 0: NO
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';

if save
    fileID = fopen(strcat(savePath,'Trial_statistics.txt'), 'w');
else
    fileID = '';
end
bands = [3,5];
for nData=1:numReads   
    pHits = [];
    pMiss = [];
    for i=1:dataLineCount(nData)
        dataTemp = dataFull{nData, i}.Pwelch;
        fMask = (dataTemp.Frequency >= bands(1)) & (dataTemp.Frequency <= bands(2) );
        lMask = dataTemp.Momment == "Pre";
        rMask = dataTemp.Choice == 1;

        if nData == 1
            pHits = [pHits; dataTemp.Psd(fMask & lMask & rMask)];
            pMiss = [pMiss; dataTemp.Psd(fMask & lMask & ~rMask)];
        else
            pHits = [pHits; dataTemp.Psd(fMask & ~lMask & rMask)];
            pMiss = [pMiss; dataTemp.Psd(fMask & ~lMask & ~rMask)];
        end
    end
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    perc = printStats(pHits, pMiss, bands,strcat(key, ' - Hits x Miss'));
%     pppSave(perc, power, peak, save, fileID);


end
if save
    fclose(fileID)
end
%% 3.1.3 Process Max power, max freq, speed

lOne = struct("MaxPower", [], "MaxFreq", [], "Speed", []);
lTwo = struct("Wh", lOne, "Mz", lOne);
lThr = repmat(lTwo, 10,1);
data = {lThr, lThr};

wSpeed = 100;
mSpeed = 100;

bands = [3,5];
for nData=1:numReads   
    pHits = [];
    pMiss = [];
    for i=1:dataLineCount(nData)
        dataTemp = dataFull{nData, i}.Pwelch;
        fMask = (dataTemp.Frequency >= bands(1)) & (dataTemp.Frequency <= bands(2) );
        lMask = dataTemp.Momment == "Pre";
        rMask = dataTemp.Choice == 1;
        jobMask = dataTemp.Job == 'Mz';
        
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        resp = [];
        
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            speedMz = mean(dataTemp.MzSpeedMean(lapMask));
            speedWh = mean(dataTemp.WhSpeedMean(lapMask));
 
            mzFreq = dataTemp.Frequency(fMask & lapMask & jobMask);
            [mzVal, mzIdx] = max(dataTemp.Psd(fMask & lapMask & jobMask));
            data{nData}(i).Mz.MaxPower = [data{nData}(i).Mz.MaxPower; mzVal];        
            data{nData}(i).Mz.MaxFreq = [data{nData}(i).Mz.MaxFreq; mzFreq(mzIdx)];           
            data{nData}(i).Mz.Speed = [data{nData}(i).Mz.Speed; speedMz];
            
            whFreq = dataTemp.Frequency(fMask & lapMask & ~jobMask);
            [whVal, whIdx] = max(dataTemp.Psd(fMask & lapMask & ~jobMask));
            
            data{nData}(i).Wh.MaxPower = [data{nData}(i).Wh.MaxPower; mzVal];        
            data{nData}(i).Wh.MaxFreq = [data{nData}(i).Wh.MaxFreq; mzFreq(whIdx)];           
            data{nData}(i).Wh.Speed = [data{nData}(i).Wh.Speed; speedMz];
        end

    end

end
clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
%% 3.2.1 - Plot max power, max freq and speed
clf
whS = [];
whP = [];
whF = [];
mzS = [];
mzP = [];
mzF = [];
save = 0;

for nData=1:numReads
    for i=1:dataLineCount(nData)
    
    whS = [whS; data{nData}(i).Wh.Speed];
    whP = [whP; data{nData}(i).Wh.MaxPower];
    whF = [whF; data{nData}(i).Wh.MaxFreq];
    mzS = [mzS; data{nData}(i).Mz.Speed];
    mzP = [mzP; data{nData}(i).Mz.MaxPower];
    mzF = [mzF; data{nData}(i).Mz.MaxFreq];
    
    end
    % Pre x Pos   
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    
    fig = figure(nData);
    fig.Position = [1 1 1600 1000];
    subplot(2,2,1)
    plot(mzS, mzP, 'k.')
    xlabel('Speed')
    ylabel('Max Power')
    title('Maze Max Power')
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
    subplot(2,2,2)
    plot(whS, whP, 'r.')
    xlabel('Speed')
    ylabel('Max Power')
    title('Wheel Max Power')
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
    
    subplot(2,2,3)
    plot(mzS, mzF, 'k.')
    xlabel('Speed')
    ylabel('Max Frequency')
    title('Maze Max Frequency')
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
    subplot(2,2,4)
    plot(whS, whF, 'r.')
    xlabel('Speed')
    ylabel('Max Frequency')
    title('Wheel Max Frequency')
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
        fileName = char(strcat(savePath, 'Max_Power_n_Frequency_', key));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end
clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
%% 3.2.2 - Group PSD - Composed by mean psd for all trials in each animal
save = 0;

data = {struct('Mz', [], 'Wh', [], 'Freq', []), struct('Mz', [], 'Wh', [], 'Freq', [])}; 
for nData=1:numReads

    for i=1:dataLineCount(nData)
        dataTemp = dataFull{nData, i}.Pwelch;
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        mzPsd = [];
        mzFrq = [];
        whPsd = [];
        whFrq = [];
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            jobMask = dataTemp.Job == "Mz";
            
            mzPsd = [mzPsd, dataTemp.Psd(lapMask & jobMask)];
            mzFrq = [mzFrq, dataTemp.Frequency(lapMask & jobMask)];
            whPsd = [whPsd, dataTemp.Psd(lapMask & ~jobMask)];
%             whFrq = [whFrq, dataTemp.Frequency(lapMask & ~jobMask)];
        end
        data{nData}.Mz = [data{nData}.Mz, mean(mzPsd,2)];
        data{nData}.Wh = [data{nData}.Wh, mean(whPsd,2)];
        data{nData}.Freq = [data{nData}.Freq, mean(mzFrq,2)];
    end
    
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    
    fig = figure(1);
    fig.Position = [1 1 1600 1000];
    subplot(1,2,nData);
    x = mean(data{nData}.Freq, 2);
    plot(x, mean(data{nData}.Wh,2), 'r', x, mean(data{nData}.Mz,2), 'k')
    xlim([0,12])
    ylim([-1000 , 46000])
    box off
    label1{1} = 'Wheel';
    label1{2} = 'Maze';
    legend(label1,'location','bestoutside','orientation','horizontal')
    legend('boxoff')
    ylabel('Power')
    xlabel('Frequency(Hz)')
    title(strcat("Mean PSD - ", key))
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
    'LabelFontSizeMultiplier', 1.6,...
    'XScale', 'linear') 
end

if save
    fileName = char(strcat(savePath, 'Group_PSD_Pre_Pro'));
    saveas(fig,fileName, 'epsc');
    saveas(fig,fileName, 'png');
end

clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
%% 3.2.3 - Group PSD + std
clf
save = 0;

data = {struct('Mz', [], 'Wh', [], 'Freq', []), struct('Mz', [], 'Wh', [], 'Freq', [])}; 
for nData=1:numReads

    for i=1:dataLineCount(nData)
        dataTemp = dataFull{nData, i}.Pwelch;
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        mzPsd = [];
        mzFrq = [];
        whPsd = [];
        whFrq = [];
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            jobMask = dataTemp.Job == "Mz";
            
            mzPsd = [mzPsd, dataTemp.Psd(lapMask & jobMask)];
            mzFrq = [mzFrq, dataTemp.Frequency(lapMask & jobMask)];
            whPsd = [whPsd, dataTemp.Psd(lapMask & ~jobMask)];
%             whFrq = [whFrq, dataTemp.Frequency(lapMask & ~jobMask)];
        end
        data{nData}.Mz = [data{nData}.Mz, mean(mzPsd,2)];
        data{nData}.Wh = [data{nData}.Wh, mean(whPsd,2)];
        data{nData}.Freq = [data{nData}.Freq, mean(mzFrq,2)];
    end
    
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    
    fig = figure(1);
    fig.Position = [1 1 1600 1000];
    subplot(1,2,nData);
    
    x = mean(data{nData}.Freq, 2);
    meanWh = mean(data{nData}.Wh,2);
    meanMz = mean(data{nData}.Mz,2);
    % Std  
    stdMz = std(meanMz)/sqrt(dataLineCount(nData));
    stdWh = std(meanWh)/sqrt(dataLineCount(nData));
    
    plot(x, meanWh , 'r', x, meanMz, 'k')
    hold on
    plot(x, meanMz+stdMz, 'k--', x, meanMz-stdMz, 'k-.')
    plot(x, meanWh+stdWh, 'r--', x, meanWh-stdWh, 'r-.')
    xlim([0,12])
    ylim([-1000 , 46000])
    label1{1} = 'Wheel';
    label1{2} = 'Maze';
    label1{3} = 'Maze + std';
    label1{4} = 'Maze - std';
    label1{5} = 'Wheel + std';
    label1{6} = 'Wheel - std';
    box off
    legend(label1,'location','bestoutside','orientation','horizontal')
    legend('boxoff')
    ylabel('Power')
    xlabel('Frequency(Hz)')
    title(strcat("Mean PSD - ", key))
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
    'LabelFontSizeMultiplier', 1.6,...
    'XScale', 'linear') 
end

if save
    fileName = char(strcat(savePath, 'Group_PSD_Pre_Pro_Std'));
    saveas(fig,fileName, 'epsc');
    saveas(fig,fileName, 'png');
end

clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
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
clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
