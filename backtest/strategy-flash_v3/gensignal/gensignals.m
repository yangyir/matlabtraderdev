% initalise all paras
clear
clc

load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
[opensignal_highest,opensignal_outside_highest,opensignal_lowest,openlsignal_outside_lowest] = fcn_gen_opensignal(candles);



