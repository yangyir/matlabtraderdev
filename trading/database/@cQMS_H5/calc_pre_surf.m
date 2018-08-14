function [call_pre_surf, put_pre_surf] = calc_pre_surf(obj, stkName)
% �����һ�������յ�call_pre_surf��put_pre_surf
%Tmport
% stkName �������

call_pre_surf = VolSurf('call');
put_pre_surf  = VolSurf('put');


% ����pre m2tkCallQuote m2tkPutQuote
callPreQuotes_ = obj.callQuotes_.getCopy();
putPreQuotes_  = obj.putQuotes_.getCopy();
[nT, nK] = size(callPreQuotes_.data);
for t = 1:nT
    for k = 1:nK
        if callPreQuotes_.data(t, k).is_obj_valid
            callPreQuotes_.data(t, k) = obj.callQuotes_.data(t, k).getCopy();
            putPreQuotes_.data(t, k)  = obj.putQuotes_.data(t, k).getCopy();
        end
    end
end

% ���ݵĴ���
stkQuote_ = obj.stkmap_.mp(stkName);
stk_preClose = stkQuote_.preClose;
for t = 1:nT
    for k = 1:nK
        if callPreQuotes_.data(t, k).is_obj_valid
            quote_ = callPreQuotes_.data(t, k);
            % ��������̼�
            quote_.S = stk_preClose;
            quote_.currentDate = today - 1;
            quote_.calcTau;
            % ���ʲ���preClose����last
            quote_.last = quote_.preClose;
            quote_.calc_last_all_greeks;
        end
        if putPreQuotes_.data(t, k).is_obj_valid
            quote_ = putPreQuotes_.data(t, k);
            % ��������̼�
            quote_.S = stk_preClose;
            quote_.currentDate = today - 1;
            quote_.calcTau;
            % ���ʲ���preClose����last
            quote_.last = quote_.preClose;
            quote_.calc_last_all_greeks;
        end
    end
end


call_pre_surf.load_data(callPreQuotes_);
put_pre_surf.load_data(putPreQuotes_);





end