/*
ONE Back Store Ignore Recall Task with Distractors (1 Back SIR-D version 1)

Copyright 2013 by Mark Ho (4/22/2013)

This is javascript code for an online version of the
1Back SIR-D task (1 Back Store Ignore Recall with Distractors) task
(see O'Reilly and Frank 2006). Shapes with textures are used
as the symbol alphabet.

- target symbols are 'activated' by the symbol immediately preceding it
- there are distractors

*/

//prevent conflicts between jQuery and other libraries
var $j = jQuery.noConflict();

/*task-wide variables*/
var exp_data = new table(["current_shape", "current_texture",
						"last_symbol_shape", "last_symbol_texture",
						"subj_resp", "reward",
						"state_start", "state_end"]);
var symbol_sequence, textbox, continue_button;

/*trial-by-trial variables*/
var curAction;
var curAvailableActions;
var curShape;
var curReward_disp;
var curState = {shape:'', texture:'', last_symbol_shape:'', last_symbol_texture:''};
var curStateStart;
var curTrial_count = 0;

//variables to counterbalance (these are default values)
var triggers = [{shape:"square", texture:"lined"}, {shape:"star", texture:"lined"}];
var distractors = [{shape:"diamond", texture:"black"}, {shape:"octagon", texture:"black"}];
var target_symbols = [{shape:"pentagon", texture:"empty"}];
var target_resp = "R";
var nontarget_resp = "L";

//rewards
var cor_active_target_r = 5;
var inc_active_target_r = -5;
var cor_inactive_target_r = 0;
var inc_inactive_target_r = -1;
var cor_nontarg_r = 0;
var inc_nontarg_r = -1;

//generates randomized variables (but does not set them) and returns an object
function randomizeVars() {
	var textures = ["lined","empty","black"];
	var shapes = ["square", "star", "pentagon", "diamond", "octagon"];
	
	fisherYates(textures);
	var one_texture = textures[0];
	var t_texture = textures[1];
	var two_texture = textures[2];
	
	fisherYates(shapes);
	var one_shapes = shapes.slice(0,2);
	var t_shapes = shapes.slice(2,4);
	var two_shapes = shapes.slice(4,5);
	
	var responses = ["R","L"];
	fisherYates(responses);
	
	return {one_texture:textures[0],two_texture:textures[1],t_texture:textures[2],
			one_shape_1:shapes[0], one_shape_2:shapes[1], 
			two_shape_1:shapes[2], two_shape_2:shapes[3],
			t_shape_1:shapes[4], t_shape_2:undefined,
			target_resp:responses[0], nontarget_resp:responses[1]};
}

//loads parameters given an object with appropriate parameter names
function loadTaskParameters(params) {
	triggers = [{shape:params.one_shape_1, texture:params.one_texture}, {shape:params.one_shape_2, texture:params.one_texture}];
	target_symbols = [{shape:params.t_shape_1, texture:params.t_texture}];
	distractors = [{shape:params.two_shape_1, texture:params.two_texture}, {shape:params.two_shape_2, texture:params.two_texture}];
	target_resp = params.target_resp;
	
	nontarget_resp = params.nontarget_resp;
}

/*--state transition and reward function functions--*/
function generateSymbolSequence() {
	/*
	cycles = one activator, one target
	*/
	var cycles = 16;
	var blocks = 4;
	var pCorrSymbol = 12/16; //probability of correlated symbol

	var symbol_sequence = [];
	for (var i = 0; i < blocks; i++) {

		//generate inter-cycle symbol sequences of size 0,1,2,3
		//each block contains 4*(0+1+2+3) = 4*6 = 24 intercycle symbols
		//intercycle (or 'distractor') symbols can be two back or one back symbols
		var distSetSize = _.replist([0,1,2,3],4);
		_.shuffleInPlace(distSetSize);
		var dist_symbols = _.replist(_.flatten([distractors,triggers]),6);
		_.shuffleInPlace(dist_symbols);
		var dist_seq = [];
		for (var j = 0; j < distSetSize.length; j++) {
			var interCycle_seq = [];
			for (var k = 0; k < distSetSize[j]; k++) {
				interCycle_seq.push(dist_symbols.pop());
			}
			dist_seq.push(interCycle_seq);
		}
		_.shuffleInPlace(dist_seq);

		var block_seq = [];

		//generate main cycles for block
		for (var j = 0; j < cycles; j++) {
			if (j < Math.floor(cycles*pCorrSymbol)){
				block_seq.push([dist_seq.pop(),triggers[0], target_symbols[0]]);
			}
			else {
				block_seq.push([dist_seq.pop(),triggers[1], target_symbols[0]]);
			}
		}
		_.shuffleInPlace(block_seq);

		Array.prototype.push.apply(symbol_sequence, block_seq);
	}
	return _.flatten(symbol_sequence);
}

function stateTransition(oldState, action) {
	/*
	Read off state transitions from the generated sequence
	*/
	
	var newState = {};
	//load next symbol from symbol sequence
	if (curTrial_count < symbol_sequence.length) {
		var newState = _.clone(symbol_sequence[curTrial_count]);
	}
	else {
		var newState = {shape:"end",texture:"end"};
	}
	
	newState.last_symbol_shape = oldState.shape;
	newState.last_symbol_texture = oldState.texture;
		
	//always return left and right
	var newActions = ["L","R"];
	
	return {state:newState,actions:newActions};
}

function rewardFunction(state, action) {
	/*
	e.g. Target Sequences:
		Context: square, lined
		Sequence: pentagon, empty; diamond, black

	Correct target sequences get a large reward
	Incorrect non-target and target sequences get a small reward
	Correct non-target get no reward
	*/
	//initial state
	if (state.shape == "" && state.texture == "") {
		return undefined;
	}
	
	//if the symbol is a target
	//trigger 1 activates; trigger 2 deactivates
	if (state.texture == target_symbols[0].texture && state.last_symbol_shape == triggers[0].shape) {
		if (action == target_resp) {
			return cor_active_target_r;
		}
		else if (action == nontarget_resp) {
			return inc_active_target_r;
		}
	}
	else if (state.texture == target_symbols[0].texture && state.last_symbol_shape == triggers[1].shape) {
		if (action == target_resp) {
			return inc_inactive_target_r;
		}
		else if (action == nontarget_resp) {
			return cor_inactive_target_r;
		}
	}
	else {
		if (action == target_resp) {
			return inc_nontarg_r;
		}
		else if (action == nontarget_resp) {
			return cor_nontarg_r;
		}
	}
}

/*----------------------*/
/*----------------------*/
/*----------------------*/
/*----------------------*/
/*----------------------*/
/*event coordinating and recording*/
function setButtonEvents() {
	$j(".exp_taskButton").click( function () {
		var myDate = new Date();
		var curStateEnd = myDate.getTime();
		$j(".exp_taskButton").off('click');
		var action_val = $j(this).text()
		var sa = stateTransition(curState, action_val);
		var reward = rewardFunction(curState,action_val);
		var oldReward = parseInt($j("#exp_pointInfo").text());
		
		//record info about state_t, action, and state_t+1
		recordInteraction(curState, curAvailableActions, action_val, reward,
								sa.state, sa.actions, curStateStart, curStateEnd);
		
		//show environment response to action (pre-state change)
		var animation_time = showReward(reward);
		if (!(typeof reward == "undefined")) {
			$j("#exp_pointInfo").text(oldReward+reward);
		}
		//show state change and reset trial
		setTimeout(function () {
			//If end trial is reached
			if (sa.state.shape == 'end' && sa.state.texture == 'end') {
				endExperiment();
			}
			//for all other trials
			else {
				setButtons(sa.actions);
				setButtonEvents();
				showStateChange(sa.state);
				curTrial_count++;
				$j("#exp_trialnumInfo").text(curTrial_count);
			}
		}, animation_time);
		
		//update internal variables
		var myDate = new Date();
		curStateStart = myDate.getTime();
		
		curState = sa.state;
		curAvailableActions = sa.actions;
	});
}

function recordInteraction(oldState, oldActions, action, reward, newState, newActions, stateStart, stateEnd) {
	if (typeof reward != "number") {
		reward = 0;
	}

	exp_data.addrow({
		current_shape: oldState.shape,
		current_texture: oldState.texture,
		last_symbol_shape: oldState.last_symbol_shape,
		last_symbol_texture: oldState.last_symbol_texture,
		subj_resp: action,
		reward: reward,
		state_start: stateStart,
		state_end: stateEnd
	});

	$j("#exp_trial_data").text(exp_data.toString());
	textbox.overwrite(exp_data.toString());
}

//wraps up experiment, automatically goes to next page
function endExperiment() {
	var oldReward_disp = curReward_disp;
	oldReward_disp.remove(); //deletes old element
	curReward_disp = taskSpace.text(250, 200, "Task Complete! Press Continue").attr({'font-size':20});
	curShape.remove();
	
	continue_button.show();
	continue_button.click();
}

/*----------------------*/
/*----------------------*/
/*--functions that link state/reward transitions to UI--*/
function showAction(action_val) {
	//action_val appears at bottom of screen
	curAction.attr({'x':250,'y':480, 'text':"+", 'fill':'limegreen'}).toFront();
	//action_val moves to center of screen
	curAction.animate({'x':250,'y':250},500,'>');
}

function showReward(reward_val) {
	var oldReward_disp = curReward_disp;
	oldReward_disp.remove(); //deletes old element

	if (typeof reward_val == "undefined") {
		curReward_disp = taskSpace.text(250, 175, "");
		return 500;
	}

	if (reward_val > 0) {
		curReward_disp = taskSpace.text(250, 175, "+"+reward_val);
		curReward_disp.attr({'font-size': 40, "font-family":"arial", "font-weight":"bold", "fill":"yellow"});
		setCanvasColor("blue");
		curReward_disp.animate({'x':250, 'y':115, 'opacity':0, "font-size":80}, 1000, '<');
		return 500;
		}
	else if (reward_val < 0) {
		curReward_disp = taskSpace.text(250, 330, reward_val);
		curReward_disp.attr({'font-size': 40, "font-family":"arial", "font-weight":"bold", "fill":"white"});
		setCanvasColor("red");
		curReward_disp.animate({'x':250, 'y':370, 'opacity':0, "font-size":20}, 1000, '<');
		return 500;
	}
	else {
		curReward_disp = taskSpace.text(250, 175, "+"+reward_val);
		curReward_disp.attr({'font-size': 40, "font-family":"arial", "font-weight":"bold", "fill":"limegreen"});
		//setCanvasColor("blue");
		curReward_disp.animate({'x':250, 'y':115, 'opacity':0}, 1000, '<');
		return 500;
	}
	
}

function showStateChange(newState) {
	setCanvasColor("white");
	curShape.animate({'opacity':0},300,'<');
	var oldShape = curShape;
	setTimeout( function () {oldShape.remove();},500); //deletes old element
	curShape = setCenterShape(newState.shape, newState.texture, taskSpace);
	curShape.toBack();
}


/*----------------------*/
/*----------------------*/
/*--Low-level functions for Manipulating Task Elements--*/
function setCanvasColor(color) {
	$j("#exp_taskSpace").css('background-color', color);
}
function setCenterShape(shape, texture, taskSpace) {

	var settings = {"stroke-width":"5"};

	//set texture
	if (texture == "lined") {
		settings.fill = "url(http://research.clps.brown.edu/mkho/cultural_images/bars_150x150.png)";
	}
	else if (texture == "black") {
		settings.fill = "black";
	}
	else if (texture == "radial") {
		settings.fill = "url(http://research.clps.brown.edu/mkho/cultural_images/radial_300x300.png)";
	}
	else if (texture == "spokes") {
		settings.fill = "url(http://research.clps.brown.edu/mkho/cultural_images/spokes_150x150.png)";
	}
	else if (texture == "empty"){
		settings.fill = "none";
	}
	else {
		settings.fill = "none";
	}
	
	//set shape
	if (shape == "circle") {
		var returnShape = taskSpace.circle(250, 250, 75).attr(settings);
	}
	else if (shape == "square") {
		var returnShape = taskSpace.rect(175, 175, 150, 150).attr(settings);
	}
	else if (shape == "hexagon") {
		var drawStr = "M 175 250 l 37.5 75 l 75 0 l 37.5 -75 l -37.5 -75 l -75 0 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == "star") {
		var drawStr = "M 250 175 L 270 230 L 325 250 L 270 270 L250 325 L 230 270 L 175 250 L 230 230 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == "trapezoid") {
		var drawStr = "M 210 175 L 290 175 L 325 325 L 175 325 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == "pentagon") {
		var drawStr = "M 250 175 l 75 54.5 l -28.6 88.1 l -92.7 0 l -28.6 -88.1 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == "oval") {
		var returnShape = taskSpace.ellipse(250, 250, 75, 40).attr(settings);
	}
	else if (shape == "triangle") {
		var drawStr = "M 250 175 L 325 325 L 175 325 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == 'diamond') {
		var drawStr = "M 250 175 L 325 250 L 250 325 L 175 250 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}
	else if (shape == "octagon") {
		var drawStr = "M 218.9 175 l 60.67 0 l 43.9 43.9 l 0 60.67 l -43.9 43.9 l -60.67 0 l -43.9 -43.9 l 0 -60.67 z";
		var returnShape = taskSpace.path(drawStr).attr(settings);
	}	
	else {
		var returnShape = taskSpace.text(250, 250, '+').attr({'font-size': 40, "font-family":"arial", "font-weight":"bold"});
	}

	return returnShape;
}

function setPoints(p) {
	$j("#exp_pointInfo").text(p);
}

function setButtons(labels) {
	for (var i = 0; i < labels.length; i++) {
		var button_label = "#button_"+(i+1);
		$j(button_label).text(labels[i]);
	}
}

/*----------------------*/
/*----------------------*/
/*----------------------*/
/*----------------------*/
/*----------------------*/

function runExperiment(task_condition, task_parameters) {
	//initialize taskspace
	taskSpace = new Raphael(document.getElementById("exp_taskSpace"), 500, 500);
	curShape = setCenterShape("", "", taskSpace);
	curAction = taskSpace.text(250, 250, "");
	curAction.attr({'font-size': 70, "font-family":"arial", "font-weight":"bold"});
	curReward_disp = taskSpace.text(250, 200, "Press the 'L' or 'R' button to begin").attr({'font-size':30});
    setCanvasColor("white");
    setPoints(0);
    

    loadTaskParameters(task_parameters);
    
    symbol_sequence = generateSymbolSequence();
    
    //initial choices
    setButtons(["L","R"]);
    
    //allow user to interact with task
    setButtonEvents();
    var myDate = new Date();
	curStateStart = myDate.getTime();
	
	//preload image in case of delay
	preloadImage("http://research.clps.brown.edu/mkho/cultural_images/bars_150x150.png");
	textbox = new QualtricsTextBoxHandler();
	continue_button = new QualtricsContinueHandler();
	continue_button.hide();
	
	$j("#debug").text("Version 44");
}

//generates parameters for the task - i.e. what the context is, etc. And saves it to a textbox
function generateTaskParams() {
	var taskparams = randomizeVars();
	var tb = new QualtricsTextBoxHandler();
	
	tb.overwrite(ObjToString(taskparams));
}

//displays rewards on reward page
function displaySubjReward() {
	var exp_trial_data = stringToTable($j("#exp_trial_data").text());
	var pointsEarned = exp_trial_data.sumCol("reward");
	//var bonus = pointsEarned/200;
	//if (bonus < 0) {bonus = 0;}
	$j("#pointsEarned").text(pointsEarned);
	//$j("#bonus").text(bonus.toFixed(2));
	
	//store task performance
	var tb = new QualtricsTextBoxHandler();
	tb.overwrite(String(pointsEarned));
}