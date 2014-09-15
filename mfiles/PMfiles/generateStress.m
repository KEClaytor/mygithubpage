%Function generateStress
% Kevin Claytor
% LANL EES-GEO
% July 22, 2006
%
% generateStress.m
% Usage
%    generateStress(maxstress,action)
%
% Launches a GUI for the user to make a stres protocol
%   For use with PMDemo.m
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Protocol - an nx2 matrix that corresponds to the x-y coordinates of
%      every point on the stress protocol with the first column
%      corresponding to time and the second stress
%   action - determines if we're going to use a user determined stress
%      protocol or if we just return a stored demo protocol
%   prevx, prevy - the previous x and y values, we want to start at zero,
%      so we initialize with these values
%   x,y - the rounded valus of where the mouse is at
%   m - the slope of the line connecting (prevx,prevy) to (x,y)
%

%Pseudocode - taken from PMDemo
% 2 - Find the Stress protocol
%     - Initialize (0,0) as a starting point
%     - Let the user click a new point
%     - Fill in the points in between
%     - Store the points
%     - Find the final point and do the same
%     - Return

function Protocol=generateStress(maxstress,action)

if nargin<2                                 % Idiot proof
    action = 'initialize';                        % demo is our default case
    if nargin<1
        maxstress = 25;                     % maintain default max stress of 25
    end
end

if strcmp(action,'initialize')              % Boot up.
    figure('Name','Stress Protocol Creator',...
           'NumberTitle','off', ...
	       'DoubleBuffer','on');   % turn off that flickering
    axes
    axis([1 100 1 maxstress])                       % Remake the axis based on the maximum stress
    xlabel('Time');
    ylabel('Stress');

uicontrol('Style','Text',...            % Some instructions
          'String','Create a protocol by clicking with left mouse button.  End by clicking the right mouse button.  Do not place points in a time previous to the time of the last point.',...
          'Units','normalized',...
          'Position',[0.70,0.70,0.22,0.22],...          %in normalized units
          'Tag','G_instruct');

    % Now start clicking!
    % Start recording the clicks
    prevx=0;        %Initialize our previous x and y values
    prevy=0;
    Protocol = [prevx,prevy];   %Initialize the protocol and store the first point
    button = 1;                 %Initialize our button so we _can_ make a protocol
    while button == 1,
        [i,j,button] = ginput(1);   % get the x and y position of the mouse and
                                    %    also what button was pressed.
        x = round(i);               % round off the input
        y = round(j);
        m = (y-prevy)/(x-prevx);    %slope
        for k = (prevx+1):x                 % For the points in between the previous point and this one
            z = m*(k-prevx)+prevy;          %Point-slope version of a line
            Protocol = [Protocol;[k,z]];    % Store the location in our matrix
        end
        hold on
        plot(Protocol(:,1),Protocol(:,2),x,y,'r.','markersize',5)   % plot our point and the line that connects them
        prevx = x;                      % and update the previous location
        prevy = y;                      % and loop
    end
    
elseif strcmp(action,'demo')  %use a predetermined stress strain instead ^_^
Protocol=[0	0;0	0;1	0.83333;2	1.6667;3	2.5;4	3.3333;5	4.1667;6	5;7	5.8333;8	6.6667;9	7.5;10	8.3333;11	9.1667;12	10;13	10.833;14	11.667;15	12.5;16	13.333;17	14.167;18	15;19	15.833;20	16.667;21	17.5;22	18.333;23	19.167;24	20;25	20.833;26	21.667;27	22.5;28	23.333;29	24.167;30	25;30	25;31	24.25;32	23.5;33	22.75;34	22;35	21.25;36	20.5;37	19.75;38	19;39	18.25;40	17.5;41	16.75;42	16;43	15.25;44	14.5;45	13.75;46	13;47	12.25;48	11.5;49	10.75;50	10;50	10;51	10.5;52	11;53	11.5;54	12;55	12.5;56	13;57	13.5;58	14;59	14.5;60	15;60	15;61	14.3;62	13.6;63	12.9;64	12.2;65	11.5;66	10.8;67	10.1;68	9.4;69	8.7;70	8;71	7.3;72	6.6;73	5.9;74	5.2;75	4.5;76	3.8;77	3.1;78	2.4;79	1.7;80	1;81	0];
end