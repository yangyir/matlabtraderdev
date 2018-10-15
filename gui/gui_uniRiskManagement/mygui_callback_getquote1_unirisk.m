function mygui_callback_getquote1_unirisk( hObject , eventdata , handles)
% updated on 2018/10/14 by sunq
    variablenotused(hObject);
    variablenotused(eventdata);
    c = CounterHSO32.sunqtest_2310_o32;
    c.login; 
    getquote1_fcn(handles,c)
%     c_rh = cCounterRH.rh_demo;
%     c_rh.login;
    t =timer('TimerFcn',{@getquote1_fcn,handles,c},...
        'Period',1.0,...
        'ExecutionMode','fixedDelay');
    start(t);
end