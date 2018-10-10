function mygui_callback_getquote1_unirisk( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);
    c = CounterHSO32.sunqtest_2310_o32;
    c.login; 
    c_rh = cCounterRH.rh_demo;
    c_rh.login;
    table_risk = handles.risk.table;
    table_warning = handles.warning.table;
    
%     details = get(table_fut,'RowName');

    [errorCode,errorMsg,packet35003] = c.queryCombiAccount_35003;%资金总额o32
    [errorCode,errorMsg,packet34003] = c.queryCombiAccount_34003;%期货保证金o32
    [errorCode,errorMsg,packet34004] = c.queryCombiAccount_34004;%期权保证金o32
    
    accountinfo = c_rh.queryAccount;%查询账户资金情况rh
    
     quote_data = cell(5,3);
%      quote_data{1,1} = string(packet1.getStr(total_asset));
%     details{1} = 'total_asset';
     %O32
     
     quote_data{1,1} = str2double(string(packet35003.getStr('total_asset')));
     num_asset_o32 = quote_data{1,1};
%      futmargin_o32 = str2double(string(packet34003.getStr('occupy_deposit_balance')));
%      optmargin_o32 = str2double(string(packet34004.getStr('occupy_deposit_balance')));
futmargin_o32=0;
optmargin_o32=0;
     stockasset_o32= str2double(string(packet35003.getStr('stock_asset')));
     quote_data{2,1} = futmargin_o32+optmargin_o32;
     quote_data{3,1} = (futmargin_o32+optmargin_o32)/num_asset_o32 * 100;
     quote_data{4,1} = futmargin_o32;
     quote_data{5,1} = futmargin_o32/num_asset_o32*100;
     quote_data{6,1} = stockasset_o32;
     quote_data{7,1} = stockasset_o32/num_asset_o32*100;
     quote_data{8,1} = 1-quote_data{3,1}-quote_data{7,1};
     % RH
     
     quote_data{1,2} = accountinfo.pre_interest;
     quote_data{2,2} = accountinfo.current_margin; %缺少期权部分
     quote_data{3,2} = accountinfo.current_margin/accountinfo.pre_interest* 100;
     quote_data{4,2} = accountinfo.current_margin;
     quote_data{5,2} = accountinfo.current_margin/accountinfo.pre_interest* 100;
     quote_data{6,2} = 0;
     quote_data{7,2} = 0;
     % total
     quote_data{1,3} = quote_data{1,1}+quote_data{1,2};
     quote_data{2,3} = quote_data{2,1}+quote_data{2,2};
     quote_data{3,3} = quote_data{2,3}/quote_data{1,3};
     quote_data{4,3} = quote_data{4,1}+quote_data{4,2};
     quote_data{5,3} = quote_data{4,3}/quote_data{1,3};
     quote_data{6,3} = quote_data{6,1}+quote_data{6,2};
     quote_data{7,3} = quote_data{6,3}/quote_data{1,3};
     [m,n]= size(quote_data);
         for i =1:m
             for j = 1:n
                 quote_data_str{i,j} = num2str(quote_data{i,j});
             end
         end
            
     set(handles.risk.table,'Data',quote_data_str);
     %
     quote_data_warning{1,1} = 20;
     quote_data_warning{1,2} = 0;
     quote_data_warning{2,1} = 5;
     quote_data_warning{2,2} = 0;
     quote_data_warning{3,1} = 20;
     quote_data_warning{3,2} = 0;
     if quote_data{3,3} <= quote_data_warning{1,1}
         quote_data_warning{1,3} = '     正常';
     else
         quote_data_warning{1,3} = '    超出限额';
     end
     if quote_data{5,3} <= quote_data_warning{2,1}
         quote_data_warning{2,3} = '     正常';
     else
         quote_data_warning{2,3} = '   超出限额';
     end
    if quote_data{7,3} <= quote_data_warning{1,3}
         quote_data_warning{3,3} = '     正常';
     else
         quote_data_warning{3,3} = '   超出限额';
     end

      set(handles.warning.table ,'Data',quote_data_warning);
      
%         pause(1);
%     end
    
end