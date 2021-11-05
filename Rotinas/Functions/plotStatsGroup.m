
function plotStatsGroup( leftData, rightData, dt, nData, toTitle, lLabel, rLabel, f, yInf, ySup)
    
    % Max power
    [maxLeft, idxMz] = max(leftData(dt, :));
    [maxRight, idxWh] = max(rightData(dt, :));

    peakLeft = f(dt(idxMz));
    peakRight = f(dt(idxWh));
 
    left = peakLeft';
    right = peakRight';
    % Error
    errL = std(left)/sqrt(length(left));
    errR = std(right)/sqrt(length(right));
    
%     [ht, pt, hr, pr] = calcStats(maxLeft, maxRight, normFactor);
    
    % Plot
    subplot(2,3,nData)
    plot([1,2], [left',right'], '.-')
    hold on
%     bar(1, mean(left), 'FaceColor', 'none')
%     bar(2, mean(right), 'FaceColor', 'none')
    errorbar([1,2], [median(left), median(right)], [errL, errR])
    xlim([0.5,2.5]);
    ylim([yInf, ySup]);
    xticklabels({'', lLabel, '', rLabel})
    title(toTitle)
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