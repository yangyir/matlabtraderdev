%%
% mygui = cGUIFut('filename','config_gui_mdefut_copper.txt');
mygui = cGUIFut('filename','config_gui_mdefut_financial.txt');
%%
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
mygui.stop;
mygui.mdefut_.stop;
delete(timerfindall);
%%
mygui.mdefut_.logoff;