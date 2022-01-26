function plotScatterNCorr(x1, y1, x2, y2, speedthresh, speedLim, xLim, yLim, ttl, xlbl, ylbl, mrkSize)
    % /10, convert mm/sec to cm/sec
    plot(x1, y1, 'ok', 'markerfacecolor', 'k', 'markersize', mrkSize)
    hold on
    plot(x2, y2, 'or', 'markerfacecolor', 'r', 'markersize', mrkSize)
    % Speed treshold line
    plot([speedthresh, speedthresh], speedLim, 'k--')
    title(ttl)
    xlabel(xlbl)
    ylabel(ylbl)
    xlim(xLim)
    if sum(yLim) > 0
        ylim(yLim);
    end
   
    coefMzAmp = polyfit(x1,  y1, 1); 
    coefWhAmp = polyfit(x2,  y2, 1);

    plot(x1, polyval(coefMzAmp, x1),'k-','linewidth',2)
    plot(x2, polyval(coefWhAmp, x2),'r-','linewidth',2)
    hold off
end
