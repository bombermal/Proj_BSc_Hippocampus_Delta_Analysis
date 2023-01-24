function [band, amp, pha, fre] = ampPhaFreq(lfp,srate,dt,low,high, angleUwnrap, freUwnrap)
    band = eegfilt2(lfp,srate,low,high);        % Filter band between low-high(eg. 1-4)
    
    amp = abs(hilbert(band));                   % Amplitude
    
    if angleUwnrap
        pha = unwrap(angle(hilbert(band)));     % Phase
    else
        pha = angle(hilbert(band)); 
    end
    
    if freUwnrap
        fre = diff(unwrap(pha))/(2*pi)/dt;  
        fre = [fre, fre(end)];
    else
        fre = diff(pha)/(2*pi)/dt;             % Instantaneus frequency
        fre = [fre, fre(end)];
    end
end