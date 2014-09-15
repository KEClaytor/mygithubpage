%Function pmCompare
% Kevin Claytor
% LANL EES-GEO
% May 21, 2007
%
% pmCompare.m
% Usage
%    pmCompare(sample)
%
% Does a quick plot to compare the simulated versus data stress-strain
%    curves.  Mainly because I'm to lazy to type in all these commands
%    myself
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%
function pmCompare(sample)
switch lower(sample)
    case 'berea'
        load StrainCurve_Berea_innerloops;  %Load the data
        Berea_Expt = StrainData;
        clear StrainData
        load StrainCurve_Berea_5000;        %Load the simulation
        Berea_Invt = StrainData;
        clear StrainData
        figure; plot(Berea_Expt(:,2),Berea_Expt(:,3),'k-'); %Plot the figure
        hold on; plot(Berea_Invt(:,2),Berea_Invt(:,3),'r-');
        set(gca,'FontSize',18)
        xlabel('Stress (MPa)');
        ylabel('Strain (Normalized)');
        title('Stress-Strain Curve for Berea');
    case 'font77'
        load StrainCurve_Font77_innerloops;  %Load the data
        Font77_Expt = StrainData;
        clear StrainData
        load StrainCurve_Font77_5000;        %Load the simulation
        Font77_Invt = StrainData;
        clear StrainData
        figure; plot(Font77_Expt(:,2),Font77_Expt(:,3),'k-'); %Plot the figure
        hold on; plot(Font77_Invt(:,2),Font77_Invt(:,3),'r-');
        set(gca,'FontSize',18)
        xlabel('Stress (MPa)');
        ylabel('Strain (Normalized)');
        title('Stress-Strain Curve for Bernard Font');
    case 'fontk'
        load StrainCurve_FontK2_innerloops;  %Load the data
        FontK_Expt = StrainData;
        clear StrainData
        load StrainCurve_FontK2_5000;        %Load the simulation
        FontK_Invt = StrainData;
        clear StrainData
        figure; plot(FontK_Expt(:,2),FontK_Expt(:,3),'k-'); %Plot the figure
        hold on; plot(FontK_Invt(:,2),FontK_Invt(:,3),'r-');
        set(gca,'FontSize',18)
        xlabel('Stress (MPa)');
        ylabel('Strain (Normalized)');
        title('Stress-Strain Curve for Koen Font');
    case 'wood'
        load StrainCurve_Wood_innerloops;  %Load the data
        Wood_Expt = StrainData;
        clear StrainData
        load StrainCurve_Wood_2000;        %Load the simulation
        Wood_Invt = StrainData;
        clear StrainData
        figure; plot(Wood_Expt(:,2),Wood_Expt(:,3),'k-'); %Plot the figure
        hold on; plot(Wood_Invt(:,2),Wood_Invt(:,3),'r-');
        set(gca,'FontSize',18)
        xlabel('Stress (MPa)');
        ylabel('Strain (Normalized)');
        title('Stress-Strain Curve for Wood');
end