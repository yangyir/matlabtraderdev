login_counter_opt1;
%%
init_mde;
%%
sec = cFutures('ni1807');
sec.loadinfo('ni1807_info.txt');
%%
mdefut.registerinstrument(sec);
%%
mdefut.timer_interval_ = 0.5;
mdefut.start
%%
candle = mdefut.getlastcandle(sec);
fprintf('candlestick time:%s\topen:%4.0f\thigh:%4.0f\tlow:%4.0f\tclose:%4.0f\n',...
    datestr(candle{1}(1),'yy-mm-dd HH:MM'),candle{1}(2),candle{1}(3),candle{1}(4),candle{1}(5));

%%
strat = cStratManual;
strat.registercounter(c_opt1);
strat.mde_fut_ = mdefut;
%%
strat.registerinstrument(sec);
%%
strat.loadbookfromcounter('FutList','all');
%%
%���ֲ�
strat.bookrunning_.printpositions;
%%
strat.start
%%
%�򿪲�
strat.longopensingleinstrument(sec.code_ctp,1,3);
%%
%��ƽ(�񣩲�
strat.shortclosesingleinstrument(sec.code_ctp,1,1,2);
%%
%������
strat.shortopensingleinstrument(sec.code_ctp,1,2);
%%
%��ƽ(�񣩲�
strat.longclosesingleinstrument(sec.code_ctp,1,1,3);
%%
%����
strat.withdrawentrusts(sec.code_ctp);
%%
%��ʾδ�ɽ��ҵ�
strat.helper_.printpendingentrusts;
%%
%��ʾ����ί�е�
strat.helper_.printallentrusts;
%%
%�ֲ�
strat.bookrunning_.printpositions;
%%
strat.stop
%%
strat.helper_.stop;
%%
mdefut.stop