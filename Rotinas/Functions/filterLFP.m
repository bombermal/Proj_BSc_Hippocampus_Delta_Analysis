function data = filterLFP(data, srate)
    %LFP
    LFP = eegfilt2(data.Track.origEeg', srate, 55,65, 0, [],1);
    
    % Fix LFP
    if data.Name(1:4) == 'A943'
        % Mean and Std from LFP
        stdLFP = std(LFP);
        meanLFP = mean(LFP, 2);
    
        % Calc inf. and Sup. limits for cut
        nStds = 2;

        limInfLFP = meanLFP-(nStds*stdLFP);
        limSupLFP = meanLFP+(nStds*stdLFP);

        % Take more values at side of each cutted value
        cutSize = 5;
        indexValues = find(LFP <= limInfLFP | LFP >= limSupLFP);
        auxLFP = zeros(1, size(indexValues, 2)*11);
        cont = 1;
        for i=indexValues
            auxLFP(cont:cont+4) = [i-cutSize:1:i-1];
            auxLFP(cont+5:cont+10) = [i:1:i+cutSize];
            cont = cont+11;
        end
        
        % Index with all cutted values
        auxLFP = unique(auxLFP);
        % Create a logical index, for easy application
        indexLogic = zeros(1, size(LFP,2));
        indexLogic(auxLFP) = 1;
        indexLogic = logical(indexLogic);

        % Filter index
        data.Track.eeg = LFP(~indexLogic)'; % Not cutted LFP values
        data.Track.speed_MMsec = data.Track.speed_MMsec(~indexLogic);
        data.Track.corrChoice = data.Track.corrChoice(~indexLogic);
        data.Track.lapID = data.Track.lapID(~indexLogic);
        data.Laps.WhlSpeedCW = data.Laps.WhlSpeedCW(~indexLogic);
    else 
        data.Track.eeg = LFP';
    end
end