function [ht, pt, hr, pr] = calcStats(left, right, normFactor)
    [ht, pt] = ttest(left./normFactor, right./normFactor);
    [pr, hr] = ranksum(left./normFactor, right./normFactor);
end