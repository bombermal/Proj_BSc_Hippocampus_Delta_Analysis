function data = fillStruct(dt, srate, WindowLength, Overlap, NFFT, data, wSpeed, mSpeed, delta, theta, pwlc)
    %LFP
    LFP = data.Track.eeg';  
    
    %Avrg run and maze 
    whSpeed = data.Laps.WhlSpeedCW+data.Laps.WhlSpeedCCW;
    mzSpeed = data.Track.speed_MMsec;
    whIdx = find(whSpeed>wSpeed);
    mzIdx = find(mzSpeed>mSpeed);

    % Store filtered idx of speed
    data.Laps.WhIdx = whIdx;
    data.Laps.MzIdx = mzIdx;
    data.Laps.WhSpeed = whSpeed;
    
    % Fix LFP
    LFPWh = LFP(whIdx);
    LFPMz = LFP(mzIdx);
    data.Track.LFPWh = LFPWh;
    data.Track.LFPMz = LFPMz;
    
    data.Bands.InstSpeedWh = whSpeed(whIdx);
    data.Bands.InstSpeedMz = mzSpeed(mzIdx);  
    
    if delta || theta
       %Timevector
        data.timeVector = dt:dt:length(LFP)/srate;
        %Delta
        if delta
            [data.Bands.Delta, data.Bands.DeltaAmp, data.Bands.DeltaPha, data.Bands.DeltaFre] = ampPhaFreq(LFP,srate,dt,3,5,false,true);

            deltaInst = diff(unwrap(angle(hilbert(data.Bands.Delta))))/(2*pi)/dt;

            data.Bands.InstDeltaMz = deltaInst(mzIdx);
            data.Bands.InstDeltaWh = deltaInst(whIdx);
            data.Bands.AmpDeltaMz = data.Bands.DeltaAmp(mzIdx);
            data.Bands.AmpDeltaWh = data.Bands.DeltaAmp(whIdx);
           
        end
        if theta
            [data.Bands.Theta, data.Bands.ThetaAmp, data.Bands.ThetaPha, data.Bands.ThetaFre] = ampPhaFreq(LFP,srate,dt,6,10,false,true);
            
            % Power Spectral Density
            thetaInst = diff(unwrap(angle(hilbert(data.Bands.Theta))))/(2*pi)/dt;

            data.Bands.InstThetaMz = thetaInst(mzIdx);
            data.Bands.InstThetaWh = thetaInst(whIdx);
            data.Bands.AmpThetaMz = data.Bands.ThetaAmp(mzIdx);
            data.Bands.AmpThetaWh = data.Bands.ThetaAmp(whIdx);        
        end
    end
    if pwlc
        [data.Pwelch.Px_wh, data.Pwelch.F] = pwelch(LFPWh,WindowLength,Overlap,NFFT,srate);
        [data.Pwelch.Px_mz, data.Pwelch.F] = pwelch(LFPMz,WindowLength,Overlap,NFFT,srate);
    end
   
end