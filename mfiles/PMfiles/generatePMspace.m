%Function generatePMspace
% Kevin Claytor
% LANL EES-GEO
% July 22, 2006
% May 21, 2007  - added option 7
%
% generatePMspace.m
% Usage
%    PMspace=generatePMspace(numelements,maxstress,state,nc)
%
% Generates a filled PM space with numelements elements, capable of going
%    up to maxstress.  state can be set to 1 - random, 2 - method a or
%    3 - method b of filling the space.  Or 4 - diagonal only, or 5 -
%    normally centered diagonal.
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   PMspace - an nx3 array that contains the closing pressure, opening
%      pressure and current state (open or closed) of all the HEUs
%      col 1 = closing stress, col 2 = opening stress, col 3 = state
%      (open or closed, initialized to open here)
%    numelements - the number of elements we want to put into our PM space
%    maxstress - the maximum stress that our PM space is capable of
%      reaching
%   nc - see RAG paper example 4 - only comes into play for state = 3
%   cp - the closing pressure of the HEU
%   co - the opening pressure of the HEU
%   temp - a temporary variable for flipping if necessary
%   

%Pseudocode - taken from PMDemo
% 1 - Initialize our array of PM elements
%     - Loop of 1:n elements
%     - Generate a (rounded) random number between 0 and max pressure
%     - Call that number the closing pressure
%     - loop generating another (rounded) random number until we get one
%       that's smaller than our previous one.
%     - Store these numbers in an array - keep an extra column to
%       keep track of which elements are open and which are closed
%     - Plot the resulting PM space

function [PMspace]=generatePMspace(numelements,maxstress,state,nc)
%Initialize PMspace
PMspace=[];

%Take care of defaults
if nargin < 4
    nc = 0;
    if nargin < 3
        state = 1;
        if nargin < 2
            maxstress = 25;
            if nargin < 1
                numelements = 50;
            end
        end
    end
end
if state == 1                   %Do the random case
    %start filling the array
    for i = 1:numelements
        cp = maxstress*rand;    %generate our first random number
        co = maxstress*rand;    %and the second random number
        if co > cp              %If the opening pressure is greater than the closing pressure
            temp = cp;           %  then flip the two, 'cause that's physically impossible
            cp = co;
            co = temp;
        end
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state==2                 %Normal Random - Like the random, but dropping off according to a normal distribution
    for i = 1:numelements
        cp = maxstress*abs(randn)/3;    %generate our first random number
        co = maxstress*abs(randn)/3;    %and the second random number
        if co > cp              %If the opening pressure is greater than the closing pressure
            temp = cp;           %  then flip the two, 'cause that's physically impossible
            cp = co;
            co = temp;
        end
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state == 3               %We fill according to Example 2 in the RAG paper
    for i = 1:numelements
        cp = maxstress*(rand)^2;
        co = cp*(rand)^(1/2);
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state == 4               %We fill according to Example 4 in the RAG paper
    for i = 1:numelements
        cp = maxstress*(rand)^2;
        co = cp*(rand)^(0.25+0.75*nc);
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state == 5               %Diagonal only
    for i = 1:numelements
        cp = maxstress*rand;    %generate our first random number
        co = cp;
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state == 6               %Normal diagonal
    for i = 1:numelements
        cp = maxstress*abs(randn)/3;    %generate our normal random number  /3 is a kludge that fits well enough
                                        %   /3 comes from the ~3 standard devations
        co = cp;
        PMspace = [PMspace;[cp,co,0]];  %Build the array
    end
elseif state == 7               %Linear falloff from the diagonal
    i=0;
    while i < numelements
        co = maxstress*rand;            %switch our standard order of doing things
        cp = maxstress*rand+co;         %because we need these to be at least on the diagonal
        det = rand;
        while (det >= .0064*(maxstress-cp+co))%&&(cp >= maxstress)      %sign fippage, originally; if det <= .0032*(25-x(k))
            det = rand;
            co = maxstress*rand;            %switch our standard order of doing things
            cp = maxstress*rand+co;         %because we need these to be at least on the diagonal
        end                                 %Okay we found one, add it to the PM Space
        if cp <= maxstress                  %if we're within PM space range
            PMspace = [PMspace;[cp,co,0]];  %Build the array
            i = i + 1;    
        end
    end
elseif state == 8
    for i = 1:numelements/3
        cp = maxstress*rand;
        co = ((cp/16)^2)*rand;
        PMspace = [PMspace;[cp,co,0]];
    end
    for i = 1:numelements/3
        cp = maxstress*rand;
        co = ((cp/8)^2)*rand;
        PMspace = [PMspace;[cp,co,0]];
    end
    for i = 1:numelements/3
        cp = maxstress*rand;
        co = ((cp/6)^2)*rand;
        PMspace = [PMspace;[cp,co,0]];
    end
end