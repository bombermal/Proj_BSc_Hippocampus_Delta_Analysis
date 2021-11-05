function [ht, pt, hr, pr] = calcStats(left, right)
    [ht, pt] = ttest2(left, right);
    [pr, hr] = ranksum(left, right);
end