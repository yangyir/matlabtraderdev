%
pathhome = getenv('HOME');
cd(pathhome);
%
if ~exist('c_opt2','var') || ~isa(c_opt2,'CounterCTP'), c_opt2 = CounterCTP.huaxin_liyang_fut;end
if ~c_opt2.is_Counter_Login, c_opt2.login;end
if ~exist('m_opt2','var') || ~isa(m_opt2,'cCTP'), m_opt2 = cCTP.huaxin_liyang_fut;end
if ~m_opt2.isconnect, m_opt2.login;end