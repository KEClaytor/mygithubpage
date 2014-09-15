%Function getStrain
% Kevin Claytor
% LANL EES-GEO
% August 10, 2006
% 5-22-07 KEC; Generality increased
%
% getStrain.m
% Usage
%    getStrain(PMSpace,Protocol,time)
%
% Runs a specified stress protocol (Protocol) on a pm space (PMSpace)
%  unlike getSpecificStrain, this function does not take any shortcuts and
%  will return the full strain profile, not just the outer loops, up to
%  time.  Thus for the full strain curve send it length(Protocol) for time.
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Global vars:
%   PMSpace - the PM space we're putting through the profile
%   Protocol - The stress protocol
%   time - the length of the protocol
%   numelements - all the elements that we need to loop through
%   Strain - the returned strain curve (a vector of strain that
%      corresponds to the time)
%   Open - the open PM elements at specified time
%   Closed - the closed PM elements at specified time
%

%Pseudocode (includes subfunction pseudocode)
% Matlab psuedocode for a Preisach model
%
% 1 - 

function Strain=getStrain(PMSpace,Protocol,time,beepio)
if nargin < 4
    beepio = 0;                     %turn the damn beep off by default
    if nargin < 3
        time = length(Protocol);        %How long is this?  // set time if it's not given
    end
end
numelements = length(PMSpace);  %how many HEUs are there?
Strain=[];                      %Initialize strain
strainprog = waitbar(0,'Starting Stress Protocol...');    %initialize a waitbar
for i = 1:time
    pressure=Protocol(i,2); % Find the current pressure
    %initialize our closed and open matricies every time, because
    %  it's the way I want to do it (of the several possible).
    Open=[];
    Closed=[];
    for j = 1:numelements           %Cycle through the elements CHECKING their history (current state) to see if they need to be opened or closed at this stress
        if pressure > PMSpace(j,1)         %if the pressure is higher than the closing pressure close it if it's open
            if PMSpace(j,3) == 0
                PMSpace(j,3) = 1;
            end
        elseif pressure < PMSpace(j,2)     %if the pressure is lower than the opening pressure open it if it's closed
            if PMSpace(j,3) == 1
                PMSpace(j,3) = 0;
            end
        end
    end
    
    for k = 1:numelements           %Add the open/closed elements to matricies dedicated to them
        if PMSpace(k,3)==1
            Closed=[Closed;PMSpace(k,:)];
        else
            Open=[Open;PMSpace(k,:)];
        end
    end
    dl = length(Closed)/numelements;    %find the strain
    Strain = [Strain;dl];           %record the strain
    %figure our fraction complete
    complete = i/time;
    %Update the waitbar accordingly
    waitbar(complete,strainprog,['Running Stress Protocol...  ',num2str(complete*100),'% Complete']);
end
close(strainprog)
if beepio==1
    beep;
end
return
