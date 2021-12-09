function plotAcgSpk(yVal, value, dataUnorm, sm, PREPOS, ttl)
    % axis values
    xHalf = floor(size(yVal,2)/2);
    xVal = -xHalf:10:xHalf;
    % Plot
    lim = find(mean(yVal,2)>value);
    yyaxis left
    imagesc(xVal, [1:size(zscore(yVal(lim,:),[],2), 1)], zscore(yVal(lim,:),[],2))
    ylabel 'Neuron (#)'
    caxis([-1 3])
    colorbar()
    yyaxis right
    % hold on
    plot(dataUnorm{PREPOS}.AcgLags,smooth(mean(zscore(yVal(lim,:),[],2)),sm),'w', 'LineWidth',1.5)
    title(ttl)
    xlabel 'Lag (ms)'
    ylabel 'Autocorrelogram'
    box off
    axis square
end