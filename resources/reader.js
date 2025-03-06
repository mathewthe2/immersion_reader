/*jshint esversion: 6 */
var lastParagraph;
var highlightedNode;
var lastSelectedIndex;
function tapToSelect(e) {
	if (getSelectionText()) {
		// dismiss popup dictionary by returning negative index
		console.log(JSON.stringify({
			"index": -1,
			"text": "",
			"messageType": "lookup",
			"timestamp": Date.now(),
			"x": e.clientX,
			"y": e.clientY,
			"isCreator": "no",
		}));
	} else {
		var result = document.caretRangeFromPoint(e.clientX, e.clientY);
		var selectedElement = result.startContainer;
		var paragraph = result.startContainer;
		var offsetNode = result.startContainer;
		var offset = result.startOffset;
		var adjustIndex = false;
		if (!!offsetNode && offsetNode.nodeType == Node.TEXT_NODE && offset) {
			const range = new Range();
			range.setStart(offsetNode, offset - 1);
			range.setEnd(offsetNode, offset);
			const bbox = range.getBoundingClientRect();
			if (bbox.left <= e.x && bbox.right >= e.x &&
				bbox.top <= e.y && bbox.bottom >= e.y) {

				result.startOffset = result.startOffset - 1;
				adjustIndex = true;
			}
		}

		while (paragraph && paragraph.nodeName !== 'P') {
			paragraph = paragraph.parentNode;
		}
		if (paragraph == null) {
			paragraph = result.startContainer.parentNode;
		}
		lastParagraph = paragraph;
		var noFuriganaText = [];
		var noFuriganaNodes = [];
		var selectedFound = false;
		var index = 0;
		for (var value of paragraph.childNodes.values()) {
			if (value.nodeName === "#text") {
				noFuriganaText.push(value.textContent);
				noFuriganaNodes.push(value);
				if (selectedFound === false) {
					if (selectedElement !== value) {
						index = index + value.textContent.length;
					} else {
						index = index + result.startOffset;
						selectedFound = true;
					}
				}
			} else {
				for (var node of value.childNodes.values()) {
					if (node.nodeName === "#text") {
						noFuriganaText.push(node.textContent);
						noFuriganaNodes.push(node);
						if (selectedFound === false) {
							if (selectedElement !== node) {
								index = index + node.textContent.length;
							} else {
								index = index + result.startOffset;
								selectedFound = true;
							}
						}
					} else if (node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
						noFuriganaText.push(node.firstChild.textContent);
						noFuriganaNodes.push(node.firstChild);
						if (selectedFound === false) {
							if (selectedElement !== node.firstChild) {
								index = index + node.firstChild.textContent.length;
							} else {
								index = index + result.startOffset;
								selectedFound = true;
							}
						}
					}
				}
			}
		}
		var text = noFuriganaText.join("");
		var offset = index;
		if (adjustIndex) {
			index = index - 1;
		}

		console.log(JSON.stringify({
			"index": index,
			"text": text,
			"messageType": "lookup",
			"timestamp": Date.now(),
			"x": e.clientX,
			"y": e.clientY,
		}));
		console.log(text[index]);
		lastSelectedIndex = index;
	}
}

function _getHighlightColor() {
	let theme = localStorage.getItem("theme");
	if (theme == null) {
		theme = 'light-theme';
	}
	switch (theme) {
		case 'light-theme': return "rgb(220, 220, 220)";
		case 'ecru-theme': return "rgb(204, 153, 51)";
		case 'water-theme': return "rgb(204, 220, 230)";
		case 'gray-theme': return "rgb(120, 120, 120)";
		case 'dark-theme': return "rgb(60, 60, 60)";
		case 'black-theme': return "rgb(50, 50, 50)";
		default: return "rgb(220, 220, 220)";
	}
}

function _highlightRange(range) {
	highlightedNode = document.createElement("span");
	highlightedNode.setAttribute(
		"style",
		"background-color: " + _getHighlightColor() + "; display: inline;"
	);
	range.surroundContents(highlightedNode);
}

function removeHighlight() {
	if (highlightedNode != null) {
		var parentNode = highlightedNode.parentNode;

		// Start with the content of the highlightedNode
		var combinedText = '';

		// Combine the text from the previous sibling if it exists
		var previousSibling = highlightedNode.previousSibling;
		if (previousSibling && previousSibling.nodeType === Node.TEXT_NODE) {
			combinedText += previousSibling.textContent;
		}

		// Add the text content of the highlightedNode
		combinedText += highlightedNode.textContent;

		// Combine the text from the next sibling if it exists
		var nextSibling = highlightedNode.nextSibling;
		if (nextSibling && nextSibling.nodeType === Node.TEXT_NODE) {
			combinedText += nextSibling.textContent;
		}

		// Create a single text node with the combined text content
		var newTextNode = document.createTextNode(combinedText);

		// Replace the highlightedNode (and its siblings) with the new text node
		if (previousSibling) {
			parentNode.removeChild(previousSibling); // Remove the previous sibling if it exists
		}
		parentNode.removeChild(highlightedNode); // Remove the highlightedNode

		if (nextSibling) {
			parentNode.removeChild(nextSibling); // Remove the next sibling if it exists
		}

		// Insert the new combined text node in place of the highlightedNode and siblings
		parentNode.appendChild(newTextNode);

		// Clear the reference to the highlightedNode
		highlightedNode = null;
	}
}

// highlight last tapped word
function highlightLast(initialOffset, textLength) {
	if (highlightedNode) {
		removeHighlight();
	}
	if (lastParagraph && lastSelectedIndex) {
		let textCounter = 0;
		let remainingOffset = Math.min(textLength, lastParagraph.textContent.length);
		for (var value of lastParagraph.childNodes.values()) {
			if (value.nodeName === "#text") {
				const counterSum = textCounter + value.textContent.length;
				if (counterSum > lastSelectedIndex || (remainingOffset > 0 && value !== lastParagraph.lastChild)) {
					const relativeOffset = Math.max(0, lastSelectedIndex + initialOffset - textCounter);
					const endOffset = Math.min(relativeOffset + remainingOffset, value.textContent.length);
					remainingOffset = Math.max(0, remainingOffset - endOffset);

					const range = document.createRange();
					range.selectNodeContents(value);
					range.setStart(range.startContainer, relativeOffset);
					range.setEnd(range.endContainer, endOffset);
					_highlightRange(range);

					if (remainingOffset === 0) {
						return;
					}
				}
				textCounter = counterSum;
			}
		}
	}
}

function getSelectionText() {
	function getRangeSelectedNodes(range) {
		var node = range.startContainer;
		var endNode = range.endContainer;
		if (node == endNode) return [node];
		var rangeNodes = [];
		while (node && node != endNode) rangeNodes.push(node = nextNode(node));
		node = range.startContainer;
		while (node && node != range.commonAncestorContainer) {
			rangeNodes.unshift(node);
			node = node.parentNode;
		}
		return rangeNodes;
		function nextNode(node) {
			if (node.hasChildNodes()) return node.firstChild;
			else {
				while (node && !node.nextSibling) node = node.parentNode;
				if (!node) return null;
				return node.nextSibling;
			}
		}
	}
	var txt = "";
	var nodesInRange;
	var selection;
	if (window.getSelection) {
		selection = window.getSelection();
		nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));
		nodes = nodesInRange.filter((node) => node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
		if (selection.anchorNode === selection.focusNode) {
			txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));
		} else {
			for (var i = 0; i < nodes.length; i++) {
				var node = nodes[i];
				if (i === 0) {
					txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));
				} else if (i === nodes.length - 1) {
					txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));
				} else {
					txt = txt.concat(node.textContent);
				}
			}
		}
	} else if (window.document.getSelection) {
		selection = window.document.getSelection();
		nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));
		nodes = nodesInRange.filter((node) => node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
		if (selection.anchorNode === selection.focusNode) {
			txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));
		} else {
			for (var i = 0; i < nodes.length; i++) {
				var node = nodes[i];
				if (i === 0) {
					txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));
				} else if (i === nodes.length - 1) {
					txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));
				} else {
					txt = txt.concat(node.textContent);
				}
			}
		}
	} else if (window.document.selection) {
		txt = window.document.selection.createRange().text;
	}
	return txt;
};
var reader = document.getElementsByClassName('book-content');
if (reader.length != 0) {
	reader[0].addEventListener('click', tapToSelect);
}
document.head.insertAdjacentHTML('beforebegin', `
  <style>
  rt {
	-webkit-touch-callout:none; /* iOS Safari */
	-webkit-user-select:none;   /* Chrome/Safari/Opera */
	-khtml-user-select:none;    /* Konqueror */
	-moz-user-select:none;      /* Firefox */
	-ms-user-select:none;       /* Internet Explorer/Edge */
	user-select:none;           /* Non-prefixed version */f
  }
  rp {
	-webkit-touch-callout:none; /* iOS Safari */
	-webkit-user-select:none;   /* Chrome/Safari/Opera */
	-khtml-user-select:none;    /* Konqueror */
	-moz-user-select:none;      /* Firefox */
	-ms-user-select:none;       /* Internet Explorer/Edge */
	user-select:none;           /* Non-prefixed version */
  }
  </style>
  `);
console.log('injected-popup-js');