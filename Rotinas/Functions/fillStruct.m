function data = fillStruct(srate, WindowLength, Overlap, NFFT, data, wSpeed, mSpeed, delta, theta)
    dt = 1/srate;     
    % Lap
    lap = data.Track.lapID;
    if delta || theta
        lapMask = lap > 0;
        eeg = data.Track.eeg(lapMask);
        cChoice = data.Track.corrChoice(lapMask);
        lfpMzSpeed =  data.Track.speed_MMsec(lapMask);
        lfpWhSpeed = (data.Laps.WhlSpeedCW(lapMask) + data.Laps.WhlSpeedCCW(lapMask));
        
        if delta
            % add Bands
            [band, amp, pha, fre] = ampPhaFreq(eeg',srate,dt,3,5, 1, 1);
            data.Band = struct('Lfp', eeg, 'Delta', band', 'Amplitude', amp', 'Phase', pha',...
                'InstFreq', fre', 'Lap', lap(lapMask), 'Choice', cChoice, 'MzSpeed', lfpMzSpeed, 'WhSpeed', lfpWhSpeed);
        else
            [band, amp, pha, fre] = ampPhaFreq(eeg',srate,dt,6,10, 1, 1);
            data.Band = struct('Lfp', eeg, 'Theta', band', 'Amplitude', amp', 'Phase', pha',...
                'InstFreq', fre', 'Lap', lap(lapMask), 'Choice', cChoice, 'MzSpeed', lfpMzSpeed, 'WhSpeed', lfpWhSpeed);
        end
     else
        jobList = ["Mz", "Wh"];

        freAux = [];
        psdAux = [];
        choAux = [];
        lapAux = [];
        jobAux = [];
        mzSAux = [];
        whSAux = [];

        lapUnique = unique(lap);
        for lp=1:length(lapUnique)
            if lapUnique(lp) ~= 0
                lapMask = lap == lapUnique(lp);
                for jb=1:length(jobList)
                    if jobList(jb) == "Mz"
                        speedMask = data.Track.speed_MMsec(lapMask) > mSpeed;
                        mzAux = mean(find(speedMask));
                        whAux = 0;
                    else
                        speedMask = (data.Laps.WhlSpeedCW(lapMask) + data.Laps.WhlSpeedCCW(lapMask)) > wSpeed;
                        mzAux = 0;
                        whAux = mean(find(speedMask));
                    end

                    cChoice = data.Track.corrChoice(lapMask);
                    cChoice = cChoice(speedMask);
                    eeg = data.Track.eeg(lapMask);

                    [psd, frq] = pwelch(eeg(speedMask),WindowLength,Overlap,NFFT,srate);
                    freAux = [freAux; frq];
                    psdAux = [psdAux; psd];
                    
                    lapAux = [lapAux; repmat(lp,length(frq),1)];      
                    jobAux = [jobAux; repmat(jobList(jb),length(frq),1)];            
                    choAux = [choAux; repmat(cChoice(1),length(frq),1)];
                    mzSAux = [mzSAux; repmat(mzAux,length(frq),1)];
                    whSAux = [whSAux; repmat(whAux,length(frq),1)];
                end
            end
        end
    end

    if ~(delta || theta)
        data.Pwelch.Frequency = freAux;
        data.Pwelch.Psd = psdAux;
        data.Pwelch.Lap = lapAux;
        data.Pwelch.Choice = choAux;
        data.Pwelch.Job = jobAux;
        data.Pwelch.MzSpeedMean = mzSAux;
        data.Pwelch.WhSpeedMean = whSAux;
    end
end