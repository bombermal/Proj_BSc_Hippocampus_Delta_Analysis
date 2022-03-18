function plotImagesc(lags, combine, xLimValue, ttlKey, xLim, yLabel, xLabel, cBar, cLim, sm, sqr)
    
    yyaxis left
    imagesc(lags, [1:size(combine, 1)], combine)
    ylabel(yLabel)
    xlabel(xLabel)
    if sum(xLim) > 0
       xlim(xLim)
    end
    if cBar
        colorbar()
    end
    if sum(cLim) > 0
        caxis(cLim)
    end
    hold on
    
    yyaxis right
    if sm > 0
       plot(xLimValue,smooth(mean(combine),sm),'w', 'LineWidth',1.5)
    else
       plot(xLimValue,mean(combine),'w', 'LineWidth',1.5) 
    end
    box off
    hold off
    if sqr
        axis square
    end
    title(ttlKey)
%     set(gca, ...
%     'Box',      'off',...
%     'Fontname', 'Arial',...
%     'Fontsize', 18)
end