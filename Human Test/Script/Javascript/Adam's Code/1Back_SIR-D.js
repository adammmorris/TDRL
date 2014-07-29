/*
2-Step Task
Adam Morris (based off code from Mark Ho)

2-step task to test for R/P split in a TDRL actor-critic model.
- 1 starting point, 2 decision points (each with 2 options)
- All nodes in the lower two levels have a randomized value from [-25,25]
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
//var curState = {shape:'', texture:'', last_symbol_shape:'', last_symbol_texture:''}; 
var curStateStart;
var curTrial_count = 0;

/* Task variables
curState is an object with the following properties:
	level: a number between 1 (first decision point) and numLevels (last decision point)
	lastAction: "L" or "R"
*/
var curState = {level:1, lastAction:''};
var numLevels = 2;
var numChoices = 2; // number of choices per level - this is assumed to be 2 throughout this program
var numSymbols; // this will be calculated in randomizeVars()

// If rewardRange = x, the rewards will be randomly set between -x and x
var rewardRange = 25;

// symbols is an array containing numSymbols objects
// each object has the following properties:
//      shape - the shape of the symbol
//		reward - the reward associated with that choice
// if you imagine the board starting at the top and moving downard, then symbols is indexed top to bottom, left to right
// (this is calculated by calculateSymbolIndex())
var symbols = [];

//generates randomized variables (but does not set them) and returns an object
function randomizeVars() {
	// Figure out how many symbols we're working with here
	numSymbols = 0;
	for (var i = 1; i <= numLevels; i++) {
		numSymbols = numSymbols + (numChoices ^ i);
	}

	// Right now, we need 6 different symbols
	
	// Get the 6 shapes (and textures?)
	//var textures = ["lined","empty","black", "spokes", "radial"];
	var shapes = ["square", "star", "pentagon", "diamond", "octagon", "circle"];
	fisherYates(shapes);
	
	// Each symbol is randomly assigned a reward
	var rewards = [];
	for (var i = 0; i < numSymbols; i++) {
		rewards[i] = Math.floor(Math.random()*(rewardRange+1));
		if (Math.random() < .5) {
			rewards[i] = rewards[i] * -1;
		}
	}
	
	return {shapes, rewards};
}

//loads parameters given an object with appropriate parameter names
function loadTaskParameters(params) {
	for (var i = 0; i < numSymbols; i++) {
		symbols[i] = {shape:params.shapes[i], reward:params.rewards[i]};
	}
}

// Given that the user was in a given state and took a certain action, calculate the index of the selected symbol
function calculateSymbolIndex(state, action) {
	// Get us to the first symbol on that level
	var index = (numChoices ^ state.level) - 1;
	// Get us to the proper branch within that level (NOT SCALABLE)
	index = index + 
}

// After each choice, transition to appropriate next state
function stateTransition(oldState, action) {
	// Move to the next level
	var nextLevel = oldState.level + 1;
	if (nextLevel > numLevels) {
		nextLevel = 1;
	}
	
	var newState = {level:nextLevel, lastAction:action};
	var newActions = ["L","R"];
	
	// Return the new state & actions
	return {state:newState, actions:newActions};
}

function rewardFunction(state, action) {
	
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
	else if (texture == "red"){
		settings.fill = "red";
	}
	else {
		settings.fill = "none";
	}
	
	//set shape
	if (shape == "circle") {
		var returnShape = taskSpace.circle(250, 250, 75).attr(settings);
		//var returnShape = taskSpace.circle(100, 250, 75).attr(settings);
	}
	else if (shape == "square") {
		//var returnShape = taskSpace.rect(175, 175, 150, 150).attr(settings);
		var returnShape = taskSpace.rect(50, 175, 150, 150).attr(settings);
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