function resp = getPeakVal(dataPeak, freqMask)
    % Peak Freqyency
    [~, idxMz] = max(dataPeak);
    resp = freqMask(idxMz);
end