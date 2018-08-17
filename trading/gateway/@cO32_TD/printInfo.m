function [ txt ] = printInfo( self )
%PRINTINFO Êä³ö
% --------------------------
% ³Ì¸Õ£¬20160201

txt = sprintf('Counter Info:\n');
txt = sprintf('%sServer = %s:%d\n',txt, self.serverIp, self.serverPort);
txt = sprintf('%sOperator = %s:%s\n',txt, self.operatorNo, self.password);
txt = sprintf('%sAccountCode = %s\n', txt, self.accountCode);
txt = sprintf('%sCombiNo = %s\n', txt, self.combiNo);
txt = sprintf('%sIsLoggedin = %d\n', txt, self.is_Counter_Login);


if nargout == 0
disp(txt);
end

end

