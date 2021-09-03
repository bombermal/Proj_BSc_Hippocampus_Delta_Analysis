function plotImagesc(idx, lags, combine, key, ttlKey, chcKey)
    subplot(2,2,idx);
    imagesc(lags, [1:size(combine', 1)], combine')
    ylabel('Time(s)')
    xlabel('Lag(ms)')
    xlim([-500,500])
    title(sprintf('%s %s - %s', key, ttlKey, chcKey))
end