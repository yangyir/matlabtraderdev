clear;clc;delete(timerfindall);
countername = 'rh_demo_tf';
bookname = 'rh-test';
strategyname = 'manual';
riskconfigfilename = [getenv('home'),'regressiontest\cstrat\manual\rh\regressiontest_manual_rh_config.txt'];
%�������ڻ��������͹�ծ�ڻ��Ĳ��������ļ�
genconfigfile('manual',riskconfigfilename,'types',{'basemetal';'govtbond'});
%%
combos = rtt_setup('countername',countername,'bookname',bookname,...
    'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
combos.mdefut.printflag_ = false;
%�������һ��������ҵı�֤��
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
%��������
combos.mdefut.login('Connection','CTP','CounterName','ccb_ly_fut');
%���ӹ�̨
c = combos.ops.getcounter;
if ~c.is_Counter_Login,c.login;end
%% ִ���ֶ����ײ���
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%% ��ӡ�г�����
combos.mdefut.printmarket
%%
code = 'T1812';
limitperentrust = combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','baseunits');
%����2�ֹ�ծ�ڻ���ϵͳӦ�ñ���
combos.strategy.longopen(code,2);
%%
code = 'T1812';
limittotal = combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','maxunits');
%�����мۿ���10��,Ȼ���ʮһ��Ӧ�ñ���
combos.strategy.longopen(code,1,'overrideprice',-1);
%% �ǳ�ϵͳ
combos.mdefut.stop;
delete(timerfindall);
try
    combos.mdefut.logoff;
catch
end
%
try
    c.logout;
catch
end





