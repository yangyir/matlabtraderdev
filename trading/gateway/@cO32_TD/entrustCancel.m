function [errorCode, errorMsg,cancelNo] = entrustCancel(self, entrustNo)
%ENTRUSTCANCEL 在CounterHSO32中重新包装函数EntrustsCancel
% --------------------------
% 程刚，20160201

connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode, errorMsg,cancelNo] = EntrustCancel( connection,token,combiNo,entrustNo, 1);
end
