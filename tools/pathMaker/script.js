/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
class Vector {
	constructor(x, y) {
		this.x = x;
		this.y = y;
	}

	convToScreenCoords() {
		return new Vector(xImageCenter + this.x / pixelToInchRatio, yImageCenter + this.y / pixelToInchRatio * -1);
	}

	convToFieldCoords() {
		return new Vector(round((xImageCenter - this.x) * pixelToInchRatio) * -1, round((yImageCenter - this.y) * pixelToInchRatio));
	}

	distTo(vector) {
		return dist(this.x, this.y, vector.x, vector.y);
	}
}

let img;
let dataChangedSinceSave = true;
let pixelToInchRatio = null;
let pointList = [];
let lineVectorList = [];
let lineVectorHasChanged = false;
const stepIncrement = 1;
let pointFile;
let xImageCenter = null;
let yImageCenter = null;
const visualizeNPoints = 16;
let currentSegment = 1;
let closestPoint;
let mouseVector;
let triggerPointList = [];

function preload() {
	img = loadImage("https://firebasestorage.googleapis.com/v0/b/pathmakerviewer.appspot.com/o/rapidreactfield.png?alt=media&token=8cf9f0e0-b56f-49b6-941b-c9240db1a2d7");
}

function setup() {
	createCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
	textSize(15);
}

function createNewLineVector(vector) {
	lineVectorList.push(vector);
	lineVectorHasChanged = true;
	dataChangedSinceSave = true;
	updateTitle(pointFile);
}

function convXToScreen(x) {
	return xImageCenter + x / pixelToInchRatio;
}

function convYToScreen(y) {
	return yImageCenter + y / pixelToInchRatio * -1;
}

function createNewPoint(vector) {
	pointList.push(vector);

	updateTitle(pointFile);
}

function removeLastLineVector() {
	if (1 < lineVectorList.length) {
		const previousPoint = lineVectorList[lineVectorList.length - 2];
		const currentPoint = lineVectorList[lineVectorList.length - 1];
		const length = ceil(previousPoint.distTo(currentPoint) / stepIncrement);
		for (let i = 0; i < length; i++) {
			pointList.pop();
		}
		currentSegment -= 1;
	}
	dataChangedSinceSave = true;
	lineVectorList.pop();
	updateTitle(pointFile);
}

function mousePressed() {
	const mouseVector = new Vector(mouseX, mouseY);
	createNewLineVector(mouseVector.convToFieldCoords());
}

document.addEventListener("keydown", function (e) {
	if (e.key === "s") {
		e.preventDefault();
		savePoints();
	}
	if (e.key === "o") {
		e.preventDefault();
		openPoints();
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
		console.error("File not selected yet.");
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

function savePoints() {
	dataChangedSinceSave = false;
	if (pointFile == null) {
		getNewFileHandle().then(result => {
			updateTitle(result);
			writeFileToDisk(result, JSON.stringify({ points: pointList, lineVectors: lineVectorList }));
			console.log(pointList);
			pointFile = result;
		});
	}
	else {
		updateTitle(pointFile);
		writeFileToDisk(pointFile, JSON.stringify({ points: pointList, lineVectors: lineVectorList }));
	}
}

async function openPoints() {
	let fileHandle;
	[fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectorList = [];
	pointList = [];
	contents["lineVectors"].forEach((item) => {
		lineVectorList.push(new Vector(item["x"], item["y"]));
	});
	contents["points"].forEach((item) => {
		pointList.push(new Vector(item["x"], item["y"]));
	});
}

function getClosestPointOnLines(pXy, aXys) {
	let minDist;
	let fTo;
	let fFrom;
	let x;
	let y;
	let i;
	let dist;

	if (aXys.length > 1) {

		for (let n = 1; n < aXys.length; n++) {

			if (aXys[n].x !== aXys[n - 1].x) {
				const a = (aXys[n].y - aXys[n - 1].y) / (aXys[n].x - aXys[n - 1].x);
				const b = aXys[n].y - a * aXys[n].x;
				dist = Math.abs(a * pXy.x + b - pXy.y) / Math.sqrt(a * a + 1);
			}
			else
				dist = Math.abs(pXy.x - aXys[n].x);

			// length^2 of line segment 
			const rl2 = Math.pow(aXys[n].y - aXys[n - 1].y, 2) + Math.pow(aXys[n].x - aXys[n - 1].x, 2);

			// distance^2 of pt to end line segment
			const ln2 = Math.pow(aXys[n].y - pXy.y, 2) + Math.pow(aXys[n].x - pXy.x, 2);

			// distance^2 of pt to begin line segment
			const lnm12 = Math.pow(aXys[n - 1].y - pXy.y, 2) + Math.pow(aXys[n - 1].x - pXy.x, 2);

			// minimum distance^2 of pt to infinite line
			const dist2 = Math.pow(dist, 2);

			// calculated length^2 of line segment
			const calcrl2 = ln2 - dist2 + lnm12 - dist2;

			// redefine minimum distance to line segment (not infinite line) if necessary
			if (calcrl2 > rl2)
				dist = Math.sqrt(Math.min(ln2, lnm12));

			if ((minDist == null) || (minDist > dist)) {
				if (calcrl2 > rl2) {
					if (lnm12 < ln2) {
						fTo = 0;//nearer to previous point
						fFrom = 1;
					}
					else {
						fFrom = 0;//nearer to current point
						fTo = 1;
					}
				}
				else {
					// perpendicular from point intersects line segment
					fTo = ((Math.sqrt(lnm12 - dist2)) / Math.sqrt(rl2));
					fFrom = ((Math.sqrt(ln2 - dist2)) / Math.sqrt(rl2));
				}
				minDist = dist;
				i = n;
			}
		}

		const dx = aXys[i - 1].x - aXys[i].x;
		const dy = aXys[i - 1].y - aXys[i].y;

		x = aXys[i - 1].x - (dx * fTo);
		y = aXys[i - 1].y - (dy * fTo);

	}

	return { "x": x, "y": y, "i": i, "fTo": fTo, "fFrom": fFrom };
}

function createTriggerPoint(point, name, code, color) {
	let dist = 0;
	lineVectorList.forEach((item, index) => {
		if (index != lineVectorList.length - 1) {
			dist += lineVectorList[index - 1].distTo(item);
		}
	});
	if (closestPoint.distTo(mouseVector.convToFieldCoords()) < 50) {
		triggerPointList.push({"vector": point, "name": name, "code": code, "color": color});
	}
	console.log(dist);
}

function keyPressed() {
	if (keyCode === 8) {
		removeLastLineVector(closestPoint);
	}
	if (keyCode === 32) {
		createTriggerPoint(closestPoint);
	}
}

function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}


function draw() {
	mouseVector = new Vector(mouseX, mouseY);
	const xCoord = mouseVector.convToFieldCoords().x;
	const yCoord = mouseVector.convToFieldCoords().y;

	background(220);
	strokeWeight(0);
	image(img, 0, 0, width, height);
	text("Screen coordinates: " + String(round(mouseX) + ", " + round(mouseY)), 10, 20);
	text("Field coordinates: " + xCoord + ", " + yCoord, 10, 40);

	if (1 < lineVectorList.length) {
		const currentLine = [lineVectorList[currentSegment - 1], lineVectorList[currentSegment]];
		if (getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).fFrom === 1 && currentSegment !== 1) {
			currentSegment -= 1;
		}
		if (getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).fFrom === 0 && lineVectorList.length >= currentSegment + 2) {
			currentSegment += 1;
		}
		closestPoint = new Vector(getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).x, getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).y);
		if (closestPoint.distTo(mouseVector.convToFieldCoords()) < 50) {
			strokeWeight(12);
			stroke(200);
			point(closestPoint.convToScreenCoords().x, closestPoint.convToScreenCoords().y);
			stroke(0);
		}
	}

	else {
		const currentLine = null;
	}

	stroke(0);
	strokeWeight(10);

	triggerPointList.forEach((item) => {
		point(item["vector"].convToScreenCoords().x, item["vector"].convToScreenCoords().y);
	});

	strokeWeight(1);

	if (lineVectorList.length === 1) {
		stroke(200);
		line(convXToScreen(lineVectorList[0].x), convYToScreen(lineVectorList[0].y), mouseX, mouseY);
	}
	else if (0 < lineVectorList.length) {
		lineVectorList.forEach((item, index) => {
			if (index !== 0) {
				const previousPoint = lineVectorList[index - 1];
				const currentPoint = item;
				let pointDrawCount = 0;

				pointList.forEach((item) => {
					if (pointDrawCount % visualizeNPoints === 0) {
						strokeWeight(5);
						point(item.convToScreenCoords().x, item.convToScreenCoords().y);
					}
					pointDrawCount += 1;
				});

				strokeWeight(2);
				line(convXToScreen(previousPoint.x), convYToScreen(previousPoint.y), convXToScreen(currentPoint.x), convYToScreen(currentPoint.y));
			}

			if (index === lineVectorList.length - 1) {
				stroke(200);
				line(convXToScreen(lineVectorList[lineVectorList.length - 1].x), convYToScreen(lineVectorList[lineVectorList.length - 1].y), mouseX, mouseY);
			}
		});

		const previousPoint = lineVectorList[lineVectorList.length - 2];
		const currentPoint = lineVectorList[lineVectorList.length - 1];
		const length = previousPoint.distTo(currentPoint);
		const xStepSize = ((currentPoint.x - previousPoint.x) / length);
		const yStepSize = ((currentPoint.y - previousPoint.y) / length);
		const targetDots = ceil(length / stepIncrement);

		stroke(0);

		if (1 < lineVectorList.length && lineVectorHasChanged) {
			let dotCount = 0;
			while (dotCount < targetDots) {
				const newPoint = new Vector(previousPoint.x + xStepSize * (stepIncrement * dotCount), previousPoint.y + yStepSize * (stepIncrement * dotCount));
				strokeWeight(8);
				createNewPoint(newPoint);
				dotCount += 1;
			}
		}
		lineVectorHasChanged = false;
	}
}