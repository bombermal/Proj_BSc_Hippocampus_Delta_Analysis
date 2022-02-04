function plotScatterNCorr(x1, y1, x2, y2, colors, speedthresh, speedLim, xLim, yLim, ttl, xlbl, ylbl, mrkSize)
    plot(x1, y1, sprintf('o%s', colors(1)), 'markerfacecolor', colors(1), 'markersize', mrkSize)
    hold on
    plot(x2, y2, sprintf('o%s', colors(2)), 'markerfacecolor', colors(2), 'markersize', mrkSize)
    % Speed treshold line
    if ~isempty(speedthresh)
        plot([speedthresh, speedthresh], speedLim, sprintf('%s--', colors(1)))
    end
    title(ttl)
    xlabel(xlbl)
    ylabel(ylbl)
    
    if ~isempty(xLim)
        xlim(xLim);
    end
    if ~isempty(yLim)
        ylim(yLim);
    end
   
    coefMzAmp = polyfit(x1,  y1, 1); 
    coefWhAmp = polyfit(x2,  y2, 1);

    plot(x1, polyval(coefMzAmp, x1), sprintf('%s-', colors(1)), 'linewidth', mrkSize)
    plot(x2, polyval(coefWhAmp, x2), sprintf('%s-', colors(2)), 'linewidth', mrkSize)
    hold off
end
