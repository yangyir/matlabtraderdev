function [ hFig ] = plot_nearATM_intraDay(obj)
% nearATM日内分时图
%左边CallnearATM日内分时图,右边nearATM日内分时图
% wuyunfeng 20170616

call_near_atm_ = obj.call_near_atm_;
put_near_atm_  = obj.put_near_atm_;
record_time_   = obj.record_time_;
near_atm_ = [call_near_atm_; put_near_atm_];

% 获取精准的分时一分钟
minSecond      = 60;
setToday       = today;
morningStart   = setToday + 9/24  + 30/24/60;
morningEnd     = setToday + 11/24 + 30/24/60;
afternoonStart = setToday + 13/24 + 1/24/60;
afternoonEnd   = setToday + 15/24;
fixed_time_ = morningStart:minSecond/24/60/60:morningEnd;
fixed_time_ = [ fixed_time_ , afternoonStart:minSecond/24/60/60:afternoonEnd ];

% 将数据进行切片处理
near_atm_ = QMS_Fusion.spliceFixedTimeQuote(near_atm_, record_time_, fixed_time_);

% 作图
hFig = figure;
time_str_ = datestr(fixed_time_', 'HH:MM');
time_str_ = cellstr(time_str_)';
fixed_time_len_ = length(fixed_time_);

% CALL
ax1 = subplot(1, 2, 1);
plot(1:fixed_time_len_, near_atm_(:, 1), 'b*-', 'LineWidth', 1, 'MarkerSize', 3)
y_call_max_ = nanmax(near_atm_(:, 1));
y_call_min_ = nanmin(near_atm_(:, 1));
set(ax1, 'XLim', [1, fixed_time_len_])
set(ax1, 'XTick', 1:(fixed_time_len_ - 1)/4:fixed_time_len_)
set(ax1, 'XTickLabel', time_str_(1:(fixed_time_len_ - 1)/4:fixed_time_len_))
set(ax1, 'FontWeight', 'bold')
title('Call Near Atm Impvol IntraDay Trend', 'FontWeight', 'bold')
grid on;

% PUT
ax2 = subplot(1, 2, 2);
plot(1:fixed_time_len_, near_atm_(:, 2), 'r*-', 'LineWidth', 1, 'MarkerSize', 3)
y_put_max_ = nanmax(near_atm_(:, 1));
y_put_min_ = nanmin(near_atm_(:, 1));
set(ax2, 'XLim', [1, fixed_time_len_])
set(ax2, 'XTick', 1:(fixed_time_len_ - 1)/4:fixed_time_len_)
set(ax2, 'XTickLabel', time_str_(1:(fixed_time_len_ - 1)/4:fixed_time_len_))
set(ax2, 'FontWeight', 'bold')
title('Put Near Atm Impvol IntraDay Trend', 'FontWeight', 'bold')
grid on;


% 对齐
y_max_ = max([y_call_max_, y_put_max_]);
y_min_ = min([y_call_min_, y_put_min_]);
set(ax1, 'YLim', [y_min_, y_max_])
set(ax2, 'YLim', [y_min_, y_max_])





end