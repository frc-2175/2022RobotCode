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
		return dist(...this, ...vector);
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
			imageCenter.y + this.y / -pixelToInchRatio,
		);
	}

	toField() {
		return new Vector(
			-round((imageCenter.x - this.x) * pixelToInchRatio),
			round((imageCenter.y - this.y) * pixelToInchRatio),
		);
	}

	* [Symbol.iterator]() {
		yield this.x;
		yield this.y;
	}
}

let img;
let pixelToInchRatio = null;
/** @type {Vector[]} */
const points = [];
/** @type {Vector[]} */
const lineVectors = [];
let lineVectorHasChanged = false;
/** @type {Vector} */
let imageCenter = null;
const pointFreq = 10;
/** @type {Vector} */
/** @type {{vector: Vector, name: string, color: Object, segment: number}[]} */
let triggerPoints = [];
let previousTriggerPointCount;
let lastColor = 0;

const colorList = [
	{
		name: "red",
		value: "ff595e",
	},
	{
		name: "orange",
		value: "ff924c",
	},
	{
		name: "yellow",
		value: "ffca3a",
	},
	{
		name: "green",
		value: "8ac926",
	},
	{
		name: "aqua",
		value: "52e3e1",
	},
	{
		name: "blue",
		value: "0061e0",
	},
	{
		name: "purple",
		value: "7161ef",
	},
	{
		name: "bink",
		value: "ff7b9c",
	},
];

// sets up field image as background
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

	return false;
}


/**
 * gets the distance from start of list to a specified trigger point in the list
 * @param {*} lvIndex index of lineVector that tp lies on
 * @param {*} tpVector point/vector that triggerPoint is (location of TP)
 */
function totalDist(lvIndex, tpVector) {
	// const lvFragmentDistance = getClosestPointOnLines(tpVector,lineVectors).fTo * endLineVector.length;
	const endLineVector = lineVectors[lvIndex];
	console.log(lineVectors, lvIndex);
	let total = 0; // total distance up to specified triggerPoint
	const remainingDistance = endLineVector.distTo(tpVector);
	const end = lvIndex; // e

	// adding up all of the linevectors up to the specified one before our end TP
	for (let i = 0; i < end; i++) {
		total += lineVectors[i].distTo(lineVectors[i + 1]);
	}
	console.log("the main part is " + total);
	total += remainingDistance; // add distance to end vector
	console.log("the remaining distance is: " + remainingDistance);

	console.log("total distance : " + total); // logging :0)
}

function createNewLineVector(vector) {
	lineVectors.push(vector);
	lineVectorHasChanged = true;
	updateTitle(pointFile, true);
}

function createNewPoint(vector) {
	points.push(vector);
	updateTitle(pointFile);
}

/**
 * removes the most recently made line vector & any trigger points on it
 */
function removeLastLineVector() {
	// if there is more than 1
	if (lineVectors.length > 1) {
		const previousLineVector = lineVectors[lineVectors.length - 2];
		const currentLineVector = lineVectors[lineVectors.length - 1];
		const length = previousLineVector.distTo(currentLineVector);
		for (let i = 0; i < length; i++) { // doesn'y this just take everything out of pointlist
			points.pop();
		}
		console.log("go away");
		// deleting all related trigger points to the line vector being deleted
		for (let i = 0; i < triggerPoints.length; i++) { //
			const triggerPoint = triggerPoints[i];
			console.log("tpl, clv");
			console.log(triggerPoint.segment);
			console.log(lineVectors.length - 2);
			console.log(triggerPoint.segment === (lineVectors.length - 2));
			if (triggerPoint.segment === (lineVectors.length - 2)) {
				console.log("deleted a thing");
				triggerPoints.splice(i, 1);
				i--;
			}
		}
		lineVectors.pop();
		updateTitle(pointFile, true);
	}
}

// eslint-disable-next-line no-unused-vars
function mouseClicked() {
	if (canvasFocused()) {
		createNewLineVector((new Vector(mouseX, mouseY)).toField());
	}
}

// controls:
// s - save points
// o - open saved points
// space key - creates a trigger point
// backspace key - deletes last segment of path
document.addEventListener("keydown", (e) => {
	if (canvasFocused()) {
		if (e.key === "s" || e.key === "S") {
			e.preventDefault();
			savePoints();
		}

		if (e.key === "o" || e.key === "O") {
			console.log("GO'AWAY");
			e.preventDefault();
			openPoints();
			triggerPoints = [];
		}


		if (e.key === " ") {
			const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
			const closestSegment = getClosestPointOnLines(fieldMouse, lineVectors).i - 1;
			e.preventDefault();
			createTriggerPoint(closestPoint, null, nextColor().value, closestSegment);
		}

		if (e.key === "Backspace") {
			removeLastLineVector();
		}
	}
}, false);

function updateTitle(handle, dataChangedSinceSave) {
	try {
		if (dataChangedSinceSave) {
			document.title = "*" + handle.name;
		} else {
			document.title = handle.name;
		}
	} catch {
		// console.error("File not selected yet.");
	}
}

function nextColor() {
	lastColor = (lastColor + 1) % colorList.length;
	return colorList[lastColor];
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

let pointFile;
/**
 * saves all points & trigger points
 */
async function savePoints() {
	if (pointFile == null) {
		const fileHandle = await getNewFileHandle();
		updateTitle(fileHandle, false);
		writeFileToDisk(fileHandle, JSON.stringify({ points, lineVectors, triggerPoints }));
		console.log(points);
		pointFile = fileHandle;
	} else {
		updateTitle(pointFile, false);
		writeFileToDisk(pointFile, JSON.stringify({ points, lineVectors, triggerPoints }));
	}
}

async function openPoints() {
	const [fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectors.length = 0;
	points.length = 0;
	for (const lineVector of contents.lineVectors) {
		lineVectors.push(new Vector(lineVector.x, lineVector.y));
	}
	for (const point of contents.points) {
		points.push(new Vector(point.x, point.y));
	}

	for (const { vector, name, color, lineVectorIndex, distance } of contents.triggerPoints) {
		triggerPoints.push({
			vector: new Vector(vector.x, vector.y), name, color, lineVectorIndex, distance,
		});
		console.log(color);
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
	let fFrom,
		fTo,
		i,
		dist,
		minDist,
		x,
		y;

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
					fTo = 0;// nearer to previous point
					fFrom = 1;
				} else {
					fFrom = 0;// nearer to current point
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

	return { vector: new Vector(x, y), i, fTo, fFrom };
}

// makes a trigger point
// point - closest point
// segment - closest path segment
/**
 *
 * @param {Vector} vector Point at which to make the triggerPoint
 * @param {string} name Name of the triggerPoint
 * @param {Object} color Color of triggerPoint
 * @param {number} lineVectorIndex Index along list of line vectors that the triggerPoint sits on.
 */
function createTriggerPoint(vector, name, color, lineVectorIndex) {
	const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
	if (closestPoint.distTo(mouseVector.toField()) < 50) { // if the distacne to the mouse on the field is less than 50
		const distance = totalDist(lineVectorIndex, vector); // find the distance to the line segment point lies on
		// add to list this trigger point
		triggerPoints.push({ vector, name, color, lineVectorIndex, distance });
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
	if (document.readyState === "complete" && previousTriggerPointCount !== triggerPoints.length) {
		if (triggerPoints.length > 0) {
			document.getElementById("triggerPointTitle").style.visibility = "visible";
		} else {
			document.getElementById("triggerPointTitle").style.visibility = "hidden";
		}
		const triggerPointDiv = document.getElementById("triggerPointDiv");
		triggerPointDiv.innerHTML = "";
		for (let i = 0; i < triggerPoints.length; i++) {
			const triggerPoint = triggerPoints[i];
			const triggerPointElement = document.createElement("div");
			const triggerPointTitle = document.createElement("h4");
			const triggerPointNameInput = document.createElement("input");
			triggerPointTitle.innerHTML = `Trigger point ${i}:`;
			triggerPointTitle.style.color = "#" + triggerPoint.color;
			triggerPointNameInput.id = `${i}nameInput`;
			triggerPointNameInput.style.zIndex = 999;
			triggerPointElement.style.display = "inline-block";
			triggerPointElement.appendChild(triggerPointTitle);
			triggerPointElement.appendChild(triggerPointNameInput);
			triggerPointDiv.appendChild(triggerPointElement);
		}
		previousTriggerPointCount = triggerPoints.length;
	}
}

/** @type {Vector} */
let mouseVector;
/** @type {Vector} */
let fieldMouse;
// eslint-disable-next-line no-unused-vars
function draw() {
	updateHTML();
	mouseVector = new Vector(mouseX, mouseY);
	fieldMouse = mouseVector.toField();

	strokeWeight(0);
	image(img, 0, 0, width, height);
	fill(0);
	text("Screen coordinates: " + round(mouseX) + ", " + round(mouseY), 10, 20);
	text("Field coordinates: " + fieldMouse.x + ", " + fieldMouse.y, 10, 40);
	if (lineVectors.length > 0) {
		text("Current segment length: " + lineVectors[lineVectors.length - 1].distTo(fieldMouse), 10, 60);
	} else {
		text("Current segment length: " + 0, 10, 60);
	}

	if (lineVectors.length > 0) { // grey line to mouse.
		stroke(150);
		strokeWeight(2);
		line(...lineVectors[lineVectors.length - 1].toScreen(), ...mouseVector);
	}

	if (lineVectors.length > 1) {
		const previousPoint = lineVectors[lineVectors.length - 2];
		const currentPoint = lineVectors[lineVectors.length - 1];
		const length = previousPoint.distTo(currentPoint);
		const stepSize = (currentPoint.sub(previousPoint)).div(length);
		const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;

		strokeWeight(12);
		point(...closestPoint.toScreen());

		stroke(0);
		strokeWeight(8);
		if (lineVectorHasChanged) {
			for (let dotCount = 0; dotCount < length; dotCount++) {
				createNewPoint(previousPoint.add(stepSize.mul(dotCount)));
			}
		}

		noFill();
		strokeWeight(2);
		beginShape();
		for (let i = 0; i < lineVectors.length; i++) vertex(...lineVectors[i].toScreen());
		endShape();

		strokeWeight(5);
		for (let i = 0; i < points.length; i += pointFreq) {
			point(...points[i].toScreen());
		}

		for (const triggerPoint of triggerPoints) {
			stroke(0);
			strokeWeight(18);
			point(...triggerPoint.vector.toScreen());
			stroke("#" + triggerPoint.color);
			strokeWeight(10);
			point(...triggerPoint.vector.toScreen());
		}

		lineVectorHasChanged = false;
	}
}
