function plotBoxPlot(dataCell, dataTags, yLabel, xLabel, ttl, clrs)
    resp = struct('Y', [], 'Tags', []);
    for tg=1:size(dataTags, 2)
        sz = length(dataCell{tg});
        resp.Y = [ resp.Y, dataCell{tg}];
        resp.Tags = [ resp.Tags, repmat(dataTags(tg), 1, sz)];
    end
    
    if isempty(clrs)
        boxplot(resp.Y, resp.Tags)
    else
        boxplot(resp.Y, resp.Tags, "Colors", clrs)
    end

    if ~isempty(yLabel)
        ylabel(yLabel)
    end
    if ~isempty(xLabel)
        xlabel(xLabel)
    end
    if ~isempty(ttl)
        title(ttl)
    end
    
    set(gca, ...
        'Box',      'off')%,...
%         'Fontname', 'Arial',...
%         'Fontsize', 18)
    
end