function perc = printStats( leftData, rightData, bands, title)
    
    [ht, pt, hr, pr] = calcStats(leftData, rightData);

    perc = sprintf('\n%s\nBand: %i Hz-%i Hz\nTtest h: %f - p: %f\nRankSum h: %f - p: %f', title, bands(1), bands(2), ht, pt, hr, pr)
        
end