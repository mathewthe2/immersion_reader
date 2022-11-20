String readerJs = """
/*jshint esversion: 6 */
function tapToSelect(e) {
    var result = document.caretRangeFromPoint(e.clientX, e.clientY);
    var selectedElement = result.startContainer;
    var paragraph = result.startContainer;
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
    
		console.log(JSON.stringify({
				"index": index,
				"text": text,
        "timestamp": Date.now(),
				"message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
			}));
  }
  var reader = document.getElementsByClassName('book-content');
  if (reader.length != 0) {
    reader[0].addEventListener('click', tapToSelect);
  }
""";
