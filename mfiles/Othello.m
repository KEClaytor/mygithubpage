%Function Othello
% Kevin Claytor
% July 22-30, 2006
%
% Othello.m
% Usage
%    Othello(action)
%
% Launches a GUI from which the user can specify their difficutly level and
%   then allows the user to play the computer, or another person
%   Note; Wimpy is really easy (my mom beat it), and I haven't had the patience
%     to test Difficult :p
%   More information on the major subfunctions can be found within this
%     code, please open and read.
%
% For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Game - the input matrix that tells us what the current game looks like.
%   depth - how far down we want to go recursively
%   Move - the next move that the computer will make
%   value - the value of the next move - for recursive purposes.
%

%Pseudocode
%
% 1 - Initialize everything
% 2 - See if we want to play against the computer or a person
% 3 - If we want to play against the computer find the difficulty and start
%     - looping player vs computer
% 4 - If we want to play against a person, start looping between the player
%     - and the other player
% 5 - When the game ends, give us the option to reset (but let's be polite
%       and leave the board up until we're told to clear it)
% 6&7 - Give us some about and rules boxes
%

function Othello(action)

global nx ny A

if nargin<1                                 % If number of arguments input < 1
    action = 'initialize';                  %  we initialize our game
end

if strcmp(action,'initialize')  
    figure('Name','Othello',...
        'NumberTitle','off', ...
        'DoubleBuffer','on');   % turn off that flickering
    axes
    set(gca,'Position',[0.22,0.05,0.75,0.85]); % Position in normalized units (% of window)
    axis([0.5 8+.5 0.5 8+.5])                       % Remake the axis based on the size of our matrix
    grid on                                 % Turn on the grid
    set(gca,'xtick',0.5:8)                 % Set the grid tick at ever half point so as to make
    set(gca,'ytick',0.5:8)                 %  the dot appear between grid marks
    set(gca,'xticklabel',[])                % Get rid of the ugly labels
    set(gca,'yticklabel',[])
    
    % Start Pushbutton
    uicontrol('Style','PushButton',...
        'String','Start',...  % Initial label on button
        'Position',[10 30 80 50],... % Position in pixel units
        'Callback','Othello(''start'')',... % What clicking on the button does
        'Tag','Start');              % Control name
    
    % Pop-up menu
    uicontrol('Style','Popupmenu',...
        'String','Wimpy|Easy|Medium|Difficult',...
        'Value',3,...
        'Position',[10 320 110 30],...
        'Tag','Difficulty');
    % Text to title the Pop-up menu
    uicontrol('Style','Text',...           % Boring text box
        'String','Difficulty',...
        'Position',[10 360 110 20]);
    
    % 2-Player mode
    uicontrol('Style','Togglebutton',...
        'String','2 Player Mode',...
        'Position',[10 290 110 30],...
        'Tag','Player');
    % Text to tell us which player's turn it is
    uicontrol('Style','Text',...
        'String','Player 1 Move',...
        'Position',[10 260 110 20],...
        'Visible','off',...          % Make this non visible until we need it
        'Tag','Play1');
    uicontrol('Style','Text',...
        'String','Player 2 Move',...
        'Position',[10 260 110 20],...
        'Visible','off',...          % Make this non visible until we need it
        'Tag','Play2');
    uicontrol('Style','Text',...
        'String','Computer''s Move',...
        'Position',[10 260 110 20],...
        'Visible','off',...          % Make this non visible until we need it
        'Tag','PlayC');
    
% An error thingy
    uicontrol('Style','Text',...
        'String','Illegal Move - Pieces cannot be placed on each other',...
        'Position',[10 230 110 50],...
        'Visible','off',...          % Make this non visible until we need it
        'Tag','Overlap');
    uicontrol('Style','Text',...
        'String','Illegal Move - No pieces will be flipped',...
        'Position',[10 130 110 50],...
        'Visible','off',...          % Make this non visible until we need it
        'Tag','Null');
    
    % An about dialouge
    uicontrol('Style','PushButton',...
        'String','About',...
        'Position',[10 1 50 15],...
        'Callback','Othello(''about'')',... % give our about message
        'Tag','About');
    % An rules dialouge
    uicontrol('Style','PushButton',...
        'String','Rules',...
        'Position',[70 1 50 15],...
        'Callback','Othello(''rules'')',... % give our about message
        'Tag','Rules');
    
    A = zeros(8,8);     %Make the starting board
    A(4,4) = 1;
    A(5,5) = 1;
    A(4,5) = 2;
    A(5,4) = 2;
    PlotDots(A)
    
elseif strcmp(action,'start')
    
    dif = findobj(gcf,'Tag','Difficulty');  % Find popup menu in current figure
    pb = findobj(gcf,'Tag','Start');        % Find the pushbutton
    tog = findobj(gcf,'Tag','Player');      % Find the toggle
    player1info = findobj(gcf,'Tag','Play1');      % Find the three text thingies
    player2info = findobj(gcf,'Tag','Play2');
    playerCinfo = findobj(gcf,'Tag','PlayC');
    
    if strcmp(get(pb,'String'),'Start')
        set(pb,'String','Stop')
        togval=get(tog,'Value');
        %See if we need to invoke the computer
        if togval==0       %We shall play against the computer!
            %Decide which difficulty to use
            switch get(dif,'Value')
                case 1                              % Default - computer looks 1 move ahead (the next move)
                    difficulty = 0;                 %   - no edge weighting
                case 2                              % computer looks 2 moves ahead
                    difficulty = 1;                 %   - moderate edge weighting
                case 3                              % computer looks 3 moves ahead
                    difficulty = 2;                 %   - severe edge weighting
                case 4                              % computer looks 6 moves ahead
                    difficulty = 5;                 %   - insane edge weighting
            end
            % The fun part!  Let's play against the computer!
            itc = 0;
            while (itc < 100) && (strcmp(get(pb,'String'),'Stop'))    % Play for gen generations
                %Do our move
                set(player1info,'Visible','on')   %make our instructions visibile
                [h,j]=getClick(A,1);
                %Flip the pieces.  This also updates the pieces we just placed
                A=OthelloFlip(A,1,h,j);
                %Plot
                PlotDots(A)
                set(player1info,'Visible','off')   %hide the instructions
                %Check to see if that didn't end the game
                [u,v]=find(A);
                if length(u)==64
                    break
                end
                
                %Do the computer's move
                set(playerCinfo,'Visible','on')   %inform the user the computer is working
                drawnow;
                [cx,cy,value,pass]=OthelloCore(A,difficulty,difficulty+1,2);
                %Filp the pieces & update if we don't pass
                if pass==0
                    A=OthelloFlip(A,2,cx,cy);
                end
                %Plot
                PlotDots(A)
                set(playerCinfo,'Visible','off')   %hide when finished
                %Check to see if that didn't end the game
                [u,v]=find(A);
                if length(u)==64
                    break
                end
                
                % Increase our itteration count (so we don't keep running on and on)
                itc = itc + 1;
            end
            %We're done?  Let's see who won.
            blackscore=0;       %Initialize our score counter
            blackscore=length(find(A>1));
            if blackscore > 32
                winstring=['The computer wins :-(  ',num2str(blackscore),':',num2str(64-blackscore)];
                msgbox(winstring,'Black Wins');
            elseif blackscore == 32
                msgbox('Tie game','Tie');
            else
                winstring=['You have won!  ',num2str(64-blackscore),':',num2str(blackscore)];
                msgbox(winstring,'White Wins');
            end
        else            %We want to play player to player.
            itc = 0;
            while (itc < 100) && (strcmp(get(pb,'String'),'Stop'))    % Play for gen generations
                
                %Player 1
                set(player1info,'Visible','on')   %make our instructions visibile
                [h,j]=getClick(A,1);
                A=OthelloFlip(A,1,h,j);     %Flip the new pieces.  This also updates with the piece we just placed
                %Plot
                PlotDots(A)
                set(player1info,'Visible','off')   %hide the instructions
                %Check to see if that didn't end the game
                [u,v]=find(A);
                if length(u)==64
                    break
                end
                
                %Player 2
                set(player2info,'Visible','on')   %make our instructions visibile
                [h,j]=getClick(A,2);
                A=OthelloFlip(A,2,h,j);     %Flip the new pieces.  This also updates with the piece we just placed
                %Plot
                PlotDots(A)
                set(player2info,'Visible','off')   %hide the instructions
                %Check to see if that didn't end the game
                [u,v]=find(A);
                if length(u)==64
                    break
                end
                
                % Increase our itteration count (so we don't keep running on and on)
                itc = itc + 1;
            end
            %We're done?  Let's see who won.
            blackscore=0;       %Initialize our score counter
            blackscore=length(find(A>1));
            if blackscore > 32
                winstring=['Player 2 wins!  ',num2str(blackscore),':',num2str(64-blackscore)];
                msgbox(winstring,'Black Wins');
            elseif blackscore ==32
                msgbox('Tie game!','Tie');
            else
                winstring=['Player 1 wins!  ',num2str(64-blackscore),':',num2str(blackscore)];
                msgbox(winstring,'White Wins');
            end
        end
        set(pb,'String','Reset')            % Reset for the next time
    elseif strcmp(get(pb,'String'),'Reset')
        Othello('reset')
    else
        set(pb,'String','Reset')            % When does this get used?
        return                              % Try putting a breakpoint here
    end
elseif strcmp(action,'reset')   %We want to reset for a new game
    pb = findobj(gcf,'Tag','Start');
    cla;                %Clear the figure
    A = zeros(8,8);     %Make the starting board
    A(4,4) = 1;
    A(5,5) = 1;
    A(4,5) = 2;
    A(5,4) = 2;
    PlotDots(A)
    set(pb,'String','Start')    %Make sure to reset the main button too.
elseif strcmp(action,'about')  %display a little about box, it's really totally worthless, but I thought it was fun.
    aboutmsg=sprintf('Othello | Version 3.0\nDesigned by Kevin Claytor because the system is down.\nFor results and more examples see: http://www.owlnet.rice.edu/~kec4482/');
    msgbox(aboutmsg,'About Othello - V 3.0')
elseif strcmp(action,'rules')  %display the rules of Othello.
    rulesmsg=sprintf('Place your piece (cyan - player 1; black - player 2) with the left mouse button.\nPlacing a piece will flip all your opponent''s pieces directly connected with the piece you just placed and your other pieces horizontal, vertical, or diagonal to the piece you just placed.\nYou cannot place a piece on top of another piece or in a location where you cannot filp any pieces.\nIn the event you cannot play use mouse button 1 or 2 to pass.\n\nOthello - A minute to learn, a lifetime to master!');
    msgbox(rulesmsg,'Othello Rules')
end

return



%================
%Plots the current state of the game
%================
function PlotDots(A)

whiteloc=[];                    %Initialize
blackloc=[];
cla;                            %Clear the figure
for j = 1:length(A)
    for k = 1:length(A)
        if A(j,k) == 1
            whiteloc(j,k) = 1;     %Find the white pieces
        end
        if A(j,k) == 2
            blackloc(j,k) = 1;     %Find the black pieces
        end
    end
end
[x,y]=find(whiteloc);              %Assign the pieces to special matricies
[u,v]=find(blackloc);
hold on                         %Don't reset the current axis
plot(x,y,'c.','markersize',80)  %And plot
plot(u,v,'k.','markersize',80)
drawnow;

return


%================
%A function that checks to make sure that the player's click is legal
%================
function [h,j]=getClick(A,color)

olperror = findobj(gcf,'Tag','Overlap');
nullerror = findobj(gcf,'Tag','Null');
%   Find where we clicked
[x,y,button] = ginput(1);   % get the x and y position of the mouse and
%    also what button was pressed.
h = round(x);               % round off the input to fit in the matrix
j = round(y);
if button==2||button==3     %We pass if we don't left click
    h=[]; j=[];
else                        %do the check, if we fail the call ourselves again
    if A(h,j)~=0
        set(olperror,'Visible','on')
        [h,j]=getClick(A,color);
        set(olperror,'Visible','off')
    end
    [Newboard,value]=OthelloFlip(A,color,h,j);
    if value==0
        set(nullerror,'Visible','on')
        [h,j]=getClick(A,color);
        set(nullerror,'Visible','off')
    end
end

return

%Function OthelloCore
% Kevin Claytor
% July 22-30, 2006
%
% OthelloCore.m
% Usage
%    [Move,value]OthelloCore(Game,depth)
%
% Computes the next move in a game of othello.  Given a starting board
%   (Game) and the knowledge of how far down you want to go recursively
%   (depth) it returns the next move it wants to take (Move) and the value
%   that the computer gains from such a move (mainly for the recursion).
%
% For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Game - the input matrix that tells us what the current game looks like.
%   difficulty - an edge / corner value multiplier.
%   depth - how far down we want to go recursively.
%   color - which color we should play as (useful for calculating future moves).
%   compx,compy - the highest value move, and the one the computer will make.
%   value - the value of the move.
%   pass - if we can't make any legal moves, go ahead and pass (1).
%

%Pseudocode
%
% 1 - Find all of the elements that border our current game state
%     - for each nonzero element check the elements that border it and see
%       if their value is nonzero.
% 2 - Figure out how effective it is to play there (if difficulty is some such we call
%       ourselves to see what happens difficulty moves in the future)
% 3 - Store this in a list
% 3 - Choose the first move in the list that has the highest value (stupid max function, no randomness)
%

function [compx,compy,value,pass]=OthelloCore(Game,difficulty,depth,color)

if depth==0 %if we've reached the bottom of recursion just return
    pass=0;
    value=0;
    compx=0;
    compy=0;
    return
end

[i,j,v]=find(Game);         %get info from our gameboard on the nonzero elements
Possiblemoves=[];           %initialize our possible moves
pass=0;                     %we don't want to not pass by accident

%Set up the recursion specific variables
newGame = Game; %we start with the current gameboard
switch color    %the next time we want to play the other color's piece
    case 1
        newcolor=2;
    case 2
        newcolor=1;
end
nextvalue=0;    %initialize our next value
nextpass=0;     %and initialize our next pass

for k = 1:length(v);                        %for every occupied element
    x = i(k)-1; y = j(k);                   %find a spot that borders an occupied spot
    if (x>0)&(x<9)&(y>0)&(y<9)              %make sure it falls within the current board
        if Game(x,y)==0                     %if that spot's open then
            [state,value]=OthelloFlip(Game,2,x,y);  %see what value we get for putting our dude there
            if (value~=0)                   %if it's >0 then store it in a list
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)   %A corner piece
                    value = value + 3*difficulty;   %Increase the value of corner plays, but only if it's a legal move
                elseif (x==0)||(x==8)||(y==0)||(y==8)                       %An edge piece
                    value = value + 2*difficulty;   %Increase the value of edge plays, but only if legal
                end
                newGame(x,y) = color;               %Change our element
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);  %play the next move
                if (nextpass~=0)  %If we don't pass
                    value = value + nextvalue;          %figure out the value with the best of the next move
                end
                Possiblemoves=[Possiblemoves;x,y,value];%add to the list of possible moves
            end
        end
    end
    %And do it all over for all the other bordering pieces (7)
    x = i(k)-1; y = j(k)+1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k); y = j(k)+1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k)+1; y = j(k)+1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k)+1; y = j(k);
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k)+1; y = j(k)-1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k); y = j(k)-1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
    x = i(k)-1; y = j(k)-1;
    if (x>0)&(x<9)&(y>0)&(y<9)
        if Game(x,y)==0
            [state,value]=OthelloFlip(Game,2,x,y);
            if (value~=0)
                if (x==0&&y==0)||(x==0&&y==8)||(x==8&&y==0)||(x==8&&y==8)
                    value = value + 3*difficulty;
                elseif (x==0)||(x==8)||(y==0)||(y==8)
                    value = value + 2*difficulty;
                end
                newGame(x,y) = color;
                [nextx,nexty,nextvalue,nextpass]=OthelloCore(newGame,difficulty,depth-1,newcolor);
                if (nextpass~=0)
                    value = value + nextvalue;
                end
                Possiblemoves=[Possiblemoves;x,y,value];
            end
        end
    end
end         %ends the for loop that builds our vector of possible moves

if length(Possiblemoves)==0     %if we can't move set it up so we pass.
    pass=1;
    value=0;
    compx=0;
    compy=0;
    return
end
[value,row]=max(Possiblemoves(:,3));    %look through the value col and find the greatest one
switch color
    case 1                  %If we're playing white's piece the value should be negative
        value = -value;
    case 2                  %If we're playing our piece we'll take a positive value
        value = value;
end
compx = Possiblemoves(row,1);           %Return the coordinates of our move
compy = Possiblemoves(row,2);

return

%Function OthelloFlip
% Kevin Claytor
% July 22-30, 2006
%
% OthelloFlip.m
% Usage
%    Flip=OthelloFlip(Game,color,x,y)
%
% Looks at the current matrix, figures out what pieces we need to flip and
%   flips them
%
% For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Game - the input matrix that tells us what the current game looks like.
%   color - what color is being put down so we can flip the others.
%   x,y - the coordinates of the piece that was just put down.
%   FlipGame - the new game board after we've flipped the pieces.
%   value - the value of the next move (# pieces flipped) - for computer purposes.
%

%Pseudocode
%
% 1 - Look through all the filled spaces for our (color) pieces
% 2 - For every piece see if it's in the same row, column, or on the
%        diagonal
%     - Find all the pieces between our piece (x,y) and our like color
% 3 - If those pieces are continous and the other color
% 4 - Then flip them to our color
%

function [FlipGame,value]=OthelloFlip(Game,color,x,y)

[i,j,v]=find(Game);     %find the nonzero elements
flipvec=[];             %initialize counters
value=0;

for k = 1:length(v)
    if v(k) == color
        if i(k) == x                %they're in the same row
            flipvec=[]; u=[]; b=[]; %re-initialize flipvec because we use it over and over, and do the same for u and b, the x and y coords of the pieces to flip
            if y > j(k)
                flipvec=Game(x,j(k)+1:y-1);
                for r = j(k)+1:y-1
                    u=[u;x]; b=[b;r];
                end
            else
                flipvec=Game(x,y+1:j(k)-1);
                for r = y+1:j(k)-1
                    u=[u;x]; b=[b;r];
                end
            end
            if (length(intersect(flipvec,0))==0)&&(length(intersect(flipvec,color))==0)   %if it's a continuous strip and doesn't contain our color
                Game=Flip(Game,u,b,color);      %flip the elements
                value=value+length(flipvec);    %and add the number of elements flipped to the score value
            end
        end
        if j(k) == y               %they're in the same column
            flipvec=[]; u=[]; b=[];
            if x > i(k)
                flipvec=Game(i(k)+1:x-1,y);
                for r = i(k)+1:x-1
                    u=[u;r]; b=[b,y];
                end
            else
                flipvec=Game(x+1:i(k)-1,y);
                for r = x+1:i(k)-1
                    u=[u;r]; b=[b;y];
                end
            end
            if (length(intersect(flipvec,0))==0)&&(length(intersect(flipvec,color))==0)   %if it's a continuous strip
                Game=Flip(Game,u,b,color);      %flip the elements
                value=value+length(flipvec);    %and add the number of elements flipped to the score value
            end
        end
        if abs(x-i(k))==abs(y-j(k))   %they're on the same diagonal
            flipvec=[]; u=[]; b=[];
            if (i(k)>x)&&(j(k)>y)
                for r = x+1:i(k)-1
                    t = abs(r-x)+y;
                    flipvec=[flipvec;Game(r,t)];
                    u=[u;r]; b=[b;t];
                end
            elseif (i(k)>x)&&(j(k)<y)
                for r = x+1:i(k)-1
                    t = y-abs(r-x);
                    flipvec=[flipvec;Game(r,t)];
                    u=[u;r]; b=[b;t];
                end
            elseif(i(k)<x)&&(j(k)>y)
                for r = i(k)+1:x-1
                    t = abs(r-x)+y;
                    flipvec=[flipvec;Game(r,t)];
                    u=[u;r]; b=[b;t];
                end
            else%%(i(k)<x)&&(j(k)<y)
                for r = i(k)+1:x-1
                    t = y-abs(r-x);
                    flipvec=[flipvec;Game(r,t)];
                    u=[u;r]; b=[b;t];
                end
            end
            if (length(intersect(flipvec,0))==0)&&(length(intersect(flipvec,color))==0)   %if it's a continuous strip
                Game=Flip(Game,u,b,color);      %flip the elements
                value=value+length(flipvec);    %and add the number of elements flipped to the score value
            end
        end
    end
end
Game(x,y)=color;                %Now update with the piece we just placed
FlipGame=Game;                  %And return the new flipped gameboard
return


function Game=Flip(Game,u,b,color)  %Flip the colors we want.
for k = 1:length(u)                 %for every element in u
    if color == 1                   %set it to our color, whatever that may be
        Game(u(k),b(k)) = 1;
    end
    if color == 2
        Game(u(k),b(k)) = 2;
    end
end
return