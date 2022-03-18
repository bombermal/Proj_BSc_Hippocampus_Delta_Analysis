function fig = plotPSD(x, vY, yTrials, labls, ttl, colors, lw, yLim, xLim, ...
    yLabel, xLabel, sqr)
    
    loopSize = size(vY, 2);
    y = {};
    stds = {};
    for i=1:loopSize
        y{i} = mean(vY{i});  
    
        % Std  
        stds{i} = std(vY{i})/sqrt(yTrials(i));
        
        plot(x, y{i}, colors(i), 'linewidth', lw)
        hold on
        labels{i} = labls(i);
    end

    for i=1:loopSize
        plot(x, y{i}+stds{i}, [colors(i),'--'], x, y{i}-stds{i}, [colors(i),'--'])
    end
    hold off

    xlim(xLim)
    if ~isempty(yLim)
        ylim(yLim)
    end
    title(ttl)
    
    box off
    legend(labels,'location','northwest')
    legend('boxoff')
    ylabel(yLabel)
    xlabel(xLabel)
    
    if sqr
        axis square
    end
    set(gca, ...
        'Box',      'off')%,...
        %'Fontname', 'Arial',...
        %'Fontsize', 18)
end