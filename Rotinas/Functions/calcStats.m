function [ht, pt, hr, pr] = calcStats(left, right, normFactor, paired)
    if paired
        % Paired
        [ht, pt] = ttest(left./normFactor, right./normFactor);
        [pr, hr] = signrank(left./normFactor, right./normFactor);
    else
    % Un-paired
        [ht, pt] = ttest2(left./normFactor, right./normFactor);
        [pr, hr] = ranksum(left./normFactor, right./normFactor);
    end
end