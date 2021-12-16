function plotImagesc(idx, lags, combine, key, ttlKey)
%     subplot(2,2,idx);
    imagesc(lags, [1:size(combine, 1)], combine)
%     colorbar()
%     caxis([-0.5, 1])
    ylabel('Trial')
    xlabel('Lag(ms)')
    xlim([-500,500])
    title(sprintf('%s %s', key, ttlKey))
end