%align probe to atlas
%change name

%this program uses several functions from other repositories, including functions from:
%https://github.com/petersaj/AP_histology
%https://github.com/JorritMontijn/Acquipix
%https://github.com/JorritMontijn/GeneralAnalysis 
%https://github.com/kwikteam/npy-matlab
%https://github.com/cortex-lab/spikes
%https://github.com/JorritMontijn/zetatest

%% ask what to load
%clear all;
%Universal Probe Finder Using Neurophysiology

function ProbeFinder
	%% add subfolders
	strFullpath = mfilename('fullpath');
	strPath = fileparts(strFullpath);
	sDir=dir([strPath filesep '**' filesep]);
	%remove git folders
	sDir(contains({sDir.folder},[filesep '.git'])) = [];
	cellFolders = unique({sDir.folder});
	for intFolder=1:numel(cellFolders)
		addpath(cellFolders{intFolder});
	end
	
	%% load atlas
	global boolIgnoreProbeFinderRenderer;
	boolIgnoreProbeFinderRenderer = false;
	
	%select which atlas to use
	cellAtlases = {'Mouse (AllenCCF)','Rat (Sprague-Dawley)'};
	[intSelectAtlas,boolContinue] = listdlg('ListSize',[200 100],'Name','Atlas Selection','PromptString','Select Atlas:',...
		'SelectionMode','single','ListString',cellAtlases);
	if ~boolContinue,return;end
	
	%try using Acquipix variables
	try
		sRP = RP_populateStructure();
	catch
		sRP = struct;
	end
	
	%load atlas
	if intSelectAtlas == 1
		%get path
		if isfield(sRP,'strAllenCCFPath') && isfolder(sRP.strAllenCCFPath)
			strAllenCCFPath = sRP.strAllenCCFPath;
		else
			strAllenCCFPath = PF_getIniVar('strAllenCCFPath');
		end
		
		%load ABA
		if (~exist('tv','var') || isempty(tv)) || (~exist('av','var') || isempty(av)) || (~exist('st','var') || isempty(st))...
				|| ~all(size(av) == [1320 800 1140]) || (~exist('strAtlasType','var') || ~strcmpi(strAtlasType,'Allen-CCF-Mouse'))
			[tv,av,st] = RP_LoadABA(strAllenCCFPath);
			if isempty(tv),return;end
		end
		
		%prep ABA
		sAtlas = RP_PrepABA(tv,av,st);
	else
		%get path
		if isfield(sRP,'strSpragueDawleyPath') && isfolder(sRP.strSpragueDawleyPath)
			strSpragueDawleyPath = sRP.strSpragueDawleyPath;
		else
			strSpragueDawleyPath = PF_getIniVar('strSpragueDawleyPath');
		end
		
		%load RATlas
		if (~exist('tv','var') || isempty(tv)) || (~exist('av','var') || isempty(av)) || (~exist('st','var') || isempty(st))...
				|| ~all(size(av) == [512 1024 512]) || (~exist('strAtlasType','var') || ~strcmpi(strAtlasType,'Sprague-Dawley-Rat'))
			[tv,av,st] = RP_LoadSDA(strSpragueDawleyPath);
			if isempty(tv),return;end
		end
		
		%prep SDA
		sAtlas = RP_PrepSDA(tv,av,st);
	end
	%save raw atlas to base workspace so it doesn't need to keep loading it
	assignin('base','tv',tv);
	assignin('base','av',av);
	assignin('base','st',st);
	assignin('base','strAtlasType',sAtlas.Type);
	
	%% load coords file
	strDefaultPath = sRP.strProbeLocPath;
	sProbeCoords = PH_LoadProbeFile(sAtlas,strDefaultPath);
	
	%% load ephys
	%select file
	try
		strOldPath = cd(sRP.strEphysPath);
		strNewPath = sRP.strEphysPath;
	catch
		strOldPath = cd();
		strNewPath = strOldPath;
	end
	%open ephys data
	sClusters = PH_OpenEphys(strNewPath);
	
	% load or compute zeta if ephys file is not an Acquipix format
	if isempty(sClusters) || strcmp(sClusters.strZetaTit,'Contamination')
		%select
		sZetaResp = PH_OpenZeta(sClusters,strNewPath);
		
		%save
		if ~isempty(sZetaResp) && isfield(sZetaResp,'vecZetaP')
			sClusters.vecDepth = sZetaResp.vecDepth;
			sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
			sClusters.strZetaTit = 'ZETA (z-score)';
		end
	end
	
	% close message
	cd(strOldPath);
	
	%% run GUI
	[hMain,hAxAtlas,hAxAreas,hAxAreasPlot,hAxZeta,hAxClusters,hAxMua] = PH_GenGUI(sAtlas,sProbeCoords,sClusters);
end