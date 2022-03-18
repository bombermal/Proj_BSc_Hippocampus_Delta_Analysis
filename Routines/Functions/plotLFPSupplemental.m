function plotLFPSupplemental(tempData, file, band, whMz, speed, xLim)
    % Plot Band
    % Without momment selection
    if whMz == "None"
        % Plot LFP
        plot(tempData.Lfp{file}, 'k')
        xlim(xLim)
        hold on
        if band == "Delta"
            plot(tempData.Delta.Band{file}, 'c', 'LineWidth', 2)
        else
            plot(tempData.Theta.Band{file}, 'c', 'LineWidth', 2)
        end
    else
        % With momment selection
        if whMz == "Wh"
            movSpeed = tempData.Speed.Wh{file} > speed;
            % Plot LFP
            plot(tempData.Lfp{file}(movSpeed), 'k')
            xlim(xLim)
            hold on
            
            if band == "Delta"
                plot(tempData.Delta.Band{file}(movSpeed), 'c', 'LineWidth', 2)
            else
                plot(tempData.Theta.Band{file}(movSpeed), 'c', 'LineWidth', 2)
            end
        else
            movSpeed = tempData.Speed.Mz{file} > speed;
            % Plot LFP
            plot(tempData.Lfp{file}(movSpeed), 'k')
            xlim(xLim)
            hold on

            if band == "Delta"
                plot(tempData.Delta.Band{file}(movSpeed), 'c', 'LineWidth', 2)
            else
                plot(tempData.Theta.Band{file}(movSpeed), 'c', 'LineWidth', 2)
            end  
        end    
    end
    hold off
    set(gca, ...
            'Box',      'off',...
            'Fontname', 'Arial',...
            'Fontsize', 18)
end