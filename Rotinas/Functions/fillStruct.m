function data = fillStruct(key, srate, WindowLength, Overlap, NFFT, data, wSpeed, mSpeed)
    jobList = ["Mz", "Wh"];
    % Lap
    lap = data.Track.lapID;

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
                eeg = data.Track.eeg(lapMask);

                [psd, frq] = pwelch(eeg(speedMask),WindowLength,Overlap,NFFT,srate);
                freAux = [freAux; frq];
                psdAux = [psdAux; psd];
                lapAux = [lapAux; repmat(lp,length(frq),1)];      
                jobAux = [jobAux; repmat(jobList(jb),length(frq),1)];            
                choAux = [choAux; repmat(mean(cChoice(speedMask)),length(frq),1)];
                mzSAux = [mzSAux; repmat(mzAux,length(frq),1)];
                whSAux = [whSAux; repmat(whAux,length(frq),1)];
                
            end
        end
    end

    data.Pwelch.Frequency = freAux;
    data.Pwelch.Psd = psdAux;
    data.Pwelch.Momment = repmat(key,length(freAux),1);
    data.Pwelch.Lap = lapAux;
    data.Pwelch.Choice = choAux;
    data.Pwelch.Job = jobAux;
    data.Pwelch.Animal = repmat(data.Name(1:13),length(freAux),1);
    data.Pwelch.MzSpeedMean = mzSAux;
    data.Pwelch.WhSpeedMean = whSAux;
end