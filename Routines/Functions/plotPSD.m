function fig = plotPSD(x, vY1, vY2, y1Trials, y2Trials, labls, ttl, colors, lw, yLim, xLim, ...
    yLabel, xLabel, sqr)
    
    y1 = mean(vY1);
    y2 = mean(vY2);
    % Std  
    std1 = std(vY1)/sqrt(y1Trials); 
    std2 = std(vY2)/sqrt(y2Trials);
    
    plot(x, y1, colors(1), x, y2, colors(2), 'linewidth', lw)
    hold on
    plot(x, y1+std1, [colors(1),'--'], x, y1-std1, [colors(1),'--'])
    plot(x, y2+std2, [colors(2),'--'], x, y2-std2, [colors(2),'--'])
    xlim(xLim)
    if sum(yLim) > 0
        ylim(yLim)
    end
    title(ttl)
    
    label1{1} = labls(1);
    label1{2} = labls(2);
    box off
    legend(label1,'location','northwest')
    legend('boxoff')
    ylabel(yLabel)
    xlabel(xLabel)
    if sqr
        axis square
    end
    set(gca, ...
        'Box',      'off')
end