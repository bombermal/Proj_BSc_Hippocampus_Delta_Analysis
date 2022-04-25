function plotHistogram(data, bins, colors, ttl, lgnd, yLabel, xLabel, sqr, fontSz)

    if size(data, 1) == 1
        histogram(data, bins, 'FaceColor', colors)
    else
        for i=1:size(data, 1)
            histogram(data{i}, bins(i, :), 'FaceColor', colors(i))
            hold on
        end
        hold off
    end
    
    if ~isempty(ttl)
        title(ttl)
    end
    if ~isempty(yLabel)
        ylabel(yLabel)
    end
    if ~isempty(xLabel)
        xlabel(xLabel)
    end
    if ~isempty(sqr)
        axis square
    end
    if ~isempty(lgnd)
        legend(lgnd)
    end
    
    set(gca, 'Box', 'off')
    if fontSz
        set(gca, 'Fontname', 'Arial', ...
            'Fontsize', 18)
    end
end