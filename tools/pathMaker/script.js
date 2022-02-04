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
let pixelToInchRatio = null;
let pointList = [];
let lineVectorList = [];
let lineVectorHasChanged = false;
const stepIncrement = 1;
let pointFile;
let xImageCenter = null;
let yImageCenter = null;
const visualizeNPoints = 16;

function preload() {
	img = loadImage("https://firebasestorage.googleapis.com/v0/b/pathmakerviewer.appspot.com/o/rapidreactfield.png?alt=media&token=8cf9f0e0-b56f-49b6-941b-c9240db1a2d7");
}

function setup() {
	//createCanvas(2987 / 3, 1757 / 3);
	createCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width /(2987/5));
	textSize(15);
}

function createNewLineVector(vector) {
	lineVectorList.push(vector);
	lineVectorHasChanged = true;
}

function convXToScreen(x) {
	return xImageCenter + x / pixelToInchRatio;
}

function convYToScreen(y) {
	return yImageCenter + y / pixelToInchRatio * -1;
}

function createNewPoint(vector) {
	pointList.push(vector);
}

function removeLastLineVector() {
	if (1 < lineVectorList.length) {
		const previousPoint = lineVectorList[lineVectorList.length - 2];
		const currentPoint = lineVectorList[lineVectorList.length - 1];
		const length = ceil(previousPoint.distTo(currentPoint) / stepIncrement);
		for (let i = 0; i < length; i++) {
			pointList.pop();
		}
	}

	lineVectorList.pop();
}

function mousePressed() {
	const mouseVector = new Vector(mouseX, mouseY);
	createNewLineVector(mouseVector.convToFieldCoords());
}

document.addEventListener("keydown", function(e) {
	if (e.key === "s") {
		e.preventDefault();
		savePoints();
	}
	if (e.key === "o") {
		e.preventDefault();
		openPoints();
	}
}, false);

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
	if (pointFile == null) {
		getNewFileHandle().then(result => {
			writeFileToDisk(result, JSON.stringify({points: pointList, lineVectors: lineVectorList}));
			console.log(pointList);
			pointFile = result;
		});
	}
	else {
		writeFileToDisk(pointFile, JSON.stringify({points: pointList, lineVectors: lineVectorList}));
	}
}

async function openPoints() {
	let fileHandle;
	[fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents)
	lineVectorList = []
	pointList = []
	contents["lineVectors"].forEach((item) => {
		console.log(item)
		lineVectorList.push(new Vector(item["x"], item["y"]))
	})
	contents["points"].forEach((item) => {
		pointList.push(new Vector(item["x"], item["y"]))
	})
}

function keyPressed() {
	if (keyCode === 8) {
		removeLastLineVector();
	}
}

function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width /(2987/5));
}


function draw() {
	const mouseVector = new Vector(mouseX, mouseY);
	const xCoord = mouseVector.convToFieldCoords().x;
	const yCoord = mouseVector.convToFieldCoords().y;

	background(220);
	strokeWeight(0);
	image(img, 0, 0, width, height);
	text("Screen coordinates: " + String(round(mouseX) + ", " + round(mouseY)), 10, 20);
	text("Field coordinates: " + xCoord + ", " + yCoord, 10, 40);
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