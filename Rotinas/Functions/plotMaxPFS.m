function fig = plotMaxPFS(fg, row, col, idx, x, y, color, xLabel, yLabel, ttl)
    fig = figure(fg);
    fig.Position = [1 1 1600 1000];
    subplot(row,col,idx)
    plot(x, y, color)
    [r, p] = corr(x,y);
    xlabel(xLabel)
    ylabel(yLabel)
    title(sprintf('%s R: %.4f P: %.4f', ttl, r, p))
    % Aesthetics
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Helvetica',...
        'TickDir',  'out', ...
        'TickLength', [.02 .02],...
        'YGrid',     'on',...
        'GridLineStyle', '-.',...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'FontWeight', 'bold',...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.4,...
        'XScale', 'linear')
end