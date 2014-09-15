function newPM=Spaceshift(oldPM,maxstress,roworcol,updown,stress,deltastress,deltashift)
%newPM = oldPM;
%  roworcol; -1 / 0 = row, 1 = col
%  updown; 1 = up, -1 = down, 0 = no shift
%     An updown of 1 means that our guess is above the actual, so we have
%     to lower it which we do by increasing the elements
if (roworcol == -1) || (roworcol == 0)
    % row shift
    for j = 1:length(oldPM)
        %if the element falls within our stress range for shifting
        if (oldPM(j,2) >= stress) && (oldPM(j,2) <= (stress+deltastress))
            %then shift it (vertically within the col)
            newCo=oldPM(j,1)+(updown*rand*deltastress*deltashift);
            %if we shifted off of the graph, move us back on
            if newCo > maxstress    %if we're greater than the max we can be
                newCo = 0;          %set us equal to zero
            end
            if newCo < oldPM(j,2)   %if we're greater than the closing stress
                newCo = oldPM(j,2); %put us on the diagonal
            end
            oldPM(j,1)=newCo;
        end
    end
elseif roworcol == 1
    % col shift
    for j = 1:length(oldPM)
        %if the element falls within our stress range for shifting
        if (oldPM(j,1) >= stress) && (oldPM(j,1) <= (stress+deltastress)) && (rand > 0.5)
            %then shift it
            newCp=oldPM(j,2)+(updown*rand*deltastress*deltashift);
            %if we shifted off of the graph, move us back on
            if newCp < 0            %if we're less than zero
                newCp = 0;          %set us equal to zero
            end
            if newCp > oldPM(j,1)   %if we're greater than the closing stress
                newCp = oldPM(j,1); %put us on the diagonal
            end
            oldPM(j,2)=newCp;
        end
    end
end
newPM = oldPM;