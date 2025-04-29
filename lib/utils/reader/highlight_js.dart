const String classPrefix = "ttu-whispersync-line-highlight";

String addNodeHighlight(String id) => """
var spans = document.querySelectorAll('span.$classPrefix-$id');

spans.forEach(span => {
  span.style.backgroundColor = 'yellow';
});
${_cueToElement(id)}
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
