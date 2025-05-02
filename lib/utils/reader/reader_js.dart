const String readerJs = """
/*jshint esversion: 6 */
var lastParagraph;
var highlightedNodeList = [];
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
		// var noFuriganaNodes = [];
		var selectedFound = false;
		var index = 0;
		for (var value of paragraph.childNodes.values()) {
			if (value.nodeName === "#text") {
				noFuriganaText.push(value.textContent);
				// noFuriganaNodes.push(value);
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
						// noFuriganaNodes.push(node);
						if (selectedFound === false) {
							if (selectedElement !== node) {
								index = index + node.textContent.length;
							} else {
								index = index + result.startOffset;
								selectedFound = true;
							}
						}
					} else if ((node.firstChild?.nodeName === "#text" || node.firstChild?.nodeName === "SPAN") && node.nodeName !== "RT" && node.nodeName !== "RP") {
						for (const value of node.childNodes.values()) {
							if (value.nodeName !== "RT" && value.nodeName !== "RP") {
								noFuriganaText.push(value.textContent);

								if (!selectedFound) {
									// for higlighted furigana text
									if (value.childNodes.length > 0) {
										isHaveChildNodes = true;
										for (const grandChild of value.childNodes.values()) {
											if (selectedElement === grandChild) {
												index = index + result.startOffset;
												selectedFound = true;
												break;
											} else {
												index += _getNodeTextContent(grandChild).length;
											}
										}
									} else {
										if (selectedElement === value) {
											index += result.startOffset;
											selectedFound = true;
											break;
										} else {
											index += _getNodeTextContent(value).length;
										}
									}
								}
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
	highlightedNodeList.push(highlightedNode);
}

function removeHighlight() {
	for (const highlightedNode of highlightedNodeList) {
		var parentNode = highlightedNode.parentNode;

		// Case 1: If the highlighted node is part of a <ruby> structure
		if (parentNode && parentNode.tagName === 'RUBY') {
			// If the highlighted node is a <ruby> annotation (like <rt>)
			if (highlightedNode.nodeName === 'RT') {
				parentNode.removeChild(highlightedNode); // Simply remove the <rt> tag (annotation)
			} else if (highlightedNode.nodeType === Node.TEXT_NODE) {
				// If it's a text node, combine with adjacent text nodes
				var combinedText = '';
				var previousSibling = highlightedNode.previousSibling;
				if (previousSibling && previousSibling.nodeType === Node.TEXT_NODE) {
					combinedText += previousSibling.textContent;
				}
				combinedText += highlightedNode.textContent;

				var nextSibling = highlightedNode.nextSibling;
				if (nextSibling && nextSibling.nodeType === Node.TEXT_NODE) {
					combinedText += nextSibling.textContent;
				}

				// Create a new text node with the combined content
				var newTextNode = document.createTextNode(combinedText);

				// Replace the highlighted text node with the combined text
				parentNode.replaceChild(newTextNode, highlightedNode);

				// Remove the previous and next siblings if they are text nodes
				if (previousSibling && previousSibling !== highlightedNode) {
					parentNode.removeChild(previousSibling);
				}
				if (nextSibling && nextSibling !== highlightedNode) {
					parentNode.removeChild(nextSibling);
				}
			}
		} else {
			// Case 2: Non-<ruby> case (just text node highlight removal)
			var previousSibling = highlightedNode.previousSibling;
			var nextSibling = highlightedNode.nextSibling;

			var combinedText = '';
			if (previousSibling && previousSibling.nodeType === Node.TEXT_NODE) {
				combinedText += previousSibling.textContent;
			}

			combinedText += highlightedNode.textContent;

			if (nextSibling && nextSibling.nodeType === Node.TEXT_NODE) {
				combinedText += nextSibling.textContent;
			}

			// Create a new text node with the combined text
			var newTextNode = document.createTextNode(combinedText);

			// Replace the highlighted node with the new combined text node
			parentNode.replaceChild(newTextNode, highlightedNode);

			// Remove previous and next text nodes if necessary
			if (previousSibling && previousSibling !== highlightedNode) {
				parentNode.removeChild(previousSibling);
			}
			if (nextSibling && nextSibling !== highlightedNode) {
				parentNode.removeChild(nextSibling);
			}
		}
		highlightedNodeList = [];
	}
}



function _getNodeTextContent(node) {
	if (node.childNodes.length > 0) {
		return [...node.childNodes].filter((innerNode) => innerNode.parentElement.nodeName !== "RT"
			&& innerNode.parentElement.nodeName !== "RP"
			&& innerNode.parentElement.parentElement.nodeName !== "RT"
			&& innerNode.parentElement.parentElement.nodeName !== "RP").map((innerNode) => _getNodeTextContent(innerNode)).join("");
	} else {
		if (node?.nodeName !== "RT" && node?.nodeName !== "RP") {
			return node.textContent;
		}
	}
	return "";
}

// highlight last tapped word
function highlightLast(initialOffset, textLength) {
	if (initialOffset == null || textLength == null) {
		return;
	}
	if (highlightedNodeList.length > 0) {
		removeHighlight();
	}
	const rangesToHighlight = [];
	if (lastParagraph && lastSelectedIndex) {
		let textCounter = 0;
		let remainingOffset = Math.min(textLength, lastParagraph.textContent.length);
		for (var value of lastParagraph.childNodes.values()) {
			const textContent = _getNodeTextContent(value);
			if (textContent.length > 0) {
				let relativeOffset = Math.max(0, lastSelectedIndex + initialOffset - textCounter);

				// skip element if offset is longer than element contents
				if (relativeOffset > textContent.length) {
					textCounter += textContent.length;
					continue;
				}

				const counterSum = textCounter + textContent.length;

				if (counterSum > (lastSelectedIndex + initialOffset) && remainingOffset > 0) {
					if (value.nodeName === "RUBY" || value.nodeName === "SPAN") {
						const textNodes = [...value.childNodes].filter((node) => node.nodeName !== "RT" && node.nodeName !== "RP")
						let childTextCounter = textContent.length;

						for (const node of textNodes) {

							// skip node

							if (node.textContent.length <= relativeOffset) {
								relativeOffset -= node.textContent.length;
								continue;
							}

							const range = document.createRange();
							range.selectNodeContents(node);


							const startNode = range.startContainer?.childNodes[0] ?? range.startContainer;
							const startOffset = startNode.textContent.length >= relativeOffset ? relativeOffset : 0;
							range.setStart(startNode, startOffset);

							const endNode = range.endContainer?.childNodes[0] ?? range.endContainer;
							const endOffset = Math.min(relativeOffset + remainingOffset, endNode.textContent.length);
							range.setEnd(endNode, Math.min(node.textContent.length, endOffset));

							// console.log("startNode", startNode);
							// console.log("endNode", endNode);
							// console.log("startOffset", startOffset);
							// console.log("endOffset", endOffset);
							childTextCounter += node.textContent.length;
							rangesToHighlight.push(range);

							remainingOffset = Math.max(0, remainingOffset - endOffset + startOffset);
							if (remainingOffset === 0) {
								break;
							}
						}
					} else {
						const range = document.createRange();
						range.selectNodeContents(value);
						const endOffset = Math.min(relativeOffset + remainingOffset, textContent.length);

						remainingOffset = Math.max(0, remainingOffset - (endOffset - relativeOffset));

						range.setStart(range.startContainer, relativeOffset);
						range.setEnd(range.endContainer, endOffset);

						rangesToHighlight.push(range);
					}

					if (remainingOffset === 0) {
						break;
					}
				}
				textCounter = counterSum;
			}
		}
	}
	for (const range of rangesToHighlight) {
		_highlightRange(range);
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
	reader[0].addEventListener('mousedown', tapToSelect);
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
""";
