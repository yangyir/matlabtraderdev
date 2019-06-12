%regression test after introducing app_id by the regulators
c = CounterCTP.ccb_ly_fut;
if ~c.is_Counter_Login,c.login;end
%%
[info,ret] = c.queryAccount;
disp(info);
if ~ret
    disp('query account failed');
end
%%
[positions,ret] = c.queryPositions;
if ~ret
    disp('query positions failed');
else
    n = length(positions);
    for i = 1:n
        fprintf('%16s\t%3s\t%4s\n',positions(i).asset_code,num2str(positions(i).direction),num2str(positions(i).total_position));
    end
end
%%
e2open = Entrust;
codestr = 'cu1908';
direction = 1;
px = 46300;
lots = 1;
offset = 1;
e2open.fillEntrust(1,codestr,direction,px,lots,offset,codestr);
ret = c.placeEntrust(e2open);
if ret
    disp('entrust placed');
else
    disp('entrust not placed');
end
pause(1);
ret = c.queryEntrust(e2open);
loop = 10;
while ((e2open.dealVolume + e2open.cancelVolume) < lots)
    ret = c.queryEntrust(e2open);
    pause(1);
    loop = loop - 1;
    if loop < 1
        break
    end
end
%%
ret = c.withdrawEntrust(e2open);
%%
c.logout;
