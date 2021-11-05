function fig = plotPSDWhxMz(fIdx,x, dt1, dt2, dt1T, dt2T, labls, key)
    subplot(2,2,fIdx);
    
    y1 = mean(dt1);
    y2 = mean(dt2);
    % Std  
    std1 = std(dt1)/sqrt(dt1T); 
    std2 = std(dt2)/sqrt(dt2T);
    
    plot(x, y1, 'g', 'linewidth', 2)
    hold on
    plot(x, y2, 'b', 'linewidth', 2)
    plot(x, y1+std1, 'g--')
    plot(x, y1-std1, 'g--')
    plot(x, y2+std2, 'b--')
    plot(x, y2-std2, 'b--')
    xlim([0,12])
    ylim([0 , 50000])
    title(sprintf('%s x %s - %s', labls(1), labls(2), key))
    
    label1{1} = sprintf('%s Choice', labls(1));
    label1{2} = sprintf('%s Choice', labls(2));
    box off
    legend(label1,'location','bestoutside','orientation','horizontal')
    legend('boxoff')
    ylabel('Power')
    xlabel('Frequency(Hz)')
    axis square
    set(gca, ...
        'Box',      'off',...
        'FontName', 'Arial',...
        'TickLength', [.02 .02],...
        'XColor',    [.3 .3 .3],...
        'YColor',    [.3 .3 .3],...
        'LineWidth', 1,...
        'FontSize', 8, ...
        'TitleFontSizeMultiplier', 1.6,...
        'LabelFontSizeMultiplier', 1.6,...
        'XScale', 'linear')
end