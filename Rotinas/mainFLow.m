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

order = [0; 1];
tittles = "All_Combined";
wSpeed = 100;
mSpeed = 100;

savePath = 'D:/Ivan/Downloads/ProjetoWheelMaze/Dataset/Processed/Single Files/';

processFiles = 0;
% Load files
if processFiles
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
            lapsNames(find(strcmp(lapsNames, 'WhlSpeedCW'))) = [];
            lapsNames(find(strcmp(lapsNames, 'NLapCW'))) = [];
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
            dataSingle = fillStruct(srate, WindowLength, Overlap, NFFT, dataSingle, wSpeed, mSpeed);

            Spike = dataSingle.Spike;
            Name = dataSingle.Name;
            Clu = dataSingle.Clu;  
            Lfp = dataSingle.Lfp;
            Delta = dataSingle.Delta;
            Theta = dataSingle.Theta;
            Choice = dataSingle.Choice;
            Speed = dataSingle.Speed;
            Pwelch = dataSingle.Pwelch;
            % Save
            mmtTtl = 'Pre';
            if i == 2
                mmtTtl = 'Pos';
            end

            file = sprintf('%s%s/%s/%s.mat', savePath, tittles, mmtTtl, Name);
            save(file, 'Clu', 'Spike', 'Name', 'Pwelch', 'Lfp', 'Delta', 'Theta', ...
               'Choice', 'Speed', '-v7.3')  


            sprintf('Dir: %d, File: %d', i, j)
        end
    end
end
% clearvars -except srate dt Band Clu Name Spike
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
subPath = ["All_Combined"];
idx = 1;
loadPath = sprintf('%s%s/', rootPath, subPath(idx));

% Load files
dataFull = {};
% Load Pre
absolutFilePath = ls(fullfile(sprintf('%sPre/', loadPath), '*.mat'));
for file=1:size(absolutFilePath, 1)
    fileName = absolutFilePath(file, :);
    dataFull{1, file} = load(strcat(loadPath, 'Pre\', fileName));
%     dataFull{1, file} = dataFull{1, file}.dataSingle;
    sprintf('%s - Pre - File: %d', subPath(idx), file)
end
% Load Pos
absolutFilePath = ls(fullfile(sprintf('%sPos/', loadPath), '*.mat'));
for file=1:size(absolutFilePath, 1)
    fileName = absolutFilePath(file, :);
    dataFull{2, file} = load(strcat(loadPath, 'Pos\', fileName));
%     dataFull{2, file} = dataFull{2, file}.dataSingle;
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
    
    if save
        fprintf(fileID, '\n');
    end
    
    for i=1:numSubReads
        
        dataTemp = dataFull{nData, i};
        choice = dataTemp.Choice;
        
        [count, value] = groupcounts(choice);
        
        if length(value) == 1
            if value == 0
                count = [count, 0];
                value = [value, 1];
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
fig.Position = [1 1 1600 1000];
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
        fCols = (dataTemp.Frequency >= bands(1)) & (dataTemp.Frequency <= bands(2) );
        cTrials = logical(dataTemp.Choice);
   
        auxHitMz = dataTemp.Psd.Mz(cTrials, fCols);
        auxMisMz = dataTemp.Psd.Mz(~cTrials, fCols);
        auxHitWh = dataTemp.Psd.Wh(cTrials, fCols);
        auxMisWh = dataTemp.Psd.Wh(~cTrials, fCols);
        pHits = [pHits, reshape(auxHitMz, [1, prod(size(auxHitMz))])];
        pMiss = [pMiss, reshape(auxMisMz, [1, prod(size(auxMisMz))])];
        pHits = [pHits, reshape(auxHitWh, [1, prod(size(auxHitWh))])];
        pMiss = [pMiss, reshape(auxMisWh, [1, prod(size(auxMisWh))])];

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

lOne = struct("Wh", [], "Mz", []);
lTwo = struct("MaxPower", lOne, "MaxFreq", lOne, "Speed", lOne, "Choice", []);
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
        
        speedMz = dataTemp.Speed.Mz;
        speedWh = dataTemp.Speed.Wh;

        [mzVal, mzIdx] = max(dataTemp.Psd.Mz(:, fMask)');
                
        data{nData}(i).MaxPower.Mz = mzVal';        
        data{nData}(i).MaxFreq.Mz = dataTemp.Frequency(mzIdx)';           
        data{nData}(i).Speed.Mz = speedMz;               
        data{nData}(i).Choice = dataTemp.Choice;               

        [whVal, whIdx] = max(dataTemp.Psd.Wh(:, fMask)');

        data{nData}(i).MaxPower.Wh = whVal';        
        data{nData}(i).MaxFreq.Wh = dataTemp.Frequency(whIdx)';           
        data{nData}(i).Speed.Wh = speedWh;        
    end
end
clearvars -except dataFull data srate dt numReads numSubReads savePath
%% 3.1.4 - Plot max power, max freq and speed
clf
whS = [];
whP = [];
whF = [];
mzS = [];
mzP = [];
mzF = [];
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/Max Power and Frequency/';
for chc=0:1
    ttl = "Wrong choice";
    if chc
        ttl = "Right choice";
    end
    
    for nData=1:numReads
        for i=1:numSubReads
        % Mask
        cMask = data{nData}(i).Choice == chc;
        
        whS = [whS; data{nData}(i).Speed.Wh(cMask)];
        whP = [whP; data{nData}(i).MaxPower.Wh(cMask)];
        whF = [whF; data{nData}(i).MaxFreq.Wh(cMask)];
        mzS = [mzS; data{nData}(i).Speed.Mz(cMask)];
        mzP = [mzP; data{nData}(i).MaxPower.Mz(cMask)];
        mzF = [mzF; data{nData}(i).MaxFreq.Mz(cMask)];

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
%% 3.1.5 - Max Power and Max Frequency analytics - All_Trials_Rank_n_Ttest
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
        preCMask = data{1}(i).Choice == chc;
        posCMask = data{2}(i).Choice == chc;
        
        mzPreFreq.List = [mzPreFreq.List; data{1}(i).MaxFreq.Mz(preCMask)];
        mzPrePowe.List = [mzPrePowe.List; data{1}(i).MaxPower.Mz(preCMask)];
        whPreFreq.List = [whPreFreq.List; data{1}(i).MaxFreq.Wh(preCMask)];
        whPrePowe.List = [whPrePowe.List; data{1}(i).MaxPower.Wh(preCMask)];
        mzPosFreq.List = [mzPosFreq.List; data{2}(i).MaxFreq.Mz(posCMask)];
        mzPosPowe.List = [mzPosPowe.List; data{2}(i).MaxPower.Mz(posCMask)];
        whPosFreq.List = [whPosFreq.List; data{2}(i).MaxFreq.Wh(posCMask)];
        whPosPowe.List = [whPosPowe.List; data{2}(i).MaxPower.Wh(posCMask)];
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
%% 3.1.6 - Group PSD + std
clc
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/PSD_Group/';
for chc=0:1
    clf
    
    ttl = "Wrong choice";
    if chc
        ttl = "Right choice";
    end
    data = {struct('Mz', [], 'Wh', []), struct('Mz', [], 'Wh', [])}; 
    for nData=1:numReads
        nTrials = 0;
        for i=1:numSubReads
            nTrials = nTrials + size(dataFull{nData, i}.Choice, 1);

            dataTemp = dataFull{nData, i}.Pwelch;

            mzPsd = [];
            mzFrq = [];
            whPsd = [];
            whFrq = [];
       
            cMask = dataTemp.Choice == chc;
            
            data{nData}.Mz = [data{nData}.Mz; dataTemp.Psd.Mz(cMask, :)];
            data{nData}.Wh = [data{nData}.Wh; dataTemp.Psd.Wh(cMask, :)];
        end

        key = "Pre";
        if nData == 2
            key = "Pos";
        end

        fig = figure(1);
        fig.Position = [1 1 1600 1000];
        subplot(1,2,nData);

        x = dataTemp.Frequency;
        meanWh = mean(data{nData}.Wh);
        meanMz = mean(data{nData}.Mz);
        % Std  
        stdWh = std(data{nData}.Wh)/sqrt(nTrials); 
        stdMz = std(data{nData}.Mz)/sqrt(nTrials);

        plot(x, meanWh, 'r', x, meanMz, 'k')
        hold on
        plot(x, meanMz+stdMz, 'k--', x, meanMz-stdMz, 'k--')
        plot(x, meanWh+stdWh, 'r--', x, meanWh-stdWh, 'r--')
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
%% 3.1.7 - err bar

clf
save = 0;
bands = [3,5; 6,10];
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/Bar/';
for bnd=1:length(bands)
    data = {struct('MzC', [], 'WhC', [], 'MzE', [], 'WhE', [], 'Freq', []), struct('MzC', [], 'WhC', [], 'MzE', [], 'WhE', [], 'Freq', [])}; 
    clf;
    for nData=1:numReads
        nTrials = 0;
        for i=1:numSubReads
            dataTemp = dataFull{nData, i}.Pwelch;
            nTrials = nTrials + size(dataFull{nData, i}.Choice, 1);

            mzPsdC = [];
            mzPsdE = [];
            frq = [];
            whPsdC = [];
            whPsdE = [];

            fMask = ( dataTemp.Frequency  > bands(bnd,1) ) & ( dataTemp.Frequency  < bands(bnd,2));
            cMask = dataTemp.Choice == 0;

            data{nData}.MzC = [data{nData}.MzC; dataTemp.Psd.Mz(~cMask, fMask)];
            data{nData}.WhC = [data{nData}.WhC; dataTemp.Psd.Wh(~cMask, fMask)];
            data{nData}.MzE = [data{nData}.MzE; dataTemp.Psd.Mz(cMask, fMask)];
            data{nData}.WhE = [data{nData}.WhE; dataTemp.Psd.Wh(cMask, fMask)];
        end

        key = "Pre";
        if nData == 2
            key = "Pos";
        end

        fig = figure(1);
        fig.Position = [1 1 1600 1000];
        subplot(1,2,nData);

        x = mean(data{nData}.Freq, 2);
        meanWhC = mean(data{nData}.WhC,2);
        meanMzC = mean(data{nData}.MzC,2);
        meanWhE = mean(data{nData}.WhE,2);
        meanMzE = mean(data{nData}.MzE,2);
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
        ylim([0,25000])
        if bnd == 1
            ylim([0,15000])
        end
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
%% 3.1.8 - Combined ACG

grIdx = [1, 2; 3, 4];
save = 0;
savePath = 'H:/.shortcut-targets-by-id/1Nli00DbOZhrqcakOcUuK8zlw9yPtuH6_/ProjetoWheelMaze/Resultados/EPS Ivan/Ultima abordagem(Flow - Trial)/ACG/';

for nData=1:numReads
    auxMzAcgCombine = [];
    auxWhAcgCombine = [];
    for i=1:numSubReads
        dataTemp = dataFull{nData, i};
        
        laps = size(dataTemp.Choice, 1);
        for lp=1:laps

            mzMask = dataTemp.Speed.Mz{lp} > 100;
            whMask = dataTemp.Speed.Wh{lp} > 100;

            LFPMz = dataTemp.Theta.Band{lp}(mzMask);
            LFPWh = dataTemp.Theta.Band{lp}(whMask);

            % Capture snippet
            [acgMz, lagsMz] = xcorr(LFPMz','coef', 1000);    
            [acgWh, lagsWh] = xcorr(LFPWh','coef', 1000);    

            auxMzAcgCombine = [auxMzAcgCombine, acgMz];
            auxWhAcgCombine = [auxWhAcgCombine, acgWh];

            sprintf('%d %d %i',nData, i, lp)
        end
    end

    ttlKey = 'Pre';
    if nData == 2
        ttlKey = 'Pos';
    end

    % Plot
    fig = figure(1);
    fig.Position = [1 1 1600 1000];
    sgtitle('Trial Combined ACG LFP')
    yyaxis left
    plotImagesc(grIdx(nData, 1), lagsMz, auxMzAcgCombine', 'Mz', ttlKey)
    hold on
    val = size(auxMzAcgCombine, 1)/2;
    xLimValue = -val:val-1;
    
    yyaxis right
    plot(xLimValue, mean(auxMzAcgCombine, 2), 'w')
    yyaxis left
    plotImagesc(grIdx(nData, 2), lagsWh, auxWhAcgCombine', 'Wh', ttlKey)
    yyaxis right
    plot(xLimValue, mean(auxMzAcgCombine, 2), 'w')
end
if save
    fileName = sprintf('%sCombined_Trial_Imagesc_ACG_LFP_Theta', savePath);
    saveas(fig,fileName, 'epsc');
    saveas(fig,fileName, 'png');
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

plot(dataFull{1,1}.Pwelch.Mz.Frequency, dataFull{1,1}.Pwelch.Mz.Psd(1:3, 1:end)')
xlim([0,12])