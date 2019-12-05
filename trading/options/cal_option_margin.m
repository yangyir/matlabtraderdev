function [margin] = cal_option_margin(settlement_future,openprice_option,settlement_option,K,margin_rate,callorput,contract_size)
%       -- 交易保证金 = max（权利金 + 标的期货合约交易保证金 - 1/2 * 期权虚值额，权利金 + 1/2 * 标的期货合约交易保证金）
%       -- 权利金 = max（期权开仓价，期权结算价） * 期权合约乘数
%       -- 标的期货合约交易保证金 = 标的期货合约结算价 * 期货合约乘数 * 保证金比例
%       -- 看涨期权的虚值额 = Max（（期权合约执行价格 - 标的期货合约结算价）*期权合约乘数，0）
%       -- 看跌期权的虚值额 = Max（（标的期货合约结算价 - 期权合约执行价格）*期权合约乘数，0）
%       -- 其中所有的结算价盘中取昨结算价，结算后取今结算价
      premium = max(openprice_option, settlement_option) * contract_size;
      margin_future = settlement_future * contract_size * margin_rate;
      if strcmp(callorput,'call')
            outofmoney_option = max((K - settlement_future) * contract_size , 0);
      elseif strcmp(callorput,'put')
            outofmoney_option = max((settlement_future - K) * contract_size , 0);
      end
      margin_left = premium + margin_future -0.5* outofmoney_option;
      margin_right = premium + 0.5 * margin_future;
      margin = max(margin_left, margin_right);
end