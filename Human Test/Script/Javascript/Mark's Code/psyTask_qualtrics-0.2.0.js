/*
Collection of useful functions and objects for embedding and running JavaScript-based
tasks in a qualtrics survey.

Version 0.2.0

Copyright Mark Ho 2013

dependencies:
jQuery
Underscore.js
*/
//prevent conflict between jquery and other libraries
var $j = jQuery.noConflict();

//extensions to Underscore.js
_.mixin({
	//replicates a list some number of times
	replist : function (list, rep_num) {
		var new_list = [];
		for (var i = 0; i < rep_num; i++) {
			for (var j = 0; j < list.length; j++) {
				new_list.push(_.clone(list[j]));
			}
		}
		return new_list;
	},

	//shuffles a list in place - same as fisheryates algorithm below
	shuffleInPlace : function ( myArray ) {
	  var i = myArray.length;
	  if ( i == 0 ) return false;
	  while ( --i ) {
	     var j = Math.floor( Math.random() * ( i + 1 ) );
	     var tempi = myArray[i];
	     var tempj = myArray[j];
	     myArray[i] = tempj;
	     myArray[j] = tempi;
	   }
	}

});


//returns the first index that an element ele appears in the list
function getIndex(ele, list) {
	for (var i = 0; i < list.length; i++) {
		if (list[i] == ele) {return i;}
	}
	return -1;
}

function listEquality(listA, listB) {
	
}

function zerospad(num, size) {
	var s = new Array();
	for (var i = 0; i < size; i++) {s.push('0');}
	s = s.join('');
	s = "000" + num;
    return s.substr(s.length-size);
}

//table object with methods for turning it into a string and adding
//new rows
//a 0th column is inserted that tracks the row number
function table (header) {
	this.header = ["#"].concat(header);
	this.rows = new Array();
	this.length = this.rows.length;
	
	//getheader function
	this.getheader = getheader;
	function getheader() {
		return this.header.slice(1,this.header.length);
	}

	//addRow function
	this.addrow = addrow;
	function addrow(row_data) {
		//fill in columns without header keys with header keys
		for (var ih = 0; ih < this.header.length; ih++) {
			colname = this.header[ih];
			if (colname == '#') {
			}
			else if (getIndex(colname,Object.getOwnPropertyNames(row_data)) == -1) {
				row_data[colname] = '';
			}
		}
		this.rows.push(row_data);
		this.length = this.rows.length;
	}

	//getRow function
	this.getrow = getrow;
	function getrow(row_index) {
		if (row_index > this.rows.length-1) {
			throw 'Error: row_index out of bounds';
		}
		return this.rows[row_index];
	}
	
	//sumCol function - converts strings in the column to floats (if not already floats)
	this.sumCol = sumCol;
	function sumCol(colname) {
		var coltype = typeof(this.rows[0][colname]);
		var sum = 0;
		for (var i = 0; i < this.rows.length;i++) {
			if (coltype == "string") { var toAdd = parseFloat(this.rows[i][colname]);}
			else if (coltype == "number") {var toAdd = this.rows[i][colname];}
			else {throw "sumCol Error: cannot recognize column type";}
			sum += toAdd;
		}
		return sum;
	}
	
	//toString function
	this.toString = toString;
	function toString() {
		var toReturn = [this.header.join(",")];
		for (var i = 0; i < this.rows.length; i++){//iterate through rows
			var thisrow = this.rows[i];
			var rowData = [];
			for (var j = 0; j < this.header.length; j++) { //iterate columns of row
				var col_name = this.header[j];
				if (thisrow.hasOwnProperty(col_name)) {
					rowData.push(thisrow[col_name]);
				}
				else if (col_name == "#") {
					rowData.push(i);
				}
				else {
					rowData.push("");
				}
			}
			toReturn.push(rowData.join(","));
		}
		return toReturn.join(";");
	}
}

//generates table from a string
function stringToTable(str) {
	var rowstr = str.split(";");
	$j("#debug").text(rowstr[0]);
	var header = rowstr[0].split(",");
	var newTable = new table(header);
	for (var i = 1; i < rowstr.length; i++) {
		var rowdata = rowstr[i].split(",");
		var newRow = {};
		for (var j = 0; j < rowdata.length; j++) {
			if (header[j] == "#") {
				newRow[header[j]] = parseInt(rowdata[j]);
			}
			else {
				newRow[header[j]] = rowdata[j];
			}
		}
		newTable.addrow(newRow);
	}
	return newTable;
}

//shuffles an array in place
function fisherYates ( myArray ) {
  var i = myArray.length;
  if ( i == 0 ) return false;
  while ( --i ) {
     var j = Math.floor( Math.random() * ( i + 1 ) );
     var tempi = myArray[i];
     var tempj = myArray[j];
     myArray[i] = tempj;
     myArray[j] = tempi;
   }
}

//chooses a random element from an array to return given probabilistic weights for elements
//weights defaults to uniform selection
function randChoose(myArray, weights) {
	//default is to set it up intensionally
	if (typeof weights === "undefined") {
		weights = new Array();
		for (var i = 0; i < myArray.length; i++) {
			weights.push(1);
		}
	}
	
	if (weights.length != myArray.length) {
		throw "Error: choice array and weight array are of different lengths";
	}
	
	//creates an array of indices based on the weights array and randomly chooses one
	var weightArray = new Array();
	for (var i = 0; i < weights.length; i ++) {
		for (var j = 0; j < weights[i]; j++) {
			weightArray.push(i);	
		}
	}
	
	var randNum = weightArray[Math.floor(Math.random()*weightArray.length)];
	return myArray[randNum];
}

//handler for writing data to a qualtrics textbox
//it assumes there's only one qualtrics textbox on the page and initially sets
//it as hidden using CSS
function QualtricsTextBoxHandler () {
	this.q_textbox = $j(".InputText");
	this.q_textbox.css('display','none');
	
	this.addText = addText;
	this.clear = clear;
	this.overwrite = overwrite;
	this.showBox = showBox;
	this.hideBox = hideBox;
	
	function addText(text) {
		this.q_textbox.val(this.q_textbox.val()+String(text));
	}
	function clear() {
		this.q_textbox.val("");
	}
	function overwrite (text) {
		this.q_textbox.val(String(text));
	}
	function showBox() {
		this.q_textbox.css('display','inline');
	}
	function hideBox() {
		this.q_textbox.css('display','none');
	}
}

function QualtricsContinueHandler () {
	this.q_continueButton = $j("#NextButton");
	
	this.hide = hide;
	this.show = show;
	this.click = click;
	
	function hide() {
		this.q_continueButton.css('display','none');
	}
	
	function show() {
		this.q_continueButton.css('display','inline');
	}
	
	function click() {
		this.q_continueButton.click();
	}
}

function continueButtonDelay(time) {
	var cb = new QualtricsContinueHandler();
	cb.hide()
	setTimeout(function () {
		cb.show();
	}, time);
}

/*ObjectCollections
ObjectCollections provide a set of methods (essentially a type of syntax)
for seeing if an object satisfies some or all properties. An ObjectCollection
can be defined 'intensionally' or 'extensionally'. Intensionally means the properties
have been restricted by passing a dictionary where keys are properties of an object
and values are lists of values the property must take on to satisfy being in the 
ObjectCollection. If the collection is defined "Extensionally", this is basically
setting up a list and later seeing if objects are contained in that list.

This is best understood as a general implementation to be used for abstracting types
of states in the sequential cultural transmission task(e.g. context states/target states)

intensional ex: {color:["blue", "red"], shape:["hexagon"]}
extensional ex: [{color:"blue",shape:"hexagon"}, {color:"red", shape:"hexagon"}]


An eventual goal is for hierarchical relations between object collections.
*/
function ObjectCollection (def, isIntensional) {
	//default is to set it up intensionally
	isIntensional = (typeof isIntensional === "undefined") ? true : isIntensional;
	
	this.isIntensional = isIntensional;
	this.def = def;
	
	//OBJECT METHODS
	this.satisfiedBy = satisfiedBy;
	this.addDef = addDef;
	this.toString = toString;
	
	function satisfiedBy (example) {
		if (this.isIntensional) {
			for (var propName in this.def) {
				if (!(example.hasOwnProperty(propName) && //NOT (the thing has the property AND
					getIndex(example[propName],this.def[propName]) >= 0)) //the thing's property is in the property definition list)
					{
						return false;
					} 
			}
			return true;
		}
		else {
			//iterate through all elements in def array
			for (var i = 0; i < this.def.length; i++) {
				var match = true;
				//iterate through all properties of element
				for (var propName in this.def[i]) {
					//check if the example has the property, and if it matches
					//the corresponding property of the definition element
					if (!(example.hasOwnProperty(propName) && 
						example[propName] == this.def[i][propName])) {
							match = false;
					}
				}
				
				//iterate through all properties of the new example
				// test whether all properties of example are in definition
				for (var propName in example) {
					if (!(this.def[i].hasOwnProperty(propName) &&
						this.def[i][propName] == example[propName])) {
							match = false;
					}
				}
				if (match) { return true; }
			}
			return false;
		}
	}
	
	function addDef (newDef) {
		if (this.isIntensional) {
			if (newDef instanceof Array)
				{throw "Error: Intensional ObjectCollection takes associative arrays not arrays";}
			for (var propName in newDef) {
				if (this.def.hasOwnProperty(propName)) {
					var oldPropList = this.def[propName];
					this.def[propName] = oldPropList.concat(newDef[propName]);
				}
				else {
					this.def[propName] = newDef[propName];
				}
			}
		}
		else {
			for (var i = 0; i < newDef.length; i++) {
				this.def.push(newDef[i]);
			}
		}
	}
	
	function toString () {
		if (this.isIntensional) {
			var toReturn = new Array();
			for (propName in this.def) {
				toReturn.push(String(propName)+":["+this.def[propName].join(",")+"]");
			}
			return "{"+toReturn.join("; ")+"}";
		}
		else {
			var toReturn = new Array();
			for (var i = 0; i < this.def.length; i++) {
				var obj_sum = new Array();
				for (var propName in this.def[i]) {
					obj_sum.push(String(propName)+String(this.def[i][propName]));
				}
				toReturn.push("{"+obj_sum.join(",")+"}")
			}
			return toReturn.join(";");
		}
	}
}


//preload image
function preloadImage(url)
{
    var img=new Image();
    img.src=url;
}

//Object to String and String to Object Functions (only for objects with properties
//that are String types without quotes). Used for communicating data between qualtrics pages
function ObjToString(obj) {
	var temp_array = new Array();
	for (propName in obj) {
		temp_array.push(propName+":"+String(obj[propName]));
	}
	return temp_array.join(",");
}

function StringToObj(str) {
	str = String(str);
	var propStrings = str.split(",");
	var newObj = {};
	for (var i = 0; i < propStrings.length; i++) {
		var splitStr = propStrings[i].split(":");
		var propName = splitStr[0];
		var propVal = splitStr[1];
		newObj[propName] = propVal;
	}
	return newObj;
}

//loads parameters into a given string (e.g. for customized instructions)
//string parameters are identified by <~paramName~>
function loadStringParams(params, str) {
	for (propName in params) {
		var patt = new RegExp("<~"+propName+"~>", 'gm');
		str = str.replace(patt, params[propName]);
	}
	return str;
}

function getExpVars() {
	var exp_vars_div = $j("#experimental_variables").children();
	var exp_vars = {};
	for (var i=0; i<exp_vars_div.length; i++) {
		exp_vars[exp_vars_div[i].id] = $j(exp_vars_div[i]).text().trim();
		if (exp_vars_div[i].className == 'int') {
			exp_vars[exp_vars_div[i].id] = parseInt(exp_vars[exp_vars_div[i].id]);
		}
		else if (exp_vars_div[i].className == 'float') {
			exp_vars[exp_vars_div[i].id] = parseFloat(exp_vars[exp_vars_div[i].id]);
		}
	}

	return exp_vars;
}