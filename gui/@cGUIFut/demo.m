%%
mygui = cGUIFut('filename','config_gui_mdefut_config2.txt');
%%
% k = mygui.mdefut_.getallcandles('i1909');
% k = k{1};
% datestr(k(end,1))
%%
% mygui.login
% %%
% mygui.mdefut_.refresh
%%
%%
mygui.refresh;
%%
mygui.mdefut_.start
%%
mygui.start;
%%
mygui.mdefut_.stop;
delete(timerfindall);