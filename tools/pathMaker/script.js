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
/** @type {number} */
/** @type {Vector} */
let mouseVector;
/** @type {Vector} */
let fieldMouse;
/** @type {{vector: Vector, name: string, code: string, color: Object, segment: number}[]} */
const triggerPointList = [];
let previousTriggerPointCount;

const colorList = [
	{
		name: "gray",
		value: "2f4f4f",
	},
	{
		name: "maroon",
		value: "7f0000",
	},
	{
		name: "green",
		value: "008000",
	},
	{
		name: "blue",
		value: "000080",
	},
	{
		name: "orange",
		value: "ff8c00",
	},
	{
		name: "yellow",
		value: "ffff00",
	},
	{
		name: "lime",
		value: "00ff00",
	},
	{
		name: "aqua",
		value: "00ffff",
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

function updateTitle(handle) {
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
 * @param {number} index
 */
function removeTriggerPoint(index) {
	triggerPointList.splice(index, 1);
}

/**
 * removes the most recently made line vector & any trigger points on it
 */
function removeLastLineVector() {
	// if there is more than 1
	if (lineVectors.length > 1) {
		const previousLineVector = lineVectors[lineVectors.length - 2];
		const currentLineVector = lineVectors[lineVectors.length - 1];
		const length = ceil(previousLineVector.distTo(currentLineVector) / stepIncrement);
		for (let i = 0; i < length; i++) { // doesn'y this just take everything out of pointlist
			pointList.pop();
		}
		// deleting all related trigger points to the line vector being deleted
		for (let i = 0; i < triggerPointList.length; i++) { //
			const triggerPoint = triggerPointList[i];
			if (triggerPoint.segment === (lineVectors.length - 2)) {
				removeTriggerPoint(i);
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

function randomColor() {
	return colorList[Math.floor(Math.random() * colorList.length)];
}

/**
 *
 * @param {Vector} point
 * @param {Vector[]} lines list of points representing a line
 * @returns {{vector: Vector, i: number, fTo: number, fFrom: number}}
 */
function getClosestPointOnLines(point, lines) {
	let fFrom; let fTo; let i; let dist; let minDist; let x; let
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

	return {
		vector: new Vector(x, y), i, fTo, fFrom,
	};
}

function totalDist(listOfVectors) {
	let total = 0;
	for (let i = 0; i < listOfVectors.length - 1; i++) {
		total += listOfVectors[i].distTo(listOfVectors[i + 1]);
	}
	return total;
}

/**
 * makes a trigger point
 * @param {Vector} point Point at which to make the triggerPoint
 * @param {string} name Name of the triggerPoint
 * @param {Object} color Color of triggerPoint
 * @param {number} segment Index along list of lines that the triggerPoint sits on.
 */
function createTriggerPoint(point, name, color, segment, dist) {
	const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
	if (closestPoint.distTo(mouseVector.toField()) < 50) {
		// add to list this trigger point
		triggerPointList.push({
			vector: point, name, color, segment, dist,
		});
	}
}


// eslint-disable-next-line no-unused-vars
function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	imageCenter = new Vector(width / 2, height / 2);
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}

function updateHTML() {
	if ((document.readyState === "ready" || document.readyState === "complete") && previousTriggerPointCount !== triggerPointList.length) {
		if (triggerPointList.length > 0) {
			document.getElementById("triggerPointTitle").style.visibility = "visible";
		} else {
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
			triggerPointTitle.style.color = "#" + triggerPoint.color;
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
		getNewFileHandle().then((result) => {
			updateTitle(result);
			writeFileToDisk(result, JSON.stringify({ points: pointList, lineVectors, triggerPointList }));
			console.log(pointList);
			pointFile = result;
		});
	} else {
		updateTitle(pointFile);
		updateTitle(triggerPointFile);
		writeFileToDisk(pointFile, JSON.stringify({
			points: pointList, lineVectors, triggerPointList,
		}));
	}
}

async function openPoints() {
	const [fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectors = [];
	pointList = [];
	for (const lineVector of contents.lineVectors) {
		lineVectors.push(new Vector(lineVector.x, lineVector.y));
	}
	for (const point of contents.points) {
		pointList.push(new Vector(point.x, point.y));
	}
}

document.addEventListener("keydown", (e) => {
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
			const closestSegment = getClosestPointOnLines(fieldMouse, lineVectors).i - 1;
			const { vector, fTo } = getClosestPointOnLines(fieldMouse, lineVectors);

			const dist = totalDist(lineVectors.slice(0, -1)) + (totalDist(lineVectors.slice(-2)) * fTo);
			console.log(dist);


			createTriggerPoint(vector, null, randomColor().value, closestSegment, dist);
		}
		if (e.key === "Backspace") {
			const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
			removeLastLineVector(closestPoint);
			// REMOVE LAST TRIGGER POINT
		}
	}
}, false);

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
		console.log(totalDist(lineVectors));
		const previousPoint = lineVectors[lineVectors.length - 2];
		const currentPoint = lineVectors[lineVectors.length - 1];
		const length = previousPoint.distTo(currentPoint);
		const stepSize = (currentPoint.sub(previousPoint)).div(length);
		const targetDots = ceil(length / stepIncrement);


		if (lineVectors.length > 1) {
			const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;

			strokeWeight(12);
			stroke(150);
			point(...closestPoint.toScreen());

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
				point(
					pointList[i].toScreen().x,
					pointList[i].toScreen().y,
				);
			}
		}

		for (const item of triggerPointList) {
			stroke(0);
			strokeWeight(18);
			point(...item.vector.toScreen());
			strokeWeight(10);
			stroke("#" + item.color);
			point(...item.vector.toScreen());
		}

		lineVectorHasChanged = false;
	}
}
