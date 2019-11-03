for k = j:np
            if diffvec(k) < 0, break;end
            refs = macdenhanced(k,p);
            upperbound1 = refs.y1 + refs.k1*refs.x(end);
            upperbound2 = refs.y3 + refs.k3*refs.x(end);
            
            
            if isempty(upperbound1) && isempty(upperbound2)
                continue;
            elseif ~isempty(upperbound1) && isempty(upperbound2)
                fprintf('%4.3f\t%4.3f\n',p(k,5),upperbound2);
                if p(k,5) > upperbound2
                    fprintf('buy at %d\n',k);
                    break
                end
            elseif isempty(upperbound1) && ~isempty(upperbound2)
                if p(k,5) > upperbound2
                    fprintf('buy at %d\n',k);
                    break
                end
            else
            end
                
            
            if scen == 1
            elseif scen == 2
            elseif scen == 3
            else
            end
            
        end