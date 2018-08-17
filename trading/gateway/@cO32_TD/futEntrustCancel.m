function [errorCode, errorMsg,cancelNo] = futEntrustCancel(self, entrustNo)
%optEntrustCancel 在CounterHSO32中重新包装函数EntrustsCancel
% --------------------------
% 朱江，20160316

connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode, errorMsg,cancelNo] = EntrustCancel( connection,token,combiNo,entrustNo, 2);
end
