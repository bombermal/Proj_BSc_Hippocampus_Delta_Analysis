function plotFig2(fIdx, x1, y1, x2, y2, speedthresh, speedLim, xLim, yLim, ttl, xlbl, ylbl)
    subplot(2, 3, fIdx)
    
    plot(x1, y1, 'ok', 'markerfacecolor', 'k', 'markersize', 2)
    hold on
    plot(x2, y2, 'or', 'markerfacecolor', 'r', 'markersize', 2)

    plot([speedthresh, speedthresh], speedLim, 'k--')
    title(ttl)
    xlabel(xlbl)
    ylabel(ylbl)
    xlim(xLim)
    if sum(yLim) > 0
        ylim(yLim);
    end
    axis square
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Arial',...
        'TickLength', [.02 .02],...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.6,...
        'XScale', 'linear')
    
    
    subplot(2, 3, fIdx)
    coefMzAmp = polyfit(x1,  y1, 1); %calcula polinomio de primeiro grau
    coefWhAmp = polyfit(x2,  y2, 1); %calcula polinomio de primeiro grau

    plot(x1, polyval(coefMzAmp, x1),'k-','linewidth',2)
    plot(x2, polyval(coefWhAmp, x2),'r-','linewidth',2)
end