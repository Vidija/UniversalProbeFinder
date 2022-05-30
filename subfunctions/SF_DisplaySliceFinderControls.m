function SF_DisplaySliceFinderControls(varargin)
	
	% Print controls
	CreateStruct.Interpreter = 'tex';
	CreateStruct.WindowStyle = 'non-modal';
	msgbox( ...
		{'\fontsize{12}Tip: if the keyboard controls stop working after you press a button, click somewhere in the header area to return focus to the GUI.' ...
		'' ...
		'\bf Image navigation: \rm' ...
		'Left/right arrow  : move to previous/next image' ...
		'Page up/down      : move forward/back by five' ...
		'Home/end          : move to first/last image' ...
		''...
		'\bf Adjust slice rotation: \rm' ...
		'q/e : roll clockwise/counter-clockwise' ...
		'w/s : pitch down/up' ...
		'a/d : yaw left/right' ...
		''...
		'\bf Adjust slice position and size: \rm' ...
		'F2  : invert ML/DV axis movement' ...
		'F3  : toggle slice overlay type' ...
		'i/k : DV, move up/down' ...
		'j/l : ML, move left/right' ...
		'h/n : AP, move forward/back' ...
		'shift + i/k : stretch/shrink vertically' ...
		'shift + j/l : stretch/shrink horizontally' ...
		''...
		'\bf Copy/paste slice rotation+position: \rm' ...
		'Control+c : copy settings of current slice' ...
		'Control+v : paste previously copied settings to slice' ...
		'Control+b : interpolate slices between last two copied slices'...
		''...
		'\bf 3D brain areas: \rm' ...
		'=/+ : add (list selector)' ...
		'Alt/Option =/+ : add (search)' ...
		'- : remove', ...
		''...
		'\bf Other: \rm' ...
		't  : slice/area transparency (toggle on/off)' ...
		'x  : export data for ProbeFinder'...
		'F5 : save data' ...
		'F9 : load data', ...
		'F1 : bring up this window'}, ...
		'Controls',CreateStruct);
	
	%reset focus
	if nargin > 0
		sGUI = guidata(varargin{1});
		sGUI.IsBusy = false;
		guidata(varargin{1}, sGUI);
	
		figure(sGUI.handles.hMain);
		set(sGUI.handles.ptrButtonHelp, 'enable', 'off');
		drawnow;
		set(sGUI.handles.ptrButtonHelp, 'enable', 'on');
	end
end


