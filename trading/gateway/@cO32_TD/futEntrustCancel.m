function [errorCode, errorMsg,cancelNo] = futEntrustCancel(self, entrustNo)
%optEntrustCancel ��CounterHSO32�����°�װ����EntrustsCancel
% --------------------------
% �콭��20160316

connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode, errorMsg,cancelNo] = EntrustCancel( connection,token,combiNo,entrustNo, 2);
end
