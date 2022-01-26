function resp = getPeakVal(dataPeak, freqMask)
    [~, idxMz] = max(dataPeak);
    resp = freqMask(idxMz);
end