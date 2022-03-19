// line vector - the big lines created when you click somewhere
// point - small points spaced about an inch apart that show up on each line vector;
// 		 these are mostly just for show on the maker and then used in pure pursuit in the robot code
// trigger point - these are user-specified points across our path, sitting on a chosen line vector,
//		 that will trigger a certain action at a part along the path

// eslint-disable-next-line no-undef
disableFriendlyErrors = true;

class Vector {
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
let pointList = [];
let lineVectors = [];
let lineVectorHasChanged = false;
const stepIncrement = 1;
let pointFile;
let imageCenter = null;
const visualizeNPoints = 10;
let closestPoint;
let closestSegment;
let mouseVector;
let fieldMouse;
const triggerPointList = [];
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

// eslint-disable-next-line no-unused-vars
//sets up field image as background
function preload() {
	img = loadImage("rapidreactfield.png");
}

// eslint-disable-next-line no-unused-vars
// sets up coordinates of cursor & displays them
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
			triggerPoint = triggerPointList[i];
			console.log("tpl, clv");
			console.log(triggerPointList[i].segment);
			console.log(lineVectors.length-2);
			console.log(triggerPointList[i].segment == (lineVectors.length-2))
			if(triggerPointList[i].segment == (lineVectors.length-2)) {
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
		if (e.key === "s") {
			e.preventDefault();
			savePoints();
		}
	
		if (e.key === "o") {
			e.preventDefault();
			openPoints();
		}
	
		if (e.key === " ") {
			e.preventDefault();
			createTriggerPoint(closestPoint, null, null, randomColor()["value"], closestSegment);
		}
		if (e.key === "Backspace") {
			removeLastLineVector(closestPoint);
			//REMOVE LAST TRIGGER POINT
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

function savePoints() {
	dataChangedSinceSave = false;
	if (pointFile == null) {
		getNewFileHandle().then(result => {
			updateTitle(result);
			writeFileToDisk(result, JSON.stringify({ points: pointList, "lineVectors": lineVectors }));
			console.log(pointList);
			pointFile = result;
		});
	}
	else {
		updateTitle(pointFile);
		writeFileToDisk(pointFile, JSON.stringify({ points: pointList, "lineVectors": lineVectors }));
	}
}

async function openPoints() {
	const [fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectors = [];
	pointList = [];	
	contents["lineVectors"].forEach((item) => {
		lineVectors.push(new Vector(item["x"], item["y"]));
	});
	contents["points"].forEach((item) => {
		pointList.push(new Vector(item["x"], item["y"]));
	});
}

function getClosestPointOnLines(pXy, aXys) {
	let fFrom, fTo, i, dist, minDist, x, y;

	for (let n = 1; n < aXys.length; n++) {
		if (aXys[n].x !== aXys[n - 1].x) {
			const a = (aXys[n].y - aXys[n - 1].y) / (aXys[n].x - aXys[n - 1].x);
			const b = aXys[n].y - a * aXys[n].x;
			dist = Math.abs(a * pXy.x + b - pXy.y) / Math.sqrt(a * a + 1);
		} else {
			dist = Math.abs(pXy.x - aXys[n].x);
		}

		// length of line segment 
		const rl = aXys[n].distTo(aXys[n - 1]);
		// distance of pt to end line segment
		const ln = pXy.distTo(aXys[n]);
		// distance of pt to begin line segment
		const lnm1 = pXy.distTo(aXys[n - 1]);
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

		const dx = aXys[i - 1].x - aXys[i].x;
		const dy = aXys[i - 1].y - aXys[i].y;

		x = aXys[i - 1].x - (dx * fTo);
		y = aXys[i - 1].y - (dy * fTo);

	}

	return { "vector": new Vector(x, y), "i": i, "fTo": fTo, "fFrom": fFrom };
}

// makes a trigger point
// point - closest point
//segment - closest path segment
/**
 * 
 * @param {Vector} point haha
 * @param {string} name haha
 * @param {*} code 
 * @param {Object} color 
 * @param {*} segment 
 */
function createTriggerPoint(point, name, code, color, segment) {
	let previousPoint = lineVectors[lineVectors.length - 1];

	if (closestPoint.distTo(mouseVector.toField()) < 50) { // if the distacne to the mouse on the field is less than 50
		//add to list this trigger point
		triggerPointList.push({"vector": point, "name": name, "code": code, "color": color, "segment": segment});
	}
}

/**
 * 
 * @param {*} lineSeg - line segment being deleted
 */
function removeTriggerPoint(lineSeg) {
	let winner;
	triggerPointList.splice(winner);
}

// eslint-disable-next-line no-unused-vars
function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	imageCenter = new Vector(width / 2, height / 2);
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}

function updateHTML() {
	if (document.readyState === "ready" || document.readyState === "complete" && previousTriggerPointCount != triggerPointList.length) {
		if (triggerPointList.length > 0) {
			document.getElementById("triggerPointTitle").style.visibility = "visible";
		}
		else {
			document.getElementById("triggerPointTitle").style.visibility = "hidden";
		}
		const triggerPointDiv = document.getElementById("triggerPointDiv");
		triggerPointDiv.innerHTML = "";
		triggerPointList.forEach((item, index) => {
			const triggerPointElement = document.createElement("div");
			const triggerPointTitle = document.createElement("h4");
			const triggerPointNameInput = document.createElement("input");
			triggerPointTitle.innerHTML = `Trigger point ${index}:`;
			triggerPointTitle.style.color = "#" + item["color"];
			triggerPointNameInput.id = `${index}nameInput`;
			triggerPointNameInput.style.zIndex = 999;
			triggerPointElement.style.display = "inline-block";
			triggerPointElement.appendChild(triggerPointTitle);
			triggerPointElement.appendChild(triggerPointNameInput);
			triggerPointDiv.appendChild(triggerPointElement);
		}); 
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
		for (let j = 0; j < pointList.length; j++) {
			if (j % visualizeNPoints === 0) {
				point(
					pointList[j].toScreen().x,
					pointList[j].toScreen().y
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