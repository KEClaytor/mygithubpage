
function quicktest
Strain=[];
StrainNew=[];
tol = 0;
roworcol = 0;
updown = 0;

numelements = 100;
maxstress = 30;

load StrainCurve                    %Load up the strain curve, the variable
                                    %   name is StrainData, col 1 = time
                                    %   col 2 = stress, col 3 = strain
Protocol = StrainData(:,1:2);       % sort and store
%Make our random PM space
newPM = generatePMspace(numelements,maxstress,1,0);
[peakStress,peakTime]=max(StrainData(:,2));     %At what time does the max stress occur and what is it?
peakTime = peakTime - 1;                        %zero correction
%initialize our sum
sum=0;
for j = 1:length(Protocol)                          %For every time point
    %find out how close we come at the current point
    StrainNew=getStrain(newPM,Protocol);            %Get these values in the beginning
    StrainAlpha=StrainNew(j);
    StrainBeta=getSpecificStrain(newPM,Protocol,j);
    difference = StrainAlpha-StrainBeta;
    sum = sum + difference;
end
sum