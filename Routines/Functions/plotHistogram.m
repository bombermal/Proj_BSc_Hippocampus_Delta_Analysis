function plotHistogram(data, bins, xLabel, ttl, clrs)
    if length(data) == 1
        histogram(data, bins)
    else
        for i=1:length(data)
            histogram(data(i), bins(1))
            hold on
        end
        hold off
    end
%     resp = struct('Y', [], 'Tags', []);
%     for tg=1:size(dataTags, 2)
%         sz = length(dataCell{tg});
%         resp.Y = [ resp.Y, dataCell{tg}];
%         resp.Tags = [ resp.Tags, repmat(dataTags(tg), 1, sz)];
%     end
%     
%     if isempty(clrs)
%         boxplot(resp.Y, resp.Tags)
%     else
%         boxplot(resp.Y, resp.Tags, "Colors", clrs)
%     end
% 
%     if ~isempty(yLabel)
%         ylabel(yLabel)
%     end
%     if ~isempty(xLabel)
%         xlabel(xLabel)
%     end
%     if ~isempty(ttl)
%         title(ttl)
%     end
    
    set(gca, 'Box', 'off')
    
end