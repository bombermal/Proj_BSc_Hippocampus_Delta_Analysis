function plotPsdSpk(data, value, dataUnorm, PREPOS, ttl, pyr)
    if pyr
        limMz=find(mean(data{PREPOS}.Mz.Acg.Pyr,2)>value);
        limWh=find(mean(data{PREPOS}.Wh.Acg.Pyr,2)>value);
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:)),'k','linewidth',2)
        hold on
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:)),'r','linewidth',2)

        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:))-std(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:))/sqrt(size(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:),1)),'k--')
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:))+std(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:))/sqrt(size(data{PREPOS}.Mz.Pwelch.Pyr(limMz,:),1)),'k--')

        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:))-std(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:))/sqrt(size(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:),1)),'r--')
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:))+std(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:))/sqrt(size(data{PREPOS}.Wh.Pwelch.Pyr(limWh,:),1)),'r--')
    else
        limMz=find(mean(data{PREPOS}.Mz.Acg.Int,2)>value);
        limWh=find(mean(data{PREPOS}.Wh.Acg.Int,2)>value);
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Int(limMz,:)),'k','linewidth',2)
        hold on
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Int(limWh,:)),'r','linewidth',2)

        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Int(limMz,:))-std(data{PREPOS}.Mz.Pwelch.Int(limMz,:))/sqrt(size(data{PREPOS}.Mz.Pwelch.Int(limMz,:),1)),'k--')
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Mz.Pwelch.Int(limMz,:))+std(data{PREPOS}.Mz.Pwelch.Int(limMz,:))/sqrt(size(data{PREPOS}.Mz.Pwelch.Int(limMz,:),1)),'k--')

        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Int(limWh,:))-std(data{PREPOS}.Wh.Pwelch.Int(limWh,:))/sqrt(size(data{PREPOS}.Wh.Pwelch.Int(limWh,:),1)),'r--')
        plot(dataUnorm{PREPOS}.PwelchF,mean(data{PREPOS}.Wh.Pwelch.Int(limWh,:))+std(data{PREPOS}.Wh.Pwelch.Int(limWh,:))/sqrt(size(data{PREPOS}.Wh.Pwelch.Int(limWh,:),1)),'r--')
    end
    
    xlim([3 15])
    % ylim([0 6]*10^-4)
    title(ttl)
    xlabel 'Frequency (Hz)'
    ylabel 'Power (mV²/Hz)'
%     axis square
    box off
    % axis tight
end