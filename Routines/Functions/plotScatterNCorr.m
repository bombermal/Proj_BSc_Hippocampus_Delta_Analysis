function plotScatterNCorr(x1, y1, x2, y2, speedthresh, speedLim, xLim, yLim, ttl, xlbl, ylbl, mrkSize)
    plot(x1, y1, 'ok', 'markerfacecolor', 'k', 'markersize', mrkSize)
    hold on
    plot(x2, y2, 'or', 'markerfacecolor', 'r', 'markersize', mrkSize)
    % Speed treshold line
    if ~isempty(speedthresh)
        plot([speedthresh, speedthresh], speedLim, 'k--')
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

    plot(x1, polyval(coefMzAmp, x1),'k-','linewidth',2)
    plot(x2, polyval(coefWhAmp, x2),'r-','linewidth',2)
    hold off
end
