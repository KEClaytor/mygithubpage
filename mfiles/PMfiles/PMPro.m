%Function PMDemo
% Kevin Claytor
% LANL EES-GEO
% Update History
% 8-10-2006 - Finished Rev 1
% 5-18-2007 - KEC
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

function PMPro(action)

global pmspace stressprotocol havestress maxstress Protocol Strain myPM

if nargin<1                                 % If we are just called
    action = 'initialize';                  %  then set up for a run
end


if strcmp(action,'initialize')
pmspace = 0;                % For making sure we have everything we need to run.
stressprotocol = 0;
    maintitle='PM Space Professional Version';  % Title our graph, use a variable that we can later change
    figure('Name',maintitle,...
           'Menubar','none',...
           'Position',[142 142 700 550],...
           'NumberTitle','off', ...
	       'DoubleBuffer','on');   % turn off that flickering
       
%Create, clear and label our subplots
          subplot(2,2,1), cla; xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');
          subplot(2,2,2), cla; xlabel('Stress'); ylabel('Strain'); title('Stress-Strain Curve');
          subplot(2,2,4), cla; xlabel('Time'); ylabel('Stress'); title('Stress Protocol');
% Buttons to enlarge the graphs
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[285 500 70 20],... % Position in pixel units
              'Callback','PMPro(''bigpm'')',... % What clicking on the button does
              'Tag','BigPM');              % Control name% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Density',...  % Initial label on button
              'Position',[285 480 70 20],... % Position in pixel units
              'Callback','PMPro(''denspm'')',... % What clicking on the button does
              'Tag','DensPM');              % Control name% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[600 500 70 20],... % Position in pixel units
              'Callback','PMPro(''bigss'')',... % What clicking on the button does
              'Tag','BigSS');              % Control name% A button to auto-run a demo version
    uicontrol('Style','PushButton',...
              'String','Enlarge',...  % Initial label on button
              'Position',[600 240 70 20],... % Position in pixel units
              'Callback','PMPro(''bigts'')',... % What clicking on the button does
              'Tag','BigTS');              % Control name

% Buttons to make a PM space by hand
% PM space options
% Frame the options
    uicontrol('Style','Frame',...           % Boring text box
              'Position',[5 115 160 150],...
              'Tag','PM_Label');
% A title
    uicontrol('Style','Text',...
              'String','PM Space Options',...
              'Position',[10 250 120 20],...
              'Tag','PM_Text');
% Pop-up options
    uicontrol('Style','Popupmenu',...
              'String','Random Distribution|Normal Random|Guyer Population 1|Guyer Nc Population|Diagonal Only|Normal Diagonal|Linear Falloff|Vlad/Koen',...
              'Position',[10 220 150 30],...
              'Tag','Popup');
% A text box for Nc
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[10 205 50 20],...
              'Tag','Nc');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Nc',...
              'Position',[60 205 30 20],...
              'Tag','Nc_Label');   
% A text box for the max stress
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','25',...
              'Position',[10 185 50 20],...
              'Tag','Max');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Max stress',...
              'Position',[60 185 60 20],...
              'Tag','MS_Label');   
% A text box for the max stress
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','300',...
              'Position',[10 165 50 20],...
              'Tag','Elements');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Number of Elements',...
              'Position',[60 165 100 20],...
              'Tag','Ele_Label');
%THE GENERATOR BUTTONS
%Generate the PM space now
    uicontrol('Style','PushButton',...
              'String','Populate PM Space',...
              'Position',[10 140 130 20],...
              'Callback','PMPro(''pmspace'')',...
              'Tag','PopulatePM');
%Stress Protocol creator
    uicontrol('Style','PushButton',...
              'String','Create Stress Protocol',...  % Initial label on button
              'Position',[10 120 130 20],...
              'Callback','PMPro(''stress'')',...
              'Tag','Stress');
          
%Inversion options
% Frame the options
    uicontrol('Style','Frame',...           % Boring text box
              'Position',[195 45 140 80],...
              'Tag','Inv_Label');
% Title this sub-group
    uicontrol('Style','Text',...           % Boring text box
              'String','Inversion Options',...
              'Position',[200 110 110 20],...
              'Tag','Inv_Label');
% A text box for Ds
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','5',...
              'Position',[200 90 50 20],...
              'Tag','Ds');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Shift resolution',...
              'Position',[250 90 80 20],...
              'Tag','Ds_Label');
% A text box for Loops
    uicontrol('Style','Edit',...           % Humm... the edit text box
              'min',2,...
              'max',3,...
              'String','16',...
              'Position',[200 70 50 20],...
              'Tag','Loops');
% Text to title the edit text box
    uicontrol('Style','Text',...           % Boring text box
              'String','Invert N times',...
              'Position',[250 70 80 20],...
              'Tag','Loops_Label');
% Toggle finer resolution
    uicontrol('Style','Checkbox',...
              'String','Constant (1 unit) shifts',...
              'Position',[200 50 130 20],...
              'Tag','Constant');
          
%SAVE AND LOAD BUTTONS
% Frame the buttons
    uicontrol('Style','Frame',...           % Boring text box
              'Position',[195 145 110 120],...
              'Tag','PM_Label');
% A title
    uicontrol('Style','Text',...
              'String','File Options',...
              'Position',[200 250 90 20],...
              'Tag','PM_Text');
%Save PM space
    uicontrol('Style','PushButton',...
              'String','Save PM Space',...
              'Position',[200 230 100 20],...
              'Callback','PMPro(''savepm'')',...
              'Tag','SavePM');
%Load PM space
    uicontrol('Style','PushButton',...
              'String','Load PM Space',...
              'Position',[200 210 100 20],...
              'Callback','PMPro(''loadpm'')',...
              'Tag','LoadPM');
%Save the stress-strain curve
    uicontrol('Style','PushButton',...
              'String','Save Strain Curve',...
              'Position',[200 190 100 20],...
              'Callback','PMPro(''savess'')',...
              'Tag','SaveSS');
%Load the stress protocol
    uicontrol('Style','PushButton',...
              'String','Load Strain Curve',...
              'Position',[200 170 100 20],...
              'Callback','PMPro(''loadss'')',...
              'Tag','LoadSS');
%Load the stress protocol
    uicontrol('Style','PushButton',...
              'String','Load Protocol Only',...
              'Position',[200 150 100 20],...
              'Callback','PMPro(''loadproc'')',...
              'Tag','LoadProc');
          
% Frame the controls
    uicontrol('Style','Frame',...           % Boring text box
              'Position',[5 18 140 90],...
              'Tag','PM_Label');
%THE REAL START BUTTON
    uicontrol('Style','PushButton',...
              'String','Run!',...  % Initial label on button
              'Position',[10 60 65 45],...
              'Callback','PMPro(''start'')',...
              'Tag','Start');
% Movies!!
    uicontrol('Style','Checkbox',...
              'String','Movie',...
              'Position',[10 40 65 20],...
              'Tag','RunMovie');
          
%INVERT PM SPACE!!
    uicontrol('Style','PushButton',...
              'String','Invert!',...  % Initial label on button
              'Position',[80 60 60 45],...
              'Callback','PMPro(''invert'')',...
              'Tag','Start');
% Movies!!
    uicontrol('Style','Checkbox',...
              'String','Movie',...
              'Position',[80 40 60 20],...
              'Tag','InvMovie');
% Fast Inversion
    uicontrol('Style','Checkbox',...
              'String','Fast',...
              'Position',[80 20 60 20],...
              'Tag','Fast',...
              'Value',1);

% An about dialouge
    uicontrol('Style','PushButton',...
              'String','About',...
              'Position',[10 20 60 20],...
              'Callback','PMPro(''about'')',... % give our about message
              'Tag','About');
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
              case 8
                  myPM=generatePMspace(numelements,maxstress,8,0);
          end
          pmspace=1;        % Record that we have a PM space
          %Reinitialize the subplots
          subplot(2,2,1), cla;
          subplot(2,2,1), plot(myPM(:,1),myPM(:,2),'kd'); xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');   %and plot it
          drawnow
elseif strcmp(action,'stress')
    Protocol = generateStress(maxstress);               % Generate the stress-strain protocol
    close('Stress Protocol Creator');
    stressprotocol=1;                                   %Record that we have a stress protocol
    subplot(2,2,4), cla;                    %Clear our stress subplot
    subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'k'); xlabel('Time'); ylabel('Stress'); title('Stress Protocol')   %  and plot it
    drawnow
%=================================
%THE GUTS - THE CUSTOM RUN PROGRAM
elseif strcmp(action,'start')
    mov = get((findobj(gcf,'Tag','RunMovie')),'Value');
    %do some checks to make sure we have somthing to run.
    if pmspace == 0
        msgbox('Populate PM Space first!','Oops!');
        return
    end
    if stressprotocol == 0;
        msgbox('Make a Stress Protocol first!','Oops!');
        return
    end
    %Now get the data and display
    Strain=[];                                      %Initialize our strain vector
    hold on                                         %Don't ditch this window
    if mov==0       %No movie, just get the strain
        Strain = getStrain(myPM,Protocol,length(Protocol),1);   %get the strain curve
    elseif mov==1       %make a movie!!
        Strain = getStrainMov(myPM,Protocol,length(Protocol),1);
    end
    subplot(2,2,2), cla; plot(Protocol(:,2),Strain,'g');    %Plot the strain on a subplot
    subplot(2,2,4), cla; plot(Protocol(:,1),Protocol(:,2),'r')   %Plot the stress protocol

%==============================================
%GUTS II - INVERTING A SS CURVE TO GET PM SPACE
elseif strcmp(action,'invert')
    %Do all the checks from pmspace to use THIS as our initial PM space
    pp = findobj(gcf,'Tag','Popup');
    no = findobj(gcf,'Tag','Nc');
    ms = findobj(gcf,'Tag','Max');
    el = findobj(gcf,'Tag','Elements');
    re = findobj(gcf,'Tag','Ds');
    lp = findobj(gcf,'Tag','Loops');
    cn = findobj(gcf,'Tag','Constant');
    fst = findobj(gcf,'Tag','Fast');
    mov = get((findobj(gcf,'Tag','InvMovie')),'Value');
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
            myPM=generatePMspace(numelements,maxstress,6,0);
        case 3
            myPM=generatePMspace(numelements,maxstress,2,0);
        case 4
            myPM=generatePMspace(numelements,maxstress,3,nc);
        case 5
            myPM=generatePMspace(numelements,maxstress,4,0);
        case 6
            myPM=generatePMspace(numelements,maxstress,5,0);
    end
    ds=str2double(get(re,'String'));  % The max stress we go to
    if isnan(ds)  %Give an error and reset if the user input anything other than a number
        errordlg('Stress resolution MUST be a NUMBER greater than zero','Bad Input','modal')
        set(re,'String','5')  %reset
        return
    end
    if ds<0  %Give an error and reset if the user input anything other than a number
        errordlg('Stress resolution MUST be a number greater than zero!','Bad Input','modal')
        set(re,'String','5')  %reset
        return
    end
    loops=str2double(get(lp,'String'));  % The max stress we go to
    if isnan(loops)  %Give an error and reset if the user input anything other than a number
        errordlg('Itteration loops MUST be a NUMBER greater than zero','Bad Input','modal')
        set(lp,'String','16')  %reset
        return
    end
    if loops<0  %Give an error and reset if the user input anything other than a number
        errordlg('Itteration loops MUST be a number greater than zero!','Bad Input','modal')
        set(lp,'String','16')  %reset
        return
    end
    if havestress == 0
        msgbox('Load a Stress-Strain curve first!','Oops!');
        return
    end
    cs=get(cn,'Value');
    fast=get(fst,'Value');
    %Now we have a stress strain curve, as well as a starting PM space
    if mov==1               %run the fast calculator and make a movie
        myPM=invertPMproMov(myPM,maxstress,ds,loops,cs);
    elseif mov==0
        if fast==1          %run the fast strain calculator
            myPM=invertPMpro(myPM,maxstress,ds,loops,cs);
        elseif fast==0      %run the full strain calculator
            myPM=invertPMprofull(myPM,maxstress,ds,loops,cs);
        end
    end
    pmspace=1;              %record that we have a pm space (if we want to run this later)
    subplot(2,2,1), cla;    %redraw PM space
    subplot(2,2,1), plot(myPM(:,1),myPM(:,2),'kd'); xlabel('Closing Pressure'); ylabel('Opening Pressure'); title('P-M Space');
    ylabel('Opening Pressure'); title('P-M Space');
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
elseif strcmp(action,'savess')  %save the time, stress, and strain space data under a default name.
    StrainData = [Protocol,Strain];
    save StrainCurve StrainData;
    msgbox('Data saved as StrainCurve.mat to the local folder.','Save Successful');
elseif strcmp(action,'loadss')  %load the stress and strain data.
    load StrainCurve;
    Protocol = StrainData(:,1:2);
    Strain = StrainData(:,3);
    havestress=1;               %A marker for invert
    stressprotocol=1;
    subplot(2,2,4), cla;        %Redraw the stress protcol subplot
    subplot(2,2,4), plot(Protocol(:,1),Protocol(:,2),'r'); xlabel('Time'); ylabel('Stress'); title('Stress Protocol');
    subplot(2,2,2), cla;        %Redraw the stress-strain subplot
    subplot(2,2,2), plot(Protocol(:,2),Strain,'r'); xlabel('Stress'); ylabel('Strain'); title('Stress-Strain Curve');
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
    set(gca,'FontSize',14);
    plot(myPM(:,1),myPM(:,2),'r.');
    xlabel('Closing Stress');
    ylabel('Opening Stress');
    title('P-M Space');
elseif strcmp(action,'denspm')  %we want a grayscale PM density
    pmDensity(myPM)
elseif strcmp(action,'bigss')   %we want to enlarge the stress-strain graph
    figure('Name','Stress Strain Curve','NumberTitle','off');
    set(gca,'FontSize',14);
    plot(Protocol(1:length(Strain),2),Strain);
    xlabel('Stress');
    ylabel('Strain');
    title('Stress-Strain Curve');
elseif strcmp(action,'bigts')   %we want to enlarge the time-stress graph
    figure('Name','Stress Protocol','NumberTitle','off');
    set(gca,'FontSize',14);
    plot(Protocol(:,1),Protocol(:,2));
    xlabel('Time');
    ylabel('Stress');
    title('Stress Protocol');
%=================
%AMUSING ABOUT BOX
elseif strcmp(action,'about')  %display a little about box, it's really totally worthless, but I thought it was fun.
    aboutmsg=sprintf('PM Space Professional Edition | Version 2.0\nDesigned by Kevin Claytor for LANL | EES-GEO\nFor results and more examples see: http://www.owlnet.rice.edu/~kec4482/\nThis software is freeware and should be distributed without charge.');
    msgbox(aboutmsg,'About PM Space Professional')
end
