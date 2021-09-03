%% 0 - Imports
clear
clc
close all
format compact
cd('D:/Ivan/OneDrive/Códigos ( Profissional )/ICE/Proj_BSc_Hippocampus_Delta_Analysis');
addpath('Rotinas/Functions/');
srate=1250;
dt=1/srate;
%% 1 - Pre process
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

% Pwelch - Specifications
WindowLength = 1*srate;
Overlap      = 0.9*srate;
NFFT         = 2^13;

order = [0,0; 1,0; 0,1];
tittles = ["Pwelch", "Delta", "Theta"];
wSpeed = 100;
mSpeed = 100;

savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/Single Files/';

% Load files
for idx=2:3
    for i=1:size(filePaths,1)
        % List all files in each directory
        absolutFilePath = ls(fullfile(filePaths(i,1:end), '*.mat'));
        % Get the number of files
        [numFil, ~ ] = size(absolutFilePath);

        % Load each .mat in the structure
        for j=1:numFil
            dataSingle = load(strcat(filePaths(i,1:end),absolutFilePath(j, 1:end)), 'Track', 'Laps', 'Clu', 'Spike');

            trackNames = fieldnames(dataSingle.Track);
            trackNames(find(strcmp(trackNames, 'eeg'))) = [];
            trackNames(find(strcmp(trackNames, 'speed_MMsec'))) = [];
            trackNames(find(strcmp(trackNames, 'lapID'))) = [];
            trackNames(find(strcmp(trackNames, 'corrChoice'))) = [];
            lapsNames = fieldnames(dataSingle.Laps);
            lapsNames(find(strcmp(lapsNames, 'WhlSpeedCCW'))) = [];
            lapsNames(find(strcmp(lapsNames, 'WhlSpeedCW'))) = [];
            spikeNames = fieldnames(dataSingle.Spike);
            spikeNames(find(strcmp(spikeNames, 'totclu'))) = [];
            spikeNames(find(strcmp(spikeNames, 'speed_MMsec'))) = [];
            spikeNames(find(strcmp(spikeNames, 'whlSpeed'))) = [];
            spikeNames(find(strcmp(spikeNames, 'res'))) = [];
            cluNames = fieldnames(dataSingle.Clu);
            cluNames(find(strcmp(cluNames, 'isIntern'))) = [];

            dataSingle.Track = rmfield(dataSingle.Track,trackNames);
            dataSingle.Laps = rmfield(dataSingle.Laps,lapsNames);        
            dataSingle.Spike = rmfield(dataSingle.Spike,spikeNames);  
            dataSingle.Clu = rmfield(dataSingle.Clu,cluNames);  
            dataSingle.Name = absolutFilePath(j, 1:16);

            dataSingle.Track.origEeg = dataSingle.Track.eeg;
            % Filter noise
            dataSingle = filterLFP(dataSingle, srate);

            % Process
            delta = order(idx, 1);
            theta = order(idx, 2);
            dataSingle = fillStruct(srate, WindowLength, Overlap, NFFT, dataSingle, wSpeed, mSpeed, delta, theta);

            names = fieldnames(dataSingle);
            names(find(strcmp(names, 'Pwelch'))) = [];
            names(find(strcmp(names, 'Band'))) = [];
            names(find(strcmp(names, 'Spike'))) = [];
            names(find(strcmp(names, 'Name'))) = [];
            dataSingle = rmfield(dataSingle,names);

            % Save
            % Save Path
            mmtTtl = 'Pre';
            if i == 2
                mmtTtl = 'Pos';
            end
            sessionName = dataSingle.Name;
            
            file = sprintf('%s%s/%s/%s.mat', savePath, tittles(idx), mmtTtl, sessionName);
            save(file, 'dataSingle', '-v7.3')
            toc
            sprintf('Dir: %d, File: %d', i, j)
        end
    end
end

%% Load processed file
% 2.0 - Load file
tic
clear
clc
close all
format compact
cd('D:/Ivan/OneDrive/Códigos ( Profissional )/ICE/Proj_BSc_Hippocampus_Delta_Analysis');
addpath('Rotinas/Functions/');
srate=1250;
dt=1/srate;

rootPath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/Single Files/';
subPath = ["Pwelch", "Delta", "Theta"];
idx = 2;
loadPath = sprintf('%s%s/', rootPath, subPath(idx));

% Load files
dataFull = {};
% Load Pre
absolutFilePath = ls(fullfile(sprintf('%sPre/', loadPath), '*.mat'));
for file=1:size(absolutFilePath, 1)
    fileName = absolutFilePath(file, :);
    dataFull{1, file} = load(strcat(loadPath, 'Pre\', fileName));
    dataFull{1, file} = dataFull{1, file}.dataSingle;
    sprintf('%s - Pre - File: %d', subPath(idx), file)
end
% Load Pos
absolutFilePath = ls(fullfile(sprintf('%sPos/', loadPath), '*.mat'));
for file=1:size(absolutFilePath, 1)
    fileName = absolutFilePath(file, :);
    dataFull{2, file} = load(strcat(loadPath, 'Pos\', fileName));
    dataFull{2, file} = dataFull{2, file}.dataSingle;
    sprintf('%s - Pos - File: %d', subPath(idx), file)
end
[numReads, numSubReads ] = size(dataFull);
clearvars -except dataFull srate dt numReads numSubReads 
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
[numReads, numSubReads ] = size(dataFull);

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
    
    for i=1:numSubReads
        
        dataTemp = dataFull{nData, i};
        lap = dataTemp.Pwelch.Lap;
        uniqueLap = unique(lap);
        
        aux = zeros(length(uniqueLap), 1);
        for lp=1:length(uniqueLap)
            lapMask = lap == uniqueLap(lp);
            cChoice = dataTemp.Pwelch.Choice(lapMask);
            aux(lp) = cChoice(1, 1);
        end
        
        [count, value] = groupcounts(aux);

        if length(value) == 1
            if value == 0
                count(2) = 0;
                value(2) = 1;
            else
                count = [0, count];
                value = [0, value];
            end
        end
                
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
% 3.1.2 - Load each pwelch array and concat each session
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
    for i=1:numSubReads
        dataTemp = dataFull{nData, i}.Pwelch;
        fMask = (dataTemp.Frequency >= bands(1)) & (dataTemp.Frequency <= bands(2) );
        rMask = dataTemp.Choice == 1;

        if nData == 1
            pHits = [pHits; dataTemp.Psd(fMask & rMask)];
            pMiss = [pMiss; dataTemp.Psd(fMask & ~rMask)];
        else
            pHits = [pHits; dataTemp.Psd(fMask & rMask)];
            pMiss = [pMiss; dataTemp.Psd(fMask & ~rMask)];
        end
    end
    key = "Pre";
    if nData == 2
        key = "Pos";
    end
    perc = printStats(pHits, pMiss, bands,strcat(key, ' - Hits x Miss'));
    pppSave(perc, save, fileID);


end
if save
    fclose(fileID)
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.1.3 Process Max power, max freq, speed
% Create a structure and save all values in

lOne = struct("MaxPower", [], "MaxFreq", [], "Speed", [], "Choice", []);
lTwo = struct("Wh", lOne, "Mz", lOne);
lThr = repmat(lTwo, 10,1);
data = {lThr, lThr};

wSpeed = 100;
mSpeed = 100;

bands = [3,5];
for nData=1:numReads   
    pHits = [];
    pMiss = [];
    for i=1:numSubReads
        dataTemp = dataFull{nData, i}.Pwelch;
        fMask = (dataTemp.Frequency >= bands(1)) & (dataTemp.Frequency <= bands(2) );
        jobMask = dataTemp.Job == 'Mz';
        
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            speedMz = mean(dataTemp.MzSpeedMean(lapMask));
            speedWh = mean(dataTemp.WhSpeedMean(lapMask));
 
            mzFreq = dataTemp.Frequency(fMask & lapMask & jobMask);
            [mzVal, mzIdx] = max(dataTemp.Psd(fMask & lapMask & jobMask));
            
            data{nData}(i).Mz.MaxPower = [data{nData}(i).Mz.MaxPower; mzVal];        
            data{nData}(i).Mz.MaxFreq = [data{nData}(i).Mz.MaxFreq; mzFreq(mzIdx)];           
            data{nData}(i).Mz.Speed = [data{nData}(i).Mz.Speed; speedMz];           
            choice = dataTemp.Choice(lapMask);
            data{nData}(i).Mz.Choice = [data{nData}(i).Mz.Choice; choice(1)];      
            
            whFreq = dataTemp.Frequency(fMask & lapMask & ~jobMask);
            [whVal, whIdx] = max(dataTemp.Psd(fMask & lapMask & ~jobMask));
            
            data{nData}(i).Wh.MaxPower = [data{nData}(i).Wh.MaxPower; whVal];        
            data{nData}(i).Wh.MaxFreq = [data{nData}(i).Wh.MaxFreq; whFreq(whIdx)];           
            data{nData}(i).Wh.Speed = [data{nData}(i).Wh.Speed; speedWh];           
            choice = dataTemp.Choice(lapMask);
            data{nData}(i).Wh.Choice = [data{nData}(i).Wh.Choice; choice(1)];  
        end

    end

end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.1 - Plot max power, max freq and speed
clf
whS = [];
whP = [];
whF = [];
mzS = [];
mzP = [];
mzF = [];
save = 0;
for chc=0:1
    ttl = "Wrong choice";
    if chc
        ttl = "Right choice";
    end
    
    for nData=1:numReads
        for i=1:numSubReads
        % Mask
        cMaskMz = data{nData}(i).Mz.Choice == chc;
        cMaskWh = data{nData}(i).Wh.Choice == chc;
        
        whS = [whS; data{nData}(i).Wh.Speed(cMaskWh)];
        whP = [whP; data{nData}(i).Wh.MaxPower(cMaskWh)];
        whF = [whF; data{nData}(i).Wh.MaxFreq(cMaskWh)];
        mzS = [mzS; data{nData}(i).Mz.Speed(cMaskMz)];
        mzP = [mzP; data{nData}(i).Mz.MaxPower(cMaskMz)];
        mzF = [mzF; data{nData}(i).Mz.MaxFreq(cMaskMz)];

        end
        % Pre x Pos   
        key = "Pre";
        if nData == 2
            key = "Pos";
        end

        tittle = sprintf('Maze Max Power - %s\nMaze', ttl);
        fig = plotMaxPFS(nData, 2, 2, 1, mzS, mzP, 'k.', 'Speed', 'Max Power', tittle);
        
        tittle = sprintf('Wheel Max Power - %s\nWheel', ttl);
        fig = plotMaxPFS(nData, 2, 2, 2, whS, whP, 'r.', 'Speed', 'Max Power', tittle);
        
        tittle = sprintf('Maze Max Frequency - %s\nMaze', ttl);
        fig = plotMaxPFS(nData, 2, 2, 3, mzS, mzF, 'k.', 'Speed', 'Max Frequency', tittle);
        
        tittle = sprintf('Wheel Max Frequency- %s\nWheel', ttl);
        fig = plotMaxPFS(nData, 2, 2, 4, whS, whF, 'r.', 'Speed', 'Max Frequency', tittle);
       
        if save
            fileName = sprintf('%sMax_Power_n_Frequency_%s_%i',savePath, key, chc);
            saveas(fig,fileName, 'epsc');
            saveas(fig,fileName, 'png');
        end
    end
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.2 - Max Power and Max Frequency analytics - All_Trials_Rank_n_Ttest
save = 0;
for chc=0:1
    mzPreFreq = struct('List', [], 'Name', 'Frequency', 'Key', 'Pre', 'Job', 'Mz');
    mzPrePowe = struct('List', [], 'Name', 'Power', 'Key', 'Pre', 'Job', 'Mz');
    whPreFreq = struct('List', [], 'Name', 'Frequency', 'Key', 'Pre', 'Job', 'Wh');
    whPrePowe = struct('List', [], 'Name', 'Power', 'Key', 'Pre', 'Job', 'Wh');
    mzPosFreq = struct('List', [], 'Name', 'Frequency', 'Key', 'Pos', 'Job', 'Mz');
    mzPosPowe = struct('List', [], 'Name', 'Power', 'Key', 'Pos', 'Job', 'Mz');
    whPosFreq = struct('List', [], 'Name', 'Frequency', 'Key', 'Pos', 'Job', 'Wh');
    whPosPowe = struct('List', [], 'Name', 'Power', 'Key', 'Pos', 'Job', 'Wh');

    for i=1:numSubReads
        % Mask
        preCMaskMz = data{1}(i).Mz.Choice == chc;
        preCMaskWh = data{1}(i).Wh.Choice == chc;
        posCMaskMz = data{2}(i).Mz.Choice == chc;
        posCMaskWh = data{2}(i).Wh.Choice == chc;
        
        mzPreFreq.List = [mzPreFreq.List; data{1}(i).Mz.MaxFreq(preCMaskMz)];
        mzPrePowe.List = [mzPrePowe.List; data{1}(i).Mz.MaxPower(preCMaskMz)];
        whPreFreq.List = [whPreFreq.List; data{1}(i).Wh.MaxFreq(preCMaskWh)];
        whPrePowe.List = [whPrePowe.List; data{1}(i).Wh.MaxPower(preCMaskWh)];
        mzPosFreq.List = [mzPosFreq.List; data{2}(i).Mz.MaxFreq(posCMaskMz)];
        mzPosPowe.List = [mzPosPowe.List; data{2}(i).Mz.MaxPower(posCMaskMz)];
        whPosFreq.List = [whPosFreq.List; data{2}(i).Wh.MaxFreq(posCMaskWh)];
        whPosPowe.List = [whPosPowe.List; data{2}(i).Wh.MaxPower(posCMaskWh)];
    end

    combined = nchoosek({mzPreFreq, mzPrePowe, whPreFreq, whPrePowe, ...
        mzPosFreq, mzPosPowe, whPosFreq, whPosPowe}, 2);

    savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';

    if save
        fileID = fopen(sprintf('%sAll_Trials_Rank_n_Ttest_%i.txt', savePath, chc), 'w');
    else
        fileID = '';
    end
    for i=1:size(combined,1)
        left = combined{i,1};
        right = combined{i,2};
        aux = sprintf('\nMax %s x Max %s - %s x %s - %s x %s', left.Name, right.Name, left.Key, right.Key, left.Job, right.Job);
        perc = printStats(left.List, right.List, [3,5], aux);
        pppSave(perc, save, fileID);
    end
    if save
        fclose(fileID)
    end
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.3 - Group PSD + std
clc
save = 0;

for chc=0:1
    clf
    
    ttl = "Wrong choice";
    if chc
        ttl = "Right choice";
    end
    data = {struct('Mz', [], 'Wh', [], 'Freq', []), struct('Mz', [], 'Wh', [], 'Freq', [])}; 
    for nData=1:numReads
        nTrials = 0;
        for i=1:numSubReads
            nTrials = nTrials + length(unique(dataFull{nData, i}.Pwelch.Lap));

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
                cMask = dataTemp.Choice == chc;

                mzPsd = [mzPsd, dataTemp.Psd(lapMask & jobMask & cMask)];
                mzFrq = [mzFrq, dataTemp.Frequency(lapMask & jobMask & cMask)];
                whPsd = [whPsd, dataTemp.Psd(lapMask & ~jobMask & cMask)];
                
            end
            data{nData}.Mz = [data{nData}.Mz, mzPsd];
            data{nData}.Wh = [data{nData}.Wh, whPsd];
            data{nData}.Freq = [data{nData}.Freq, mzFrq];
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
        stdWh = std(data{nData}.Wh')/sqrt(nTrials); 
        stdMz = std(data{nData}.Mz')/sqrt(nTrials);

        plot(x, meanWh, 'r', x, meanMz, 'k')
        hold on
        plot(x, meanMz+stdMz', 'k--', x, meanMz-stdMz', 'k--')
        plot(x, meanWh+stdWh', 'r--', x, meanWh-stdWh', 'r--')
        xlim([0,12])
        ylim([0 , 50000])
        label1{1} = 'Wheel';
        label1{2} = 'Maze';
        box off
        legend(label1,'location','bestoutside','orientation','horizontal')
        legend('boxoff')
        ylabel('Power')
        xlabel('Frequency(Hz)')
        title(sprintf("Mean PSD - %s\n%s", key, ttl))
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
        fileName = sprintf('%sGroup_PSD_Pre_Pro_Std_%i',savePath, chc);
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end

clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.4 - err bar

clf
save = 0;
bands = [3,5; 6,10];
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';
for bnd=1:length(bands)
    data = {struct('MzC', [], 'WhC', [], 'MzE', [], 'WhE', [], 'Freq', []), struct('MzC', [], 'WhC', [], 'MzE', [], 'WhE', [], 'Freq', [])}; 
    clf;
    for nData=1:numReads
        nTrials = 0;
        for i=1:numSubReads
            dataTemp = dataFull{nData, i}.Pwelch;
            nTrials = nTrials + length(unique(dataTemp.Lap));
            lap = dataTemp.Lap;
            uniqueLap = unique(lap);

            mzPsdC = [];
            mzPsdE = [];
            frq = [];
            whPsdC = [];
            whPsdE = [];
            for lp=1:length(uniqueLap)

                lapMask = dataTemp.Lap == uniqueLap(lp);
                freqMask = ( dataTemp.Frequency  > bands(bnd,1) ) & ( dataTemp.Frequency  < bands(bnd,2));
                jobMask = dataTemp.Job == "Mz";
                cMask = dataTemp.Choice == 0;

                frq = [frq, dataTemp.Frequency(lapMask & jobMask & freqMask & cMask)];
                mzPsdE = [mzPsdE, dataTemp.Psd(lapMask & jobMask & freqMask & cMask)];
                whPsdE = [whPsdE, dataTemp.Psd(lapMask & ~jobMask & freqMask & cMask)];
                
                mzPsdC = [mzPsdC, dataTemp.Psd(lapMask & jobMask & freqMask & ~cMask)];
                whPsdC = [whPsdC, dataTemp.Psd(lapMask & ~jobMask & freqMask & ~cMask)];
            end
            data{nData}.MzC = [data{nData}.MzC, mzPsdC];
            data{nData}.WhC = [data{nData}.WhC, whPsdC];
            data{nData}.MzE = [data{nData}.MzE, mzPsdE];
            data{nData}.WhE = [data{nData}.WhE, whPsdE];
            data{nData}.Freq = [data{nData}.Freq, frq];
        end

        key = "Pre";
        if nData == 2
            key = "Pos";
        end

        fig = figure(1);
        fig.Position = [1 1 1600 1000];
        subplot(1,2,nData);

        x = mean(data{nData}.Freq, 2);
        meanWhC = mean(data{nData}.WhC,1);
        meanMzC = mean(data{nData}.MzC,1);
        meanWhE = mean(data{nData}.WhE,1);
        meanMzE = mean(data{nData}.MzE,1);
        % Std  
        stdWhC = std(meanWhC)/sqrt(nTrials);
        stdMzC = std(meanMzC)/sqrt(nTrials);
        stdWhE = std(meanWhE)/sqrt(nTrials);
        stdMzE = std(meanMzE)/sqrt(nTrials);

        bar([1,2,3,4], [mean(meanMzC), mean(meanMzE), mean(meanWhC), mean(meanWhE)], 'w')
        [ hMz, pMz ] = ttest2(meanMzC, meanMzE);
        [ hWh, pWh ] = ttest2(meanWhC, meanWhE);
        hold on
        errorbar([1,2,3,4], [mean(meanMzC), mean(meanMzE), mean(meanWhC), mean(meanWhE)], [stdMzC, stdMzE, stdWhC, stdWhE], 'k.')
        box off
        xticklabels(["Maze C", "Maze E", "Wheel C", "Wheel E"])
        ylabel('Power')
        xlabel('Frequency(Hz)')
        title(sprintf("Mean PSD - %s - Band: %i - %i Hz\nMaze: h: %f p: %f\nWheel: h: %f p: %f", key, bands(bnd,1), bands(bnd,2), hMz, pMz, hWh, pWh))
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
        fileName = sprintf('%sGroup_Bar_PSD_Pre_Pro_Std_%i_%i',savePath, bands(bnd,1), bands(bnd,2));
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.5 - Combined ACG

grIdx = [1, 2; 3, 4];
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';
for chc=0:1
    for nData=1:numReads
        auxMzAcgCombine = [];
        auxWhAcgCombine = [];
        for i=1:numSubReads

            dataTemp = dataFull{nData, i}.Band;
            lap = dataTemp.Lap;
            uniqueLap = unique(lap);

            for lp=1:length(uniqueLap)
                lapMask = dataTemp.Lap == uniqueLap(lp);
                mzMask = dataTemp.MzSpeed > 100;
                whMask = dataTemp.WhSpeed > 100;
                cMask = dataTemp.Choice == chc;

                LFPMz = dataTemp.Lfp(lapMask & mzMask & cMask);
                LFPWh = dataTemp.Lfp(lapMask & whMask & cMask);

                % Capture snippet
                auxAcgMz = [];
                ms = 10*srate; % Sec
                for idx=[1:ms:size(LFPMz, 1)-ms]
                    [acg, lagsMz] = xcorr(LFPMz(idx:idx+ms),'coef', 1000);    
                    auxAcgMz = [ auxAcgMz; acg ];
                end    

                auxAcgWh = [];
                for idx=[1:ms:size(LFPWh, 1)-ms]
                    [acg, lagsWh] = xcorr(LFPWh(idx:idx+ms),'coef', 1000);    
                    auxAcgWh = [ auxAcgWh; acg ];
                end

                auxMzAcgCombine = [auxMzAcgCombine; auxAcgMz];
                auxWhAcgCombine = [auxWhAcgCombine; auxAcgWh];
              
                sprintf('%d %d %i',nData, i, lp)
            end
        end
        
        ttlKey = 'Pre';
        if nData == 2
            ttlKey = 'Pos';
        end
        chcKey = 'Miss';
        if chc == 1
            chcKey = 'Hits';
        end
        % Plot
        fig = figure(chc+1);
        fig.Position = [1 1 1600 1000];
        sgtitle('Trial Combined ACG LFP')
        plotImagesc(grIdx(nData, 1), lagsMz, auxMzAcgCombine, 'Mz', ttlKey, chcKey)
        plotImagesc(grIdx(nData, 2), lagsWh, auxWhAcgCombine, 'Wh', ttlKey, chcKey)
        
 
    end
    if save
        fileName = sprintf('%sCombined_Trial_Imagesc_ACG_LFP_%s', savePath, chcKey);
        saveas(fig,fileName, 'epsc');
        saveas(fig,fileName, 'png');
    end 
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.2.6 - Trial LFP
clf
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';
for nData=1:numReads
    for i=1:dataLineCount(nData)
        
        dataTemp = dataFull{nData, i}.Pwelch.Lfp;
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        tam = length(uniqueLap);
        guide = repmat([1:1:18], 1, 5);
        
        FigList = findall(groot, 'Type', 'figure');
        for iFig = 1:numel(FigList)
            try
                clf(FigList(iFig));
            catch
                % Nothing to do
            end
        end
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            jobMask = dataTemp.Job == "Mz";
            
            key = 'Pre';
            ttl = sprintf('LFP - Pre muscimol\n%s',dataFull{nData,i}.Name(1:16));
            if nData == 2
                key = 'Pos';
                ttl = sprintf('LFP - Pos muscimol\n%s',dataFull{nData,i}.Name(1:16));
            end

            LFPMz = dataTemp.Lfp(lapMask & jobMask);
            LFPWh = dataTemp.Lfp(lapMask & ~jobMask);

            % Plot           
            if (lp <= 18)
                figA = plotLFP(1, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, 'Mz');
                figB = plotLFP(2, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPWh, 'Wh');
            elseif (lp > 18) && (lp <= 36)
                figC = plotLFP(3, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, 'Mz');
                figD = plotLFP(4, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPWh, 'Wh');
            elseif (lp > 36) && (lp <= 54)
                figE = plotLFP(5, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, 'Mz');
                figF = plotLFP(6, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPWh, 'Wh');
            elseif (lp > 54)
                figG = plotLFP(7, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, 'Mz');
                figH = plotLFP(8, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPWh, 'Wh');
            end
  
            sprintf('%d %d %i',nData, i, lp)
        end
        
        if save
            
            parts = [figA, figB];
            if exist('figC')
                parts = [parts; figC, figD];
            end
            if exist('figE')
                parts = [parts; figE, figF];
            end
            if exist('figG')
                parts = [parts; figG, figH];
            end

            for n=1:size(parts, 1)
                fileNameMZ = sprintf('%sLFP_Trial/Combined_Individual_%s_%s_LFP_MZ_PART_%i', savePath, dataFull{nData,i}.Name(1:16), key, n);
                fileNameWH = sprintf('%sLFP_Trial/Combined_Individual_%s_%s_LFP_WH_PART_%i', savePath, dataFull{nData,i}.Name(1:16), key, n);
                saveas(parts(n, 1),fileNameMZ, 'epsc');
                saveas(parts(n, 1),fileNameMZ, 'png');
                saveas(parts(n, 2),fileNameWH, 'epsc');
                saveas(parts(n, 2),fileNameWH, 'png');
            end

        end      
    end
end
clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
%% 3.2.7 - Trial PSD
clf
save = 1;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/';
for nData=1:numReads
    for i=1:dataLineCount(nData)
        
        dataTemp = dataFull{nData, i}.Pwelch;
        lap = dataTemp.Lap;
        uniqueLap = unique(lap);
        
        tam = length(uniqueLap);
        guide = repmat([1:1:18], 1, 5);
        
        FigList = findall(groot, 'Type', 'figure');
        for iFig = 1:numel(FigList)
            try
                clf(FigList(iFig));
            catch
                % Nothing to do
            end
        end
        for lp=1:length(uniqueLap)
            lapMask = dataTemp.Lap == uniqueLap(lp);
            jobMask = dataTemp.Job == "Mz";
            
            key = 'Pre';
            ttl = sprintf('PSD - Pre muscimol\n%s',dataFull{nData,i}.Name(1:16));
            if nData == 2
                key = 'Pos';
                ttl = sprintf('PSD - Pos muscimol\n%s',dataFull{nData,i}.Name(1:16));
            end

            LFPMz = dataTemp.Psd(lapMask & jobMask);
            frequ = dataTemp.Frequency(lapMask & jobMask);
            LFPWh = dataTemp.Psd(lapMask & ~jobMask);

            % Plot           
            if (lp <= 18)
                
                figA = plotPSD(1, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, LFPWh, frequ);
            elseif (lp > 18) && (lp <= 36)
                figB = plotPSD(2, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, LFPWh, frequ);
            elseif (lp > 36) && (lp <= 54)
                figC = plotPSD(3, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, LFPWh, frequ);
            elseif (lp > 54)
                figD = plotPSD(4, ttl, min(9,tam/2), guide(lp), uniqueLap(lp), LFPMz, LFPWh, frequ);
            end
  
            sprintf('%d %d %i',nData, i, lp)
        end
        
        if save
            
            parts = [figA];
            if exist('figB')
                parts = [parts; figB];
            end
            if exist('figC')
                parts = [parts; figC];
            end
            if exist('figD')
                parts = [parts; figD];
            end

            for n=1:size(parts, 1)
                fileNameMZ = sprintf('%sPSD_Trial/Combined_Individual_%s_%s_PSD_PART_%i', savePath, dataFull{nData,i}.Name(1:16), key, n);
                saveas(parts(n, 1),fileNameMZ, 'epsc');
                saveas(parts(n, 1),fileNameMZ, 'png');
            end

        end      
    end
end
clearvars -except dataFull data srate dt dataLineCount numReads numSubReads savePath
%% Teste
