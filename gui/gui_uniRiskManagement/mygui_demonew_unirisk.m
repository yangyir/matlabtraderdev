function handles = mygui_demonew_unirisk
    handles = mygui_framework_unirisk;
%     c = CounterHSO32.sunqtest_2310_o32;
%     c.login; 
%     c_rh = cCounterRH.rh_demo;
%     c_rh.login;
    set(handles.operation1.button_futquote,'CallBack',{@mygui_callback_getquote1_unirisk, handles});
    set(handles.operation2.button_futquote,'CallBack',{@mygui_callback_getquote2_unirisk, handles});
end