const String readerJs = """
/*jshint esversion: 6 */
function tapToSelect(e) {
	if (getSelectionText()) {
	  console.log(JSON.stringify({
				  "index": -1,
				  "text": getSelectionText(),
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
""";
