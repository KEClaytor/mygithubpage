function Strain=altStrainCalc(Protocol,myPM)
%Initialize vars
Strain=[];
%Load up our data
%load StrainCurve
%Protocol = StrainData(:,1:2);
%load PMSpace

for j = 1:length(Protocol)                          %For every time point
    Strain = [Strain;getSpecificStrain(myPM,Protocol,j)];
end