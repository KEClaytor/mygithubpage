%Function PMDemo
% Kevin Claytor
% LANL EES-GEO
% July 22, 2006
%
% PMDemo.m
% Usage
%    PMDemo(action)
%
% Launches a GUI (if called empty) that then accesses generatePMspace and
%    generateStress to make a PM space an walk through it according to
%    a Protocol.  Clicking demo will launch a demo using a random PM space
%    and a pre-stored stress protocol.  Clicking Run will run a custom PM
%    space and a custom stress protocol (but requires the two subfunctions
%    to be run before it does).
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Global vars:
%   myPM - the result of generatePMspace
%   Protocol - The stress protcol (from generateStress)
%   maxstress - global to be referred to throughout
%   Strain - an nx2 matrix (first column - time, second strain) that
%      records the strain history of the rock
%   Local vars:
%   state - which mode are we going to run generatePMspace in?
%   nc - for mode 3 of generatePMspace - moves the distribution
%   time - how long the stress protcol is
%   pressure - the current pressure of the stress protcol.  It's compared
%      to the opening and closing pressures of the HEUs to determine if
%      they should switch state.
%   numelements - how many HEUs there are
%   dl - used for calculating strain (dl/l) where dl is the fraction of
%      elements closed
%   l - the randomly chosen length of the sample, higher values give
%      smaller strains
%

%Pseudocode (includes subfunction pseudocode)
% Matlab psuedocode for a Preisach model
%
% 1 - Initialize our array of PM elements
%     - Loop of 1:n elements
%     - Generate a (rounded) random number between 0 and max pressure
%     - Call that number the closing pressure
%     - loop generating another (rounded) random number until we get one
%       that's smaller than our previous one.
%     - Store these numbers in an array - keep an extra column to
%       keep track of which elements are open and which are closed
%     - Plot the resulting PM space
% 2 - Find the Stress protocol
%     - Initialize (0,0) as a starting point
%     - Let the user click a new point
%     - Fill in the points in between
%     - Store the points
%     - Find the final point and do the same
%     - Return
% 3 - Start running through the stress protocol
%     - Look at our current stress
%     - Find all the elements that close at that stress
%     - Close them if they're open
%     - Find all the elements that open at that stress
%     - Open them if they're closed
%       **Make sure the history is recoreded**
%     - Calculate our new length
%     - And store in a new array
% 4 - Plot stress versus strain
%     - And anything else that could be of value

function PMDemo(action)

global pmspace stressprotocol myPM Protocol maxstress Strain

if nargin<1                                 % If we are just called
    action = 'initialize';                  %  then set up for a run
end


if strcmp(action,'initialize')
pmspace = 0;                % For making sure we have everything we need to run.
stressprotocol = 0;
    maintitle='PM Space Demo';  % Title our graph, use a variable that we can later change
    figure('Name',maintitle,...
           'Menubar','none',...
           'NumberTitle','off', ...
	       'DoubleBuffer','on');   % turn off that flickering
       
%Create, clear and label our subplots
          subplot(2,2,1), cla; xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');
          subplot(2,2,2), cla; xlabel('Stress'); ylabel('Strain'); title('Stress Strain');
          subplot(2,2,4), cla; xlabel('Time'); ylabel('Stress'); title('Stress Protocol');
% Buttons to enlarge the graphs
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[220 390 70 20],... % Position in pixel units
              'Callback','PMDemo(''bigpm'')',... % What clicking on the button does
              'Tag','BigPM');              % Control name% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[470 390 70 20],... % Position in pixel units
              'Callback','PMDemo(''bigss'')',... % What clicking on the button does
              'Tag','BigSS');              % Control name% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[470 195 70 20],... % Position in pixel units
              'Callback','PMDemo(''bigts'')',... % What clicking on the button does
              'Tag','BigTS');              % Control name

% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Demo',...  % Initial label on button
              'Position',[10 30 80 50],... % Position in pixel units
              'Callback','PMDemo(''demo'')',... % What clicking on the button does
              'Tag','Demo');              % Control name
% Buttons to make one by hand

%PM space options
% Pop-up options
    uicontrol('Style','Popupmenu',...
              'String','Random Distribution|Normal Random|Guyer Population 1|Guyer Nc Population|Diagonal Only|Normal Diagonal|Linear Falloff',...
              'Position',[10 170 150 30],...
              'Tag','Popup');
% A text box for Nc
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[10 155 50 20],...
              'Tag','Nc');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Nc',...
              'Position',[60 155 30 20],...
              'Tag','Nc_Label');   
% A text box for the max stress
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','25',...
              'Position',[10 135 50 20],...
              'Tag','Max');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Max stress',...
              'Position',[60 135 60 20],...
              'Tag','MS_Label');   
% A text box for the max stress
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','300',...
              'Position',[10 115 50 20],...
              'Tag','Elements');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Number of Elements',...
              'Position',[60 115 100 20],...
              'Tag','Ele_Label');
          
%THE GENERATOR BUTTONS
%Generate the PM space now
    uicontrol('Style','PushButton',...
              'String','Populate PM Space',...
              'Position',[10 90 120 20],...
              'Callback','PMDemo(''pmspace'')',...
              'Tag','PopulatePM');
%Stress Protocol creator
    uicontrol('Style','PushButton',...
              'String','Create Stress Protocol',...  % Initial label on button
              'Position',[140 90 130 20],...
              'Callback','PMDemo(''stress'')',...
              'Tag','Stress');
          
%SAVE AND LOAD BUTTONS
%Save PM space
    uicontrol('Style','PushButton',...
              'String','Save PM Space',...
              'Position',[165 175 100 20],...
              'Callback','PMDemo(''savepm'')',...
              'Tag','SavePM');
%Load PM space
    uicontrol('Style','PushButton',...
              'String','Load PM Space',...
              'Position',[165 155 100 20],...
              'Callback','PMDemo(''loadpm'')',...
              'Tag','LoadPM');
%Save the stress-strain curve
    uicontrol('Style','PushButton',...
              'String','Save Strain Curve',...
              'Position',[165 135 100 20],...
              'Callback','PMDemo(''savess'')',...
              'Tag','SaveSS');
%Load the stress protocol
    uicontrol('Style','PushButton',...
              'String','Load Protocol',...
              'Position',[165 115 100 20],...
              'Callback','PMDemo(''loadproc'')',...
              'Tag','LoadProc');
          
%THE REAL START BUTTON
    uicontrol('Style','PushButton',...
              'String','Run!',...  % Initial label on button
              'Position',[100 30 80 50],...
              'Callback','PMDemo(''start'')',...
              'Tag','Start');

% An about dialouge
    uicontrol('Style','PushButton',...
              'String','About',...
              'Position',[10 1 50 15],...
              'Callback','PMDemo(''about'')',... % give our about message
              'Tag','About');
%===========
%DEMO MODE!!
elseif strcmp(action,'demo')
          %Reinitialize the subplots
          subplot(2,2,1), cla; xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');
          subplot(2,2,2), cla; xlabel('Stress'); ylabel('Strain'); title('Stress Strain');
          subplot(2,2,4), cla; xlabel('Time'); ylabel('Stress'); title('Stress Protocol');
          numelements = 300;        %Set some defaults
          maxstress = 25;
          state = 1;
          nc = 0;
          myPM=generatePMspace(numelements,maxstress,state,nc);     % Generate our PM space
          Protocol = generateStress(25,'demo');                     % Generate the stress-strain protocol
          time = length(Protocol);                                  %   using the prestored demo value
          Strain=[];                  %Initialize our strain vector
          hold on                     %Don't ditch this window
          for i = 1:time
              pressure=Protocol(i,2); % Find the current pressure
              %initialize our closed and open matricies every time, because
              %  then we can graph them and get a good idea of what's going
              %  on as it happens!
              Open=[];
              Closed=[];
              for j = 1:numelements
                  if pressure > myPM(j,1)         %if the pressure is higher than the closing pressure close it if it's open
                      if myPM(j,3) == 0
                          myPM(j,3) = 1;
                      end
                  elseif pressure < myPM(j,2)     %if the pressure is lower than the opening pressure open it if it's closed
                      if myPM(j,3) == 1
                          myPM(j,3) = 0;
                      end
                  end
              end
              
              for k = 1:numelements
                  if myPM(k,3)==1
                      Closed=[Closed;myPM(k,:)];
                  else
                      Open=[Open;myPM(k,:)];
                  end
              end
              
              if length(Open) ~= 0
                  subplot(2,2,1), plot(Open(:,1),Open(:,2),'rd');
                  hold on
              end
              if length(Closed) ~= 0
                  subplot(2,2,1), plot(Closed(:,1),Closed(:,2),'bd');
              end
              dl = length(Closed)/numelements;    %find the strain
              Strain = [Strain;dl];           %record the strain
              subplot(2,2,2), plot(Protocol(1:length(Strain),2),Strain,'g-'); axis([0 maxstress 0 1]);  %Plot the strain on a subplot
              subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'r')                                     %Plot the stress protocol
              subplot(2,2,4), plot(Protocol(1:length(Strain),1),Protocol(1:length(Strain),2),'b')       %Plot the current position of the stress protocol
              pause(0.1);                         % wait,
              drawnow                             % draw,
          end                                     % and move on to the next time step
%=====================================
%MAKING CUSTOM PM SPACES AND PROTOCOLS    
elseif strcmp(action,'pmspace')
          pp = findobj(gcf,'Tag','Popup');
          no = findobj(gcf,'Tag','Nc');
          ms = findobj(gcf,'Tag','Max');
          el = findobj(gcf,'Tag','Elements');
          maxstress=str2double(get(ms,'String'));  % The max stress we go to
          if isnan(maxstress)  %Give an error and reset if the user input anything other than a number
              errordlg('Max stress MUST be a NUMBER greater than zero','Bad Input','modal')
              set(ms,'String','25')  %reset
              return
          end
          if maxstress<0  %Give an error and reset if the user input anything other than a number
              errordlg('Max stress MUST be a number greater than zero!','Bad Input','modal')
              set(ms,'String','25')  %reset
              return
          end
          nc=str2double(get(no,'String'));
          if isnan(nc)  %Give an error and reset if the user input anything other than a number
              errordlg('Nc MUST be a NUMBER equal or greater than zero','Bad Input','modal')
              set(no,'String','0')  %reset
              return
          end
          if maxstress<0  %Give an error and reset if the user input anything other than a number
              errordlg('Nc MUST be a number equal or greater than zero!','Bad Input','modal')
              set(no,'String','0')  %reset
              return
          end
          numelements=str2double(get(el,'String'));
          if isnan(nc)  %Give an error and reset if the user input anything other than a number
              errordlg('The number of elements MUST be greater than zero!','Bad Input','modal')
              set(no,'String','0')  %reset
              return
          end
          if maxstress<=0  %Give an error and reset if the user input anything other than a number
              errordlg('The number of elements MUST be greater than zero!','Bad Input','modal')
              set(no,'String','0')  %reset
              return
          end
          switch get(pp,'Value')
              case 1
                  myPM=generatePMspace(numelements,maxstress,1,0);
              case 2
                  myPM=generatePMspace(numelements,maxstress,2,0);
              case 3
                  myPM=generatePMspace(numelements,maxstress,3,0);
              case 4
                  myPM=generatePMspace(numelements,maxstress,4,nc);
              case 5
                  myPM=generatePMspace(numelements,maxstress,5,0);
              case 6
                  myPM=generatePMspace(numelements,maxstress,6,0);
              case 7
                  myPM=generatePMspace(numelements,maxstress,7,0);
          end
          pmspace=1;        % Record that we have a PM space
          %Reinitialize the subplots
          subplot(2,2,1), cla;
          subplot(2,2,1), plot(myPM(:,1),myPM(:,2),'kd'); xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');   %and plot it
          drawnow
elseif strcmp(action,'stress')
    if pmspace == 0
        msgbox('Populate PM Space first!','Oops!');
    end
    Protocol = generateStress(maxstress);               % Generate the stress-strain protocol
    close('Stress Protocol Creator');
    stressprotocol=1;                                   %Record that we have a stress protocol
    subplot(2,2,4), cla;                    %Clear our stress subplot
    subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'k'); xlabel('Time'); ylabel('Stress'); title('Stress Protocol')   %  and plot it
    drawnow
%=================================
%THE GUTS - THE CUSTOM RUN PROGRAM
elseif strcmp(action,'start')
    %Clear the second plot
    subplot(2,2,2), cla; xlabel('Stress'); ylabel('Strain'); title('Stress Strain');
    if pmspace == 0
        msgbox('Populate PM Space first!','Oops!');
        return
    end
    if stressprotocol == 0;
        msgbox('Make a Stress Protocol first!','Oops!');
        return
    end
    time = length(Protocol);
    numelements = length(myPM);
    Strain=[];                  %Initialize our strain vector
    hold on                     %Don't ditch this window
    for i = 1:time
        pressure=Protocol(i,2); % Find the current pressure
        %initialize our closed and open matricies every time, because
        %  it's the way I want to do it (of the several possible).
        Open=[];
        Closed=[];
        for j = 1:numelements           %Cycle through the elements CHECKING their history (current state) to see if they need to be opened or closed at this stress
            if pressure > myPM(j,1)         %if the pressure is higher than the closing pressure close it if it's open
                if myPM(j,3) == 0
                    myPM(j,3) = 1;
                end
            elseif pressure < myPM(j,2)     %if the pressure is lower than the opening pressure open it if it's closed
                if myPM(j,3) == 1
                    myPM(j,3) = 0;
                end
            end
        end
        
        for k = 1:numelements           %Add the open/closed elements to matricies dedicated to them
            if myPM(k,3)==1
                Closed=[Closed;myPM(k,:)];
            else
                Open=[Open;myPM(k,:)];
            end
        end
        
        if length(Open) ~= 0            %If we have open elements plot them - in red
            subplot(2,2,1), plot(Open(:,1),Open(:,2),'rd');
            hold on
        end
        if length(Closed) ~= 0          %if we have closed elements plot them - in blue
            subplot(2,2,1), plot(Closed(:,1),Closed(:,2),'bd');
        end
        dl = length(Closed)/numelements;    %find the strain
        Strain = [Strain;dl];           %record the strain
        subplot(2,2,2), plot(Protocol(1:length(Strain),2),Strain,'g-'); axis([0 maxstress 0 1]);    %Plot the strain on a subplot
        subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'r')                                       %Plot the stress protocol
        subplot(2,2,4), plot(Protocol(1:length(Strain),1),Protocol(1:length(Strain),2),'b')         %Plot the current position of the stress protocol
        %pause(0.1);                         %wait,
        drawnow                             % draw,
    end                                     % and move on to the next time step

%=======================
%SAVING AND LOADING DATA
elseif strcmp(action,'savepm')  %save the pm space data under a default name.
    for k=1:length(myPM)        %reset all elements to the open state
        if myPM(k,3)==1
            myPM(k,3)=0;
        end
    end
    save PMSpace myPM;
    msgbox('Data saved as PMSpace.mat to the local folder.','Save Successful');
elseif strcmp(action,'loadpm')  %load the pm space data previously saved
    load PMSpace;               %Import the data
    pmspace = 1;                %record that we have pmspace
    maxstress = max(myPM(:,1)); %record the max stress as well
    subplot(2,2,1), cla;        %Redraw the subplot
    subplot(2,2,1), plot(myPM(:,1),myPM(:,2),'kd'); xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');
elseif strcmp(action,'savess')  %save the pm space data under a default name.
    StrainData = [Protocol,Strain];
    save StrainCurve StrainData;
    msgbox('Data saved as StrainCurve.mat to the local folder.','Save Successful');
elseif strcmp(action,'loadproc')    %Load the stress profile from the strain data
    load StrainCurve;
    Protocol = StrainData(:,1:2);
    stressprotocol=1;           %record that we have a stress protocol
    subplot(2,2,4), cla;        %Redraw the subplot
    subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'r'); xlabel('time'); ylabel('Stress'); title('Stress Protocol');
%================
%ENLARGING GRAPHS
elseif strcmp(action,'bigpm')   %we want to enlarge the PM space graph
    figure('Name','PM Space','NumberTitle','off');
    plot(myPM(:,1),myPM(:,2),'r.');
    xlabel('Closing Stress');
    ylabel('Opening Stress');
    title('P-M Space');
elseif strcmp(action,'bigss')   %we want to enlarge the stress-strain graph
    figure('Name','Stress Strain Curve','NumberTitle','off');
    plot(Protocol(1:length(Strain),2),Strain);
    xlabel('Stress');
    ylabel('Strain');
    title('Stress-Strain Curve');
elseif strcmp(action,'bigts')   %we want to enlarge the time-stress graph
    figure('Name','Stress Protocol','NumberTitle','off');
    plot(Protocol(:,1),Protocol(:,2));
    xlabel('Time');
    ylabel('Stress');
    title('Stress Protocol');
%=================
%AMUSING ABOUT BOX
elseif strcmp(action,'about')  %display a little about box, it's really totally worthless, but I thought it was fun.
    aboutmsg=sprintf('PM Space Demo | Version 2.0\nDesigned by Kevin Claytor for the LANL Student Symposium 2006\nFor results and more examples see: http://www.owlnet.rice.edu/~kec4482/');
    msgbox(aboutmsg,'About PMSpace Demo')
end
