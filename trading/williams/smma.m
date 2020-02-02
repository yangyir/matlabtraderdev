function [ outputs ] = smma(candles,n_smoothing,future_shift )
% param candles: 1 - datetime, 2 - open, 3 - high, 4 - low, 5 - close
% param n_smoothing: amount of periods for calculating moving average
% return: list of SMMAs from n_smoothing position to the (end of candles + future_shift)

n_candles = length(candles);

if n_candles < n_smoothing
    error('smma:input candles are too short with input n_smoothing')
end

median_prices = 0.5*(candles(:,3) + candles(:,4));  %(high+low)/2

outputs = nan(n_candles,1);
outputs(n_smoothing) = sum(median_prices(1:n_smoothing))/n_smoothing;
for i = n_smoothing+1:n_candles
    outputs(i) = outputs(i-1)*(n_smoothing-1)/n_smoothing + median_prices(i)/n_smoothing;
end

if nargin < 3
    future_shift = 0;
end

outputs = outputs(1:end-future_shift);


%def SMMA(self, candles_list, n_smoothing_periods, future_shift):
%         '''
%         :param candles_list: list with candles to get median prices
%                 candles indicies: 0 - Open time, 1 - Open, 2 - High, 3 - Low, 4 - Close, 5 - Volume, 6 - Close time
%                 candles_list is at least as long as future_shift
%         :param n_smoothing_periods: amount of periods for calculating moving average
%         :return: list of SMMAs from n_smoothing_periods position to the (end of list + future_shift)
%                 elements 0-5 are sma of previouse periods, 6 - SMA for current periods - the rest - future_shift
%         '''
% 
%         if len(candles_list) < n_smoothing_periods:
%             print('too short')
%             return
% 
%         #create a list of median prices
%         self.median_prices_list = []
%         for i in range(len(candles_list)):
%             median_price = (float(candles_list[i][2]) + float(candles_list[i][3])) / 2  # (high + low) / 2
%             self.median_prices_list.append(median_price)
% 
%         #print(len('median prices list', self.median_prices_list))
% 
%         self.start_len = len(self.median_prices_list)
% 
%         for i in range(n_smoothing_periods, len(candles_list) + future_shift):
%             #print(self.median_prices_list[-n_smoothing_periods:-1])
%             sum_prices = sum(self.median_prices_list[i-n_smoothing_periods:i])
%             smma = sum_prices / n_smoothing_periods
%             self.median_prices_list.append(smma)
% 
%         #print('median_prices_list after smma add', len(self.median_prices_list))
%         return self.median_prices_list[-(self.start_len + n_smoothing_periods): -1]


end

