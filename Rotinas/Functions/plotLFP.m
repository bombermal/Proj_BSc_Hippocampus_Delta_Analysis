function fig = plotLFP(fgNunber, tittle, gridSize, position, trialNumber, x, job)
    fig = figure(fgNunber);
    fig.Name = sprintf('%s_%i', job, fgNunber);
    sgtitle(tittle)
    fig.Position = [1 1 1000 1600];

    subplot(gridSize, 2, position);
    plot(x)
    ylabel('LFP')

%     xlim([-500,500])
    title(sprintf('Trial %i - %s', trialNumber, job))
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
        'TitleFontSizeMultiplier', 1.2,...
        'LabelFontSizeMultiplier', 0.8,...
        'XScale', 'linear') 
end