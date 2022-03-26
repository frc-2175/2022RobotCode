// line vector - the big lines created when you click somewhere
// point - small points spaced about an inch apart that show up on each line vector;
// 		 these are mostly just for show on the maker and then used in pure pursuit in the robot code
// trigger point - these are user-specified points across our path, sitting on a chosen line vector,
//		 that will trigger a certain action at a part along the path

// eslint-disable-next-line no-undef
disableFriendlyErrors = true;

/** Class representing a vector. */
class Vector {
	/**
	 * Create a Vector
	 * @param {number} x 
	 * @param {number} y 
	 */
	constructor(x, y) {
		this.x = x;
		this.y = y;
	}

	distTo(vector) {
		return dist(this.x, this.y, vector.x, vector.y);
	}

	add(vector) {
		vector = typeof vector === "number" ? new Vector(vector, vector) : vector;
		return new Vector(this.x + vector.x, this.y + vector.y);
	}

	sub(vector) {
		vector = typeof vector === "number" ? new Vector(vector, vector) : vector;
		return new Vector(this.x - vector.x, this.y - vector.y);
	}

	div(vector) {
		vector = typeof vector === "number" ? new Vector(vector, vector) : vector;
		return new Vector(this.x / vector.x, this.y / vector.y);
	}
	
	mul(vector) {
		vector = typeof vector === "number" ? new Vector(vector, vector) : vector;
		return new Vector(this.x * vector.x, this.y * vector.y);
	}

	toScreen() {
		return new Vector(
			imageCenter.x + this.x / pixelToInchRatio,
			imageCenter.y + this.y / -pixelToInchRatio
		);
	}

	toField() {
		return new Vector(
			-round((imageCenter.x - this.x) * pixelToInchRatio),
			round((imageCenter.y - this.y) * pixelToInchRatio)
		);
	}

	*[Symbol.iterator] () {
		yield this.x;
		yield this.y;
	}
}

let img;
let dataChangedSinceSave = true;
let pixelToInchRatio = null;
/** @type {Vector[]} */
let pointList = [];
/** @type {Vector[]} */
let lineVectors = [];
let lineVectorHasChanged = false;
const stepIncrement = 1;
let pointFile;
let triggerPointFile;
/** @type {Vector} */
let imageCenter = null;
const visualizeNPoints = 10;
/** @type {Vector} */
let closestPoint;
let closestSegment; //
/** @type {Vector} */
let mouseVector;
/** @type {Vector} */
let fieldMouse;
/** @type {{vector: Vector, name: string, code: string, color: Object, segment: number}[]} */
let triggerPointList = [];
let previousTriggerPointCount;

const colorList = [
	{
		"name": "gray",
		"value": "2f4f4f"
	},
	{
		"name": "maroon",
		"value": "7f0000"
	},
	{
		"name": "green",
		"value": "008000"
	},
	{
		"name": "blue",
		"value": "000080"
	},
	{
		"name": "orange",
		"value": "ff8c00"
	},
	{
		"name": "yellow",
		"value": "ffff00"
	},
	{
		"name": "lime",
		"value": "00ff00"
	},
	{
		"name": "aqua",
		"value": "00ffff"
	}
];

//sets up field image as background
// eslint-disable-next-line no-unused-vars
function preload() {
	img = loadImage("rapidreactfield.png");
}

// sets up coordinates of cursor & displays them
// eslint-disable-next-line no-unused-vars
function setup() {
	createCanvas(windowWidth, (windowWidth * 0.58));
	imageCenter = new Vector(width / 2, height / 2);
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
	textSize(15);
}

//
function canvasFocused() {
	if (mouseY > 0 && mouseY < (windowWidth * 0.58) && mouseX > 0 && mouseX < windowWidth) {
		return true;
	}
	else {
		return false;
	}
}

// triggerPointList.push({"vector": point, "name": name, "code": code, "color": color, "segment": segment/*, "distance": distance */});
/**
 * gets the distance from start of list to a specified trigger point in the list
 * @param {*} lvIndex index of lineVector that tp lies on
 * @param {*} tpVector point/vector that triggerPoint is (location of TP)
 */
function totalDist(lvIndex, tpVector) {
	// const lvFragmentDistance = getClosestPointOnLines(tpVector,lineVectors).fTo * endLineVector.length;
	const endLineVector = lineVectors[lvIndex];
	let total = 0; // total distance up to specified triggerPoint
	const remainingDistance = endLineVector.distTo(tpVector);
	const end = lvIndex; //e

	//adding up all of the linevectors up to the specified one before our end TP
	for (let i = 0 ; i < end ; i++) {
		total += lineVectors[i].distTo(lineVectors[i+1]);
	}
	console.log("the main part is " + total);
	total += remainingDistance; //add distance to end vector
	console.log("the remaining distance is: " + remainingDistance);

	console.log("total distance : " + total); //logging :0)
}

function createNewLineVector(vector) {
	lineVectors.push(vector);
	lineVectorHasChanged = true;
	dataChangedSinceSave = true;
	updateTitle(pointFile);
}

function createNewPoint(vector) {
	pointList.push(vector);
	updateTitle(pointFile);
}

/**
 * removes the most recently made line vector & any trigger points on it
 */
function removeLastLineVector() {
	//if there is more than 1
	if (lineVectors.length > 1) {
		const previousLineVector = lineVectors[lineVectors.length - 2];
		const currentLineVector = lineVectors[lineVectors.length - 1];
		const length = ceil(previousLineVector.distTo(currentLineVector) / stepIncrement);
		for (let i = 0; i < length; i++) {// doesn'y this just take everything out of pointlist
			pointList.pop();
		}
		console.log("go away");
		//deleting all related trigger points to the line vector being deleted
		// triggerPointList.push({"vector": point, "name": name, "code": code, "color": color, "segment": segment});
		for (let i = 0; i < triggerPointList.length; i++) { //
			const triggerPoint = triggerPointList[i];
			console.log("tpl, clv");
			console.log(triggerPoint.segment);
			console.log(lineVectors.length-2);
			console.log(triggerPoint.segment === (lineVectors.length-2));
			if (triggerPoint.segment === (lineVectors.length-2)) {
				console.log("deleted a thing");
				triggerPointList.splice(i,1);
				i--;
			}
		}
	}
	dataChangedSinceSave = true;
	lineVectors.pop();	
	updateTitle(pointFile);
}

// eslint-disable-next-line no-unused-vars
function mouseClicked() {
	if (canvasFocused()) {
		createNewLineVector((new Vector(mouseX, mouseY)).toField());
	}
}

//controls:
// s - save points 
// o - open saved points
// space key - creates a trigger point 
// backspace key - deletes last segment of path
document.addEventListener("keydown", function (e) {
	if (canvasFocused()) {
		if (e.key === "s"|| e.key === "S") {
			e.preventDefault();
			savePoints();
		}
	
		if (e.key === "o" || e.key === "O") {
			console.log("GO'AWAY");
			e.preventDefault();
			openPoints();
			triggerPointList = [];
		}
	
		if (e.key === " ") {
			e.preventDefault();
			createTriggerPoint(closestPoint, null, null, randomColor()["value"], closestSegment);
		}
		if (e.key === "Backspace") {
			removeLastLineVector(closestPoint);
		}
	}
}, false);

function updateTitle(handle) {
	try {
		if (dataChangedSinceSave) {
			document.title = "*" + handle.name;
		}
		else {
			document.title = handle.name;
		}
	}
	catch {
		//console.error("File not selected yet.");
	}
}

function randomColor() {
	return colorList[Math.floor(Math.random() * colorList.length)];
}

async function getNewFileHandle() {
	const options = {
		types: [
			{
				description: "Pure Pursuit Path File",
				accept: {
					"text/plain": [".path"],
				},
			},
		],
	};
	const handle = await window.showSaveFilePicker(options);
	return handle;
}

async function writeFileToDisk(fileHandle, contents) {
	// Create a FileSystemWritableFileStream to write to.
	const writable = await fileHandle.createWritable();
	// Write the contents of the file to the stream.
	await writable.write(contents);
	// Close the file and write the contents to disk.
	await writable.close();
}

/**
 * saves all points & trigger points
 */
function savePoints() {
	dataChangedSinceSave = false;
	if (pointFile == null) {
		getNewFileHandle().then(result => {
			updateTitle(result);

			writeFileToDisk(result, JSON.stringify({ points: pointList, "lineVectors": lineVectors, "triggerPoints":triggerPointList }));
			console.log(pointList);
			pointFile = result;
		});
	}
	else {
		updateTitle(pointFile);
		writeFileToDisk(pointFile, JSON.stringify({ points: pointList, "lineVectors": lineVectors , "triggerPoints": triggerPointList}));
	}
}

async function openPoints() {
	const [fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectors = [];
	pointList = [];	
	for (const lineVector of contents["lineVectors"]) {
		lineVectors.push(new Vector(lineVector["x"], lineVector["y"]));
	}
	for (const point of contents["points"]) {
		pointList.push(new Vector(point["x"], point["y"]));
	}
	// triggerPointList.push({"vector": point, "name": name, "code": code, "color": color, "lineVectorIndex": lineVectorIndex, "distance": distance });
	for (const tp of contents["triggerPoints"]) {
		triggerPointList.push({ "vector": new Vector(tp["vector"]["x"], tp["vector"]["y"]),"name":tp["name"],"code":tp["code"],"color":tp["color"],"lineVectorIndex":tp["lineVectorIndex"],"distance":tp["distance"] });
		//triggerPointList.push({ tp["vector"],tp["name"],tp["code"],tp["color"],tp["lineVectorIndex"],tp["distance"] });
		console.log(tp["color"]);
	}
}

/**
 * gets the closest point to a singular point/vector on a specified lineVector
 * @param {Vector} point 
 * @param {Vector[]} lines - list of points representing a line
 * @returns {Vector} vector - Vector of closesst point 
 * @returns {number} i - Index of closest point along lines
 * @returns {number} fTo - Relative distance on line to start point
 * @returns {number} fFrom - Relative distance on line to end point
 */
function getClosestPointOnLines(point, lines) {
	let fFrom, fTo, i, dist, minDist, x, y;

	for (let n = 1; n < lines.length; n++) {
		if (lines[n].x !== lines[n - 1].x) {
			const a = (lines[n].y - lines[n - 1].y) / (lines[n].x - lines[n - 1].x);
			const b = lines[n].y - a * lines[n].x;
			dist = Math.abs(a * point.x + b - point.y) / Math.sqrt(a * a + 1);
		} else {
			dist = Math.abs(point.x - lines[n].x);
		}

		// length of line segment 
		const rl = lines[n].distTo(lines[n - 1]);
		// distance of pt to end line segment
		const ln = point.distTo(lines[n]);
		// distance of pt to begin line segment
		const lnm1 = point.distTo(lines[n - 1]);
		// calculated length of line segment
		const calcrl = ln + lnm1 - dist;

		// redefine minimum distance to line segment (not infinite line) if necessary
		if (calcrl > rl) dist = Math.min(ln, lnm1);

		if (minDist == null || minDist > dist) {
			if (calcrl > rl) {
				if (lnm1 < ln) {
					fTo = 0;//nearer to previous point
					fFrom = 1;
				}
				else {
					fFrom = 0;//nearer to current point
					fTo = 1;
				}
			} else {
				// perpendicular from point intersects line segment
				fTo = Math.sqrt(lnm1 ** 2 - dist ** 2) / rl;
				fFrom = Math.sqrt(ln ** 2 - dist ** 2) / rl;
			}
			minDist = dist;
			i = n;
		}

		const dx = lines[i - 1].x - lines[i].x;
		const dy = lines[i - 1].y - lines[i].y;

		x = lines[i - 1].x - (dx * fTo);
		y = lines[i - 1].y - (dy * fTo);

	}

	return { "vector": new Vector(x, y), "i": i, "fTo": fTo, "fFrom": fFrom };
}

// makes a trigger point
// point - closest point
//segment - closest path segment
/**
 * 
 * @param {Vector} point Point at which to make the triggerPoint
 * @param {string} name Name of the triggerPoint
 * @param {*} code Code to run at trigger Point(maybe not happening)
 * @param {Object} color Color of triggerPoint
 * @param {number} lineVectorIndex Index along list of line vectors that the triggerPoint sits on.
 */
function createTriggerPoint(point, name, code, color, lineVectorIndex) {
	if (closestPoint.distTo(mouseVector.toField()) < 50) { // if the distacne to the mouse on the field is less than 50
		const distance = totalDist(lineVectorIndex, point); // find the distance to the line segment point lies on
		// console.log("Distance to trigger point: " + distance); 
		//add to list this trigger point
		triggerPointList.push({"vector": point, "name": name, "code": code, "color": color, "lineVectorIndex": lineVectorIndex, "distance": distance });
	}
}

// /** TODO : Make this a thing
//  * @param {number} index
//  */
// function removeTriggerPoint(index) {
// 	triggerPointList.splice(index, 1);
// }

// eslint-disable-next-line no-unused-vars
function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	imageCenter = new Vector(width / 2, height / 2);
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}

function updateHTML() {
	if (document.readyState === "ready" || document.readyState === "complete" && previousTriggerPointCount !== triggerPointList.length) {
		if (triggerPointList.length > 0) {
			document.getElementById("triggerPointTitle").style.visibility = "visible";
		}
		else {
			document.getElementById("triggerPointTitle").style.visibility = "hidden";
		}
		const triggerPointDiv = document.getElementById("triggerPointDiv");
		triggerPointDiv.innerHTML = "";
		for (let i = 0; i < triggerPointList.length; i++) {
			const triggerPoint = triggerPointList[i];
			const triggerPointElement = document.createElement("div");
			const triggerPointTitle = document.createElement("h4");
			const triggerPointNameInput = document.createElement("input");
			triggerPointTitle.innerHTML = `Trigger point ${i}:`;
			triggerPointTitle.style.color = "#" + triggerPoint["color"];
			triggerPointNameInput.id = `${i}nameInput`;
			triggerPointNameInput.style.zIndex = 999;
			triggerPointElement.style.display = "inline-block";
			triggerPointElement.appendChild(triggerPointTitle);
			triggerPointElement.appendChild(triggerPointNameInput);
			triggerPointDiv.appendChild(triggerPointElement);
		}
		previousTriggerPointCount = triggerPointList.length;
	}
}
// eslint-disable-next-line no-unused-vars
function draw() {
	updateHTML();
	mouseVector = new Vector(mouseX, mouseY);
	fieldMouse = mouseVector.toField();

	background(220);
	strokeWeight(0);
	image(img, 0, 0, width, height);
	fill(0);
	text("Screen coordinates: " + String(round(mouseX) + ", " + round(mouseY)), 10, 20);
	text("Field coordinates: " + fieldMouse.x + ", " + fieldMouse.y, 10, 40);

	strokeWeight(1);

	if (lineVectors.length === 1) {
		stroke(150);
		line(...lineVectors[0].toScreen(), ...mouseVector);
	} else if (lineVectors.length > 0) {
		const previousPoint = lineVectors[lineVectors.length - 2];
		const currentPoint = lineVectors[lineVectors.length - 1];
		const length = previousPoint.distTo(currentPoint);
		const stepSize = (currentPoint.sub(previousPoint)).div(length);
		const targetDots = ceil(length / stepIncrement);

		
		if (lineVectors.length > 1) {
			closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
			closestSegment = getClosestPointOnLines(fieldMouse, lineVectors).i - 1;

			strokeWeight(12);
			stroke(150);
			point(closestPoint.toScreen().x, closestPoint.toScreen().y);

			if (lineVectorHasChanged) {
				for (let dotCount = 0; dotCount < targetDots; dotCount++) {
					const newPoint = previousPoint.add(stepSize.mul(stepIncrement * dotCount));
					stroke(0);
					strokeWeight(8);
					createNewPoint(newPoint);
				}
			}
		}

		beginShape();
		for (let i = 0; i < lineVectors.length; i++) {
			const item = lineVectors[i];
			vertex(item.toScreen().x, item.toScreen().y);

			if (i === lineVectors.length - 1) {
				stroke(150);
				strokeWeight(2);
				line(...lineVectors[i].toScreen(), ...mouseVector);
			}
		}
		noFill();
		stroke(0);
		strokeWeight(2);
		endShape();
		
		strokeWeight(5);
		for (let i = 0; i < pointList.length; i++) {
			if (i % visualizeNPoints === 0) {
				pointList[i];
				point(
					pointList[i].toScreen().x,
					pointList[i].toScreen().y
				);
			}
		} 

		for (const item of triggerPointList) {
			stroke(0);
			strokeWeight(18);
			point(...item["vector"].toScreen());
			strokeWeight(10);
			stroke("#" + item["color"]);
			point(...item["vector"].toScreen());
		}
		
		lineVectorHasChanged = false;
	}
}