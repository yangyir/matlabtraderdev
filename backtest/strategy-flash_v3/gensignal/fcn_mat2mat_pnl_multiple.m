function [tradepnl_mat1] = fcn_mat2mat_pnl_multiple(tradepnl_struct_single1,tradepnl_struct_single2,tradepnl_struct_single3,tradepnl_struct_single4)
   % opentimenum | closetimenum | direction | openprice | closeprice | pnl | outsideornot
   tradepnl_mat_single1 = fcn_struct2mat_pnl_single(tradepnl_struct_single1);
   tradepnl_mat_single2 = fcn_struct2mat_pnl_single(tradepnl_struct_single2);
   tradepnl_mat_single3 = fcn_struct2mat_pnl_single(tradepnl_struct_single3);
   tradepnl_mat_single4 = fcn_struct2mat_pnl_single(tradepnl_struct_single4);
   if ~isempty(tradepnl_mat_single1)
        tradepnl_mat = tradepnl_mat_single1;
    end
    if ~isempty(tradepnl_mat_single2)
        tradepnl_mat = [tradepnl_mat; tradepnl_mat_single2];
    end
    if ~isempty(tradepnl_mat_single3)
        tradepnl_mat = [tradepnl_mat; tradepnl_mat_single3];
    end
    if ~isempty(tradepnl_mat_single4)
        tradepnl_mat = [tradepnl_mat; tradepnl_mat_single4];
    end
    % clear the rows with NAN   
    row = any(isnan(tradepnl_mat),2);
    tradepnl_mat(row,:) = [];
    % sortrows according on closetimenum
    if ~isempty(tradepnl_mat)
        tradepnl_mat1=sortrows(tradepnl_mat,2);
    end
end