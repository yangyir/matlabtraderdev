%
pathhome = getenv('HOME');
cd(pathhome);
%
if ~exist('c_opt1','var') || ~isa(c_opt1,'CounterCTP'), c_opt1 = CounterCTP.ccb_liyang_fut;end
if ~c_opt1.is_Counter_Login, c_opt1.login;end
% if ~exist('m_opt1','var') || ~isa(m_opt1,'cCTP'), m_opt1 = cCTP.ccb_liyang_fut;end
% if ~m_opt1.isconnect, m_opt1.login;end