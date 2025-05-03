const String classPrefix = "ttu-whispersync-line-highlight";

String _nodeHighlightColor = """
function _getNodeHighlightColor() {
	let theme = localStorage.getItem("theme");
	if (theme == null) {
		theme = 'light-theme';
	}
	switch (theme) {
		case 'light-theme': return "#ffe694";
		case 'ecru-theme': return "#A7CAB1";
		case 'water-theme': return "#7fd1ae";
		case 'gray-theme': return "#3c8b80";
		case 'dark-theme': return "#395a4f";
		case 'black-theme': return "#254d4c";
		default: return "#ffe694";
	}
}
""";

String addNodeHighlight({required String id, bool isCueToElement = true}) => """
$_nodeHighlightColor
var spans = document.querySelectorAll('span.$classPrefix-$id');

spans.forEach(span => {
  span.style.backgroundColor = _getNodeHighlightColor();
});
${isCueToElement ? _cueToElement(id) : ""}
""";

String removeNodeHighlight(String id) => """
var spans = document.querySelectorAll('span.$classPrefix-$id');

spans.forEach(span => {
  span.style.backgroundColor = 'initial';
});
""";

String removeAllHighlights() => """
var spans = document.querySelectorAll('span[class^="$classPrefix"]');

spans.forEach(span => {
  span.style.backgroundColor = 'initial';
});
""";

String _cueToElement(String id) => """
	document.dispatchEvent(
			new CustomEvent('ttu-action', {
				detail: {
					type: 'cue',
					scrollMode: 'Page',
					scrollBehavior: 'instant',
					selector:  'span.$classPrefix-$id'
				},
			}),
		);
""";

String updateIsEnableSwipeInReader(bool isEnableSwipe) => """
	document.dispatchEvent(
			new CustomEvent('ttu-action', {
				detail: {
					type: '${isEnableSwipe ? 'enableSwipe' : 'disableSwipe'}',
				},
			}),
		);
""";

String dispatchReloadEvent = """
	document.dispatchEvent(
			new CustomEvent('ttu-action', {
				detail: {
					type: 'reload',
				},
			}),
		);
""";
