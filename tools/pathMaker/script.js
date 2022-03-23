// line vector - the big lines created when you click somewhere
// point - small points spaced about an inch apart that show up on each line vector;
// 		 these are mostly just for show on the maker and then used in pure pursuit in the robot code
// trigger point - these are user-specified points across our path, sitting on a chosen line vector,
//		 that will trigger a certain action at a part along the path

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
/** @type {number} */
let pixelToInchRatio = null;
/** @type {Vector[]} */
const points = [];
/** @type {Vector[]} */
const lineVectors = [];
/** @type {boolean} */
let lineVectorHasChanged = false;
/** @type {Vector} */
let imageCenter = null;
const pointFreq = 10;
/** @type {{vector: Vector, name: string, code: string, color: string, segment: number}[]} */
const triggerPoints = [];

let scale = 1;

const colorList = [
	{ name: "gray", value: "#2f4f4f" },
	{ name: "maroon", value: "#7f0000" },
	{ name: "green", value: "#008000" },
	{ name: "blue", value: "#000080" },
	{ name: "orange", value: "#ff8c00" },
	{ name: "yellow", value: "#ffff00" },
	{ name: "lime", value: "#00ff00" },
	{ name: "aqua", value: "#00ffff" },
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
	pixelToInchRatio = (1.37 / (width / (2987 / 5))) / scale;
	textSize(15);
	imageMode(CENTER);
}

function canvasFocused() {
	return mouseY > 0 && mouseY < (windowWidth * 0.58) && mouseX > 0 && mouseX < windowWidth;
}

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

function createNewLineVector(vector) {
	lineVectors.push(vector);
	lineVectorHasChanged = true;
	updateTitle(pointFile, true);
}

function createNewPoint(vector) {
	points.push(vector);
	updateTitle(pointFile);
}

/** @param {number} index */
function removeTriggerPoint(index) {
	triggerPoints.splice(index, 1);
}

/**
 * removes the most recently made line vector & any trigger points on it
 */
function removeLastLineVector() {
	if (lineVectors.length > 1) { // if there is more than 1
		const previousLineVector = lineVectors[lineVectors.length - 2];
		const currentLineVector = lineVectors[lineVectors.length - 1];
		const length = previousLineVector.distTo(currentLineVector);
		points.splice(-length); // remove length elements from end of array
		// deleting all related trigger points to the line vector being deleted
		for (let i = 0; i < triggerPoints.length; i++) {
			if (triggerPoints[i].segment === (lineVectors.length - 2)) {
				removeTriggerPoint(i--);
			}
		}
	}
	lineVectors.pop();
	updateTitle(pointFile, true);
}

// eslint-disable-next-line no-unused-vars
function mouseClicked() {
	if (canvasFocused()) {
		createNewLineVector(fieldMouse);
	}
}

function randomColor() {
	return colorList[Math.floor(Math.random() * colorList.length)];
}

/**
 * @param {Vector} point
 * @param {Vector[]} lines list of points representing a line
 * @returns {{vector: Vector, i: number, fTo: number, fFrom: number}}
 */
function getClosestPointOnLines(point, lines) {
	let fFrom; let fTo; let i; let dist; let minDist; let x; let y;

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

function totalDist(listOfVectors) {
	let total = 0;
	for (let i = 0; i < listOfVectors.length - 1; i++) {
		total += listOfVectors[i].distTo(listOfVectors[i + 1]);
	}
	return total;
}

/**
 * makes a trigger point
 * @param {Vector} vector Point at which to make the triggerPoint
 * @param {string} name Name of the triggerPoint
 * @param {string} color Color of triggerPoint
 * @param {number} segment Index along list of lines that the triggerPoint sits on.
 */
function createTriggerPoint(vector, name, color, segment, dist) {
	const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
	if (closestPoint.distTo(mouseVector.toField()) < 50) {
		triggerPoints.push({ vector, name, color, segment, dist });
	}
}

// eslint-disable-next-line no-unused-vars
function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	imageCenter = new Vector(width / 2, height / 2);
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}

let prevTriggers = 0;
function updateHTML() {
	if (document.readyState === "complete" && prevTriggers !== triggerPoints.length) {
		document.getElementById("triggerTitle").style.display = triggerPoints.length ? "block" : "none";
		const triggerDiv = document.getElementById("triggerDiv");
		triggerDiv.innerHTML = "";
		for (let i = 0; i < triggerPoints.length; i++) {
			const triggerTitle = document.createElement("h4");
			triggerTitle.innerHTML = `Trigger point ${i}:`;
			triggerTitle.style.color = triggerPoints[i].color;

			const triggerNameInput = document.createElement("input");
			triggerNameInput.id = `${i}nameInput`;
			triggerNameInput.style.zIndex = 999;

			const triggerElement = document.createElement("div");
			triggerElement.style.display = "inline-block";
			triggerElement.appendChild(triggerTitle);
			triggerElement.appendChild(triggerNameInput);

			triggerDiv.appendChild(triggerElement);
		}
		prevTriggers = triggerPoints.length;
	}
}


async function getNewFileHandle() {
	const options = {
		types: [{
			description: "Pure Pursuit Path File",
			accept: { "text/plain": ".path" },
		}],
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
	// we do this because contents has json objects, not our vector classes.
	for (const lineVector of contents.lineVectors) {
		lineVectors.push(new Vector(lineVector.x, lineVector.y));
	}
	for (const point of contents.points) {
		points.push(new Vector(point.x, point.y));
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

			const startDist = totalDist(lineVectors.slice(0, -1));
			const dist = startDist + (totalDist(lineVectors.slice(-2)) * fTo);
			console.log(dist);

			createTriggerPoint(vector, null, randomColor().value, closestSegment, dist);
		}
		if (e.key === "Backspace") {
			const closestPoint = getClosestPointOnLines(fieldMouse, lineVectors).vector;
			removeLastLineVector(closestPoint);
		}
	}
}, false);

// eslint-disable-next-line no-unused-vars
function mouseWheel(event) {
	console.log(event.delta);
	scale *= 1.005 ** event.delta;
	pixelToInchRatio = (1.37 / (width / (2987 / 5))) / scale;
}

/** @type {Vector} */
let mouseVector;
/** @type {Vector} */
let fieldMouse;
// eslint-disable-next-line no-unused-vars
function draw() {
	clear();
	updateHTML();
	mouseVector = new Vector(mouseX, mouseY);
	fieldMouse = mouseVector.toField();

	strokeWeight(0);
	image(img, width / 2, height / 2, scale * width, scale * height);
	fill(0);
	text("Screen coordinates: " + round(mouseX) + ", " + round(mouseY), 10, 20);
	text("Field coordinates: " + fieldMouse.x + ", " + fieldMouse.y, 10, 40);

	if (lineVectors.length > 0) { // grey line to mouse
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
		for (let i = 0; i < points.length; i++) {
			if (i % pointFreq === 0) {
				point(...points[i].toScreen());
			}
		}

		for (const triggerPoint of triggerPoints) {
			stroke(0);
			strokeWeight(18);
			point(...triggerPoint.vector.toScreen());
			stroke(triggerPoint.color);
			strokeWeight(10);
			point(...triggerPoint.vector.toScreen());
		}

		lineVectorHasChanged = false;
	}
}
