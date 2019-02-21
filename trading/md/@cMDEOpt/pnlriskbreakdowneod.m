function [] = pnlriskbreakdowneod(underlier_code_ctp,numofstrikes)
    [calls,puts] = getlistedoptions(underlier_code_ctp,numofstrikes);
    cobdate = getlastbusinessdate;
    predate = businessdate(cobdate,-1);
    pnlbreakeodc = cell(size(calls,1),1);
    pnlbreakeodp = cell(size(calls,1),1);
    
    for j = 1:size(calls,1)
        pnlbreakeodc{j} = pnlriskbreakdown1(calls{j},cobdate);
        pnlbreakeodp{j} = pnlriskbreakdown1(puts{j},cobdate);
    end
    
    headerformat = '%14s%10s%10s%10s%10s%10s%10s%11s%11s\n';
    fprintf('\npnl breakdown of calls from %s to %s:\n',datestr(predate,'dd-mmm'),datestr(cobdate,'dd-mmm'));
    fprintf(headerformat,'code','totalpnl','thetapnl','deltapnl','gammapnl','vegapnl','other','iv1','iv2');
    for j = 1:size(calls,1)
        fprintf('%14s',calls{j}.code_ctp);
        fprintf('%10.1f',pnlbreakeodc{j}.pnltotal);
        fprintf('%10.1f',pnlbreakeodc{j}.pnltheta);
        fprintf('%10.1f',pnlbreakeodc{j}.pnldelta);
        fprintf('%10.1f',pnlbreakeodc{j}.pnlgamma);
        fprintf('%10.1f',pnlbreakeodc{j}.pnlvega);
        fprintf('%10.1f',pnlbreakeodc{j}.pnlunexplained);
        fprintf('%10.1f%%',pnlbreakeodc{j}.iv1*100);
        fprintf('%10.1f%%',pnlbreakeodc{j}.iv2*100);
        fprintf('\n');
    end

    fprintf('\npnl breakdown of puts from %s to %s:\n',datestr(predate,'dd-mmm'),datestr(cobdate,'dd-mmm'));
    fprintf(headerformat,'code','totalpnl','thetapnl','deltapnl','gammapnl','vegapnl','other','iv1','iv2');
    for j = 1:size(puts,1)
        fprintf('%14s',puts{j}.code_ctp);
        fprintf('%10.1f',pnlbreakeodp{j}.pnltotal);
        fprintf('%10.1f',pnlbreakeodp{j}.pnltheta);
        fprintf('%10.1f',pnlbreakeodp{j}.pnldelta);
        fprintf('%10.1f',pnlbreakeodp{j}.pnlgamma);
        fprintf('%10.1f',pnlbreakeodp{j}.pnlvega);
        fprintf('%10.1f',pnlbreakeodp{j}.pnlunexplained);
        fprintf('%10.1f%%',pnlbreakeodp{j}.iv1*100);
        fprintf('%10.1f%%',pnlbreakeodp{j}.iv2*100);
        fprintf('\n');
    end
    
end