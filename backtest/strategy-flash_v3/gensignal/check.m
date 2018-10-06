load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
[opensignal_outside_highest,opensignal_outside_lowest,opensignal_highest,opensignal_lowest] = fcn_closeposition_v1(candles);