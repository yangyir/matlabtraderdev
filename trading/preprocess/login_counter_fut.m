%
pathhome = getenv('HOME');
cd(pathhome);
%
if ~exist('c_fut','var') || ~isa(c_fut,'CounterCTP'), c_fut = CounterCTP.citic_kim_fut;end
if ~c_fut.is_Counter_Login, c_fut.login;end
if ~exist('m_fut','var') || ~isa(m_fut,'cCTP'), m_fut = cCTP.citic_kim_fut;end
if ~m_fut.isconnect, m_fut.login;end