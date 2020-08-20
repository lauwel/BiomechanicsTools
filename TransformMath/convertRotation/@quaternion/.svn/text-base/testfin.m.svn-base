    for k = 1:count,
        for j = 1:size(Sn,1),
            qTest = Sn{j,k};
            q = qTest{1}
%             if (isnan(An))
%                 error('Quaternion cannot be NaN. Retry input.');
%             else,
%                 q = quaternion(An(j,:));
%             end;
            T = q.r;
            fprintf(fid2,'%g\t%g\t%g\n',T');
            fprintf(fid2,'0\t0\t0\n');
        end;
    end;
    
%     end;
% end;
fclose(fid2);
