function [perc, power, peak] = printStats( leftData, rightData, dt, bands, i, f, ex, paired)
    sumTempMz = sum(leftData(dt, :), 1);
    sumTempWh = sum(rightData(dt, :), 1);
    
    normFactor = mean([sumTempMz; sumTempWh]);
    
    [ht, pt, hr, pr] = calcStats(sumTempMz, sumTempWh, normFactor, paired);

    perc = sprintf('\n%s\nBand: %i Hz-%i Hz Norm Factor\nTtest h: %f - p: %f\nSignRank h: %f - p: %f', ex, bands(i,1), bands(i,2), ht, pt, hr, pr)

    [maxPowerMz, idxMz] = max(leftData(dt, :));
    [maxPowerWh, idxWh] = max(rightData(dt, :));

    normFactor = mean([maxPowerMz; maxPowerWh]);

    [ht, pt, hr, pr] = calcStats(maxPowerMz, maxPowerWh, normFactor, paired);

    power = sprintf('\n%s\nBand: %i Hz-%i Hz MAX POWER\nTtest h: %f - p: %f\nSignRank h: %f - p: %f', ex, bands(i,1), bands(i,2), ht, pt, hr, pr)

    peakFreqMz = f(dt(idxMz));
    peakFreqWh = f(dt(idxWh));

    [ht, pt, hr, pr] = calcStats(peakFreqMz, peakFreqWh, 1, paired);
    peak = sprintf('\n%s\nBand: %i Hz-%i Hz PEAK FREQ\nTtest h: %f - p: %f\nSignRank h: %f - p: %f\n--------------------------\n', ex, bands(i,1), bands(i,2), ht, pt, hr, pr)  
end