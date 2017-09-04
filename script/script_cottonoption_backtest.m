% script cotton options
% option is sold in Apr07/May07 and exercised/settled in Sep07/Oct07
% 6 months time to expiry
% the active contract would be the May07 contract when to price
% the active contract would be the Jan08 contract when to settle

% --- data analysis (part 1)
% analysis the calendar spread between the May-Jan contract for the last 5
% years
period = '-5y';
cottonRollResults = rollfutures('cotton',period,'CalcDailyReturn',true);
