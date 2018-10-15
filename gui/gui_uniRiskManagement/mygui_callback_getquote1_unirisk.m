function mygui_callback_getquote1_unirisk( hObject , eventdata , handles)
% updated on 2018/10/15 by sunq
    set(handles.t,'TimerFcn',{@getquote1_fcn,handles});
%     set(handles.t,'UserData',handles);
    start(handles.t);
 end