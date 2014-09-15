% Sodoku Core
%Kevin Claytor
%October 19, 2006
%
%SodokuCore(A)
%  Solves the input matrix A (where blanks are represented as zeros)
%

function [A]=SudokuCore(A)

%%FIRST CHECK METHOD
loop = 0;
while (min(min(A))==0 && loop<100)  %While there is a blank
    %look for another position to solve
    for x=1:9
        for y=1:9
            if A(x,y)==0 %this spot is zero, we need to solve it
                %clear possible
                possible = [];
                %get the possible values that this element can take
                possible = getPossible(A,x,y);
                %if that vector is only one number long, that must be the only allowed
                if length(possible)==1
                    %  piece, record it in A
                    A(x,y) = possible;
                end
            end
        end
    end
    loop = loop + 1;
    %move onto the next piece
end
%%END FIRST CHECK METHOD

%%SECOND CHECK METHOD
%  If the first check method fails and after trying all the empty spaces
%  the matrix is the same, try this method.
%Check each element of the row, col, or Mat individually to see if
%   our possibilities are possible element in one of these.
%If it's not a possible value, than this element must
%   take that value.

% loop = 0;
% while (min(min(A))==0 && loop<10)  %While there is a blank
%     %look for another position to solve
%     for x=1:9
%         for y=1:9
%             if A(x,y)==0 %this spot is zero, we need to solve it
%                 %Initialize vars
%                 row = [];
%                 col = [];
%                 Mat = [];
%                 possible = [];
%                 %get the row, column and 3x3 group our element is in
%                 row = A(x,:);
%                 col = A(:,y);
%                 Mat = getMat(A,x,y);
%                 %Find the possible values that our cell can take
%                 possible = getPossible(A,x,y);
%                 %for each possible value of this element, see if it is
%                 %    a possible value of the miniMat, row or col.  If
%                 %    it is not a possible value of any of these, it
%                 %    must be the value of this cell.
%                 possiblerow = [];
%                 possiblecol = [];
%                 possiblemat = [];
%                 %Check the row
%                 unique=[];
%                 for m=1:9
%                     if row(m)==0
%                         possiblerow=[possiblerow,getPossible(A,x,m)];
%                     end
%                 end
%                 for k=1:length(possible) 
%                     unique=compare(possiblerow,possible(k));
%                 end
%                 if length(unique)==1
%                     A(x,y)=unique(1);
%                 end
%                 %Check the column
%                 unique=[];
%                 for m=1:9
%                     if col(m)==0
%                         possiblecol=[possiblecol,getPossible(A,m,y)];
%                     end
%                 end
%                 for k=1:length(possible) 
%                     unique=compare(possiblecol,possible(k));
%                 end
%                 if length(unique)==1
%                     A(x,y)=unique(1);
%                 end
%                 %Check the matrix
% %                 unique=[];
% %                 for m=1:3
% %                     for n=1:3
% %                     if Mat(m,n)==0
% %                         possiblemat=[possiblemat,getPossible(A,x+(m-1),y+(n-1))];
% %                     end
% %                 end
% %                 for k=1:length(possible) 
% %                     unique=compare(possiblerow,possible(k));
% %                 end
% %                 if length(unique)==1
% %                     A(x,y)=unique(1);
% %                 end
%                 
%             end
%         end
%     end
%     loop = loop + 1;
%     %move onto the next piece
% end
% %%END SECOND CHECK METHOD

return

%Determines the possible values that a certain element could take.
function possible=getPossible(A,x,y)

%Initialize vars
row = [];
col = [];
Mat = [];
possible = [];
%get the row, column and 3x3 group our element is in
row = A(x,:);
col = A(:,y);
Mat = getMat(A,x,y);
%check those three groups for the numbers 1:9
%if we don't find a number this cell could potentially be
%   that, add it to a vector
for k = 1:9
    valr = compare(row,k);
    valc = compare(col,k);
    valm = compare(Mat,k);
    if (valr+valc+valm) == 0    %if the number isn't found in either the row, column, or sub grid, it is a possible solution
        possible = [possible,k];
    end
end

return



%determines if wer're in the first, middle or third position of a middle
%   cell using mod (remainder) and then get's the other elements
function Mat = getMat(A,x,y)

if mod(x,3)==1  %the first x position of a minicell
    if mod(y,3)==1  %Same for y positions
        Mat=A(x:x+2,y:y+2);
    elseif mod(y,3)==2
        Mat=A(x:x+2,y-1:y+1);
    else
        Mat=A(x:x+2,y-2:y);
    end
elseif mod(x,3)==2  %the middle x position of a minicell
    if mod(y,3)==1
        Mat=A(x-1:x+1,y:y+2);
    elseif mod(y,3)==2
        Mat=A(x-1:x+1,y-1:y+1);
    else
        Mat=A(x-1:x+1,y-2:y);
    end
else    %the end x position of a minicell
    if mod(y,3)==1
        Mat=A(x-2:x,y:y+2);
    elseif mod(y,3)==2
        Mat=A(x-2:x,y-1:y+1);
    else
        Mat=A(x-2:x,y-2:y);
    end
end

return



%returns 0 if the the matricies B and C share no elements
%  if they do have an element in common, then we add it to a list if it's
%  not already in there
function res = compare(B,C)

res = 0;
[h,j]=size(B);
[k,l]=size(C);

%Loop through every element in B and compare it to every element in C
for x = 1:h
    for y = 1:j
        for c = 1:k
            for v = 1:l
                if B(x,y)==C(c,v)   %if they match add it
                    if res ~= []    %and if res is not empty
                        for g=1:length(res) %only if we don't already have it
                            if res(g)~=C(c,v)
                                res = [res,C(c,v)];
                            end
                        end
                    else            %if it is empty, we certainly don't have it, go on and add it
                        res = [res,C(c,v)];
                    end
                end
            end
        end
    end
end

return
