%Function getSpecificStrain
% Kevin Claytor
% LANL EES-GEO
% July 27, 2006
%
% getSpecificStrain.m
% Usage
%    Strain=getSpecificStrain(PMSpace,Protocol,time)
%
% Is a fast method of getting the strain for a simple up down stress-strain
%    curve.  Looks to see what the pressure is and closes elements below
%    that pressure, ignoring the history, unless the max has already been
%    reached.
% WARING: Because of this this method CAN NOT be used for stress
%    protocols that contain inner loops as it will give false results.
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Strain - the the PM space should be at for this time of this
%       protocol strain we are at
%   PMSpace - the PM space
%   Protocol - The stress protocol that generated Strain
%   time - the current time we are along the stress protocol
%   shift - how much we want to shift our elements by
%   con - variable for constant shifting (shift = 1)

function Strain=getSpecificStrain(PMSpace,Protocol,time)
numelements = length(PMSpace);  %how many HEUs are there?
Strain=[];                      %Initialize strain
pressure=Protocol(time,2);      %Find the current pressure
[value,pos]=max(Protocol(:,2)); %Where is our max pressure?
%initialize our closed and open matricies every time, because
%  it's the way I want to do it (of the several possible).
Open=[];
Closed=[];
if time > pos                   %if we've progressed through the max pressure
    %close all elements
    %and open those that we're now lower than.
    for j = 1:numelements
        PMSpace(j,3)=1;
        if pressure < PMSpace(j,2)
            if PMSpace(j,3) == 1
                PMSpace(j,3) = 0;
            end
        end
    end
else                            %we have yet to reach the max stress
    for j = 1:numelements  %Cycle through the elements CHECKING their history (current state) to see if they need to be opened or closed at this stress
        if pressure > PMSpace(j,1)         %if the pressure is higher than the closing pressure close it if it's open
            if PMSpace(j,3) == 0
                PMSpace(j,3) = 1;
            end
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
Strain = dl;                        %record the strain
