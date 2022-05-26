function [ testName, p, h , r, b] = getStats(left, right, sigOrRank, statsOrCorr)
    if statsOrCorr == "Statistic"
        [h, ~, ~] = swtest([left, right]);
        if h == 1
            if sigOrRank == "Signrank" 
                [ p, h ] = signrank(left, right);
                testName = "Signrank";
            else
                [ p, h ] = ranksum(left, right);
                testName = "Ranksum";
            end
        else
            [ h, p ] = ttest(left, right);
            testName = "Ttest";
        end
        r = '-';
        b = '-';
    else
        coef = polyfit(left, right, 1); % 1 = linear
        
        mdl = fitlm(left, right);
        b = mdl.Rsquared.Ordinary;
        [r, p] = corr(left', right', 'Type', 'Spearman');
        testName = 'Spearman';
        h = '-';
    end
    
end