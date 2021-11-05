function data = fillStruct(srate, WindowLength, Overlap, NFFT, data, wSpeed, mSpeed)
    dt = 1/srate;     
    % Trial
    lap = data.Track.lapID;
    lapUnique = unique(lap);
    lapUnique = lapUnique(lapUnique > 0);
    lfpCell = {};
    choiceArray = [];
    mzCell = {};
    whCell = {};
    bandCellD = {};
    ampCellD = {};
    phaCellD = {};
    freCellD = {};
    bandCellT = {};
    ampCellT = {};
    phaCellT = {};
    freCellT = {};

    eeg = data.Track.eeg;

    [bandD, ampD, phaD, freD] = ampPhaFreq(eeg',srate,dt,3,5, 1, 1);
    [bandT, ampT, phaT, freT] = ampPhaFreq(eeg',srate,dt,6,10, 1, 1);

    for tr=1:length(lapUnique)
        trialMask = lap == lapUnique(tr);
        cChoice = data.Track.corrChoice(trialMask);

        lfpCell{tr} = data.Track.eeg(trialMask);   
        choiceArray = [choiceArray; cChoice(1)];
        mzCell{tr} = data.Track.speed_MMsec(trialMask);
        whCell{tr} = data.Laps.WhlSpeedCW(trialMask);
        bandCellD{tr} = bandD(trialMask);
        ampCellD{tr} = ampD(trialMask);
        phaCellD{tr} = phaD(trialMask);
        freCellD{tr} = freD(trialMask);
        bandCellT{tr} = bandT(trialMask);
        ampCellT{tr} = ampT(trialMask);
        phaCellT{tr} = phaT(trialMask);
        freCellT{tr} = freT(trialMask);

        data.Lfp = lfpCell';
        data.Delta.Band = bandCellD';
        data.Theta.Band = bandCellT';
        data.Delta.Amplitude = ampCellD';
        data.Theta.Amplitude = ampCellT';
        data.Delta.Phase = phaCellD';
        data.Theta.Phase = phaCellT';
        data.Delta.InstFreq= freCellD';
        data.Theta.InstFreq = freCellT';
        data.Choice = choiceArray;
        data.Speed.Mz = mzCell';
        data.Speed.Wh = whCell';
    end    

    psdAuxMz = [];
    choAuxMz = [];
    psdAuxWh = [];
    choAuxWh = [];
    mzSpeedAux = [];
    whSpeedAux = [];

    for lp=1:length(lapUnique)
        lapMask = lap == lapUnique(lp);

        speedMaskMz = data.Track.speed_MMsec(lapMask) > mSpeed;
        mzAux = mean(find(speedMaskMz));

        speedMaskWh = data.Laps.WhlSpeedCW(lapMask) > wSpeed;
        whAux = mean(find(speedMaskWh));

        cChoice = data.Track.corrChoice(lapMask);
        eeg = data.Track.eeg(lapMask);

        % Mz
        [psd, frq] = pwelch(eeg(speedMaskMz)',WindowLength,Overlap,NFFT,srate);
        psdAuxMz = [psdAuxMz, psd];      
        choAuxMz = [choAuxMz, cChoice(1)];
        mzSpeedAux = [mzSpeedAux, mzAux];              

        % Wh
        [psd, frq] = pwelch(eeg(speedMaskWh)',WindowLength,Overlap,NFFT,srate);
        psdAuxWh = [psdAuxWh, psd];      
        whSpeedAux = [whSpeedAux, whAux]; 
    end

    data.Pwelch.Choice = choAuxMz';        
    data.Pwelch.Frequency = frq';
    data.Pwelch.Psd.Mz = psdAuxMz';
    data.Pwelch.Psd.Wh = psdAuxWh';
    data.Pwelch.Speed.Mz = mzSpeedAux';
    data.Pwelch.Speed.Wh = whSpeedAux';
end