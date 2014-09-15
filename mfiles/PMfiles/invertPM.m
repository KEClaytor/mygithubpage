%Function invertPM
% Kevin Claytor
% LANL EES-GEO
% July 27, 2006
%
% invertPM.m
% Usage
%    PMSpace=invertPM(numelements,maxstress,ds,loops)
%
% Given a certain stress - strain curve it generates a random PM space and
%    shuffles it up until it get's a reasonable answer.  numelements
%    specifies how many elements the PM space should consist of, maxstress
%    is the max stress that the PM space is responsible for, and ds is the
%    resolution of changes in the PM space.  Loops tells it how many times
%    to loop and refine the PM Space, with the resolution of changes
%    governed by; dx*1/(current loop number (1:loops))
%  **Data is drawn from a file called StrainCurve where column 1 is time,
%    column 2 is stress and column 3 is strain.**
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   StrainNew - the resultant strain curve
%   PMSpace - the PM space that this function thinks will generate
%       StrainNew or something near it.
%   Strain - The orginal strain data from the file StrainCurve
%   Protocol - The stress protocol that generated Strain

%Pseudocode - a Monte Carlo method / Simulated Anealing
% 0 - Generate a PM space and a curve
%      ^-Handled in PMDemo
% 1 - Generate a random PM space
% 2 - Make a curve
% 3 - See how good it fits, and where & how it doesn't
% 4 - Modify the PM space accordingly
% 5 - Repeat steps 3 & 4 until tolerances are met
% 6 - Plot/Save and try a more complicated Stress Protocol to see if it
%      matches up.

function [PMSpace,M]=invertPM(numelements,maxstress,ds,loops)
%Initialize some variables
Strain=[];
StrainNew=[];
tol = 0;
roworcol = 0;
updown = 0;
%Do some defaulting if we wern't specified
if nargin < 4
    loops = 1;                          %default to the shortest time
    if nargin < 3
        ds = 5                          %default stress resolution to 5
        if nargin < 2
            maxstress = 25;             %The default max stress
            if nargin < 1
                numelements = 300;      %Make the default number of elements 300
            end
        end
    end
end
load StrainCurve                    %Load up the strain curve, the variable
                                    %   name is StrainData, col 1 = time
                                    %   col 2 = stress, col 3 = strain
Protocol = StrainData(:,1:2);       % The protocol drawn from the save file
Strain = StrainData(:,3);           % Strain drawn from the save file
%load PMSpace
%Strain = getStrain(myPM,Protocol);    % the new strain freshly calculated
%Initialize our percent complete bar
currentprog = waitbar(0,'Awaiting Creation of PM Space...');
%Make our random PM space
newPM = generatePMspace(numelements,maxstress,1,0);
%oriPM=newPM;       %More testing crap
%load PMSpace       %A line for testing, load a PM space and we shouldn't have to shift ANYTHING
%newPM=myPM;
figure
StrainNewFull=altStrainCalc(Protocol,newPM);
plot(Protocol(:,2),StrainNewFull,'r')
hold on
[peakStress,peakTime]=max(StrainData(:,2));     %At what time does the max stress occur and what is it?
peakTime = peakTime - 1;                        %zero correction
frmcount=0;
for k = 1:loops %Do it once fairly rough, and then do it again to smooth it.
    for j = 1:length(Protocol)                          %For every time point
        frmcount = frmcount +1;
        newPM=resetPM(newPM);                           %Make sure all elements are open
        %find out how close we come at the current point
        StrainNew=getSpecificStrain(newPM,Protocol,j);            %Get these values in the beginning
        tol = abs(StrainNew-Strain(j));
        updown=sign(StrainNew-Strain(j));            %Are we above or below
        % if we're going up we want to modify rows so roworcol = 1
        % but if we're going back we want to modify cols so roworcol = 2
        %now figure that out....
        roworcol=sign(Protocol(j,1)-peakTime);
        count = 0;                                      %Initialize our counter
        while ((tol > .001)&&(count < 10))              %Begin our loop
            newPM=resetPM(newPM);                       %Make sure all elements are open
            %check to see where we need to go the next time
            StrainNew = getSpecificStrain(newPM,Protocol,j);
            roworcol = sign(Protocol(j,1)-peakTime);    %determine if we're going to be shifting rows or cols
            updown = sign(StrainNew-Strain(j));         %See if we need to move the strain curve up or down
            tol = abs(StrainNew-Strain(j));                          %how close are we to the curve anyway
            %Shift our PM Space
            newPM = Spaceshift(newPM,maxstress,roworcol,updown,Protocol(j,2),ds,(1/k));
            count = count + 1;              %increase our counter before we forget
        end
        %%SOME DRAWING STUFF -- For movies ^_^
        %cla
        %StrainNewFull=altStrainCalc(Protocol,newPM);
        %plot(Protocol(:,2),Strain,'b')
        %plot(Protocol(:,2),StrainNewFull,'r')
        %M(:,frmcount)=getframe(gcf);
        %drawnow
        %%END DRAWING STUFF
        %figure our fraction complete
        complete = (k-1)/loops+((j/length(Protocol))/loops);
        %Update the waitbar accordingly
        waitbar(complete,currentprog,['Shifting PM Space...  ',num2str(complete*100),'% Complete']);
    end
end
close(currentprog); %we don't need the wait bar anymore
beep;               %audibly notify the user that we're done
msgbox('Matching PM Space Generated!','Done!'); %and toss in a box to make sure

PMSpace = newPM;

return

%A simple function that makes sure we start with a clean PM space each time
function newPM=resetPM(newPM)
for k=1:length(newPM)   %For every element
    if newPM(k,3)==1    %If the element is closed
        newPM(k,3)=0;   %Open it
    end
end
return