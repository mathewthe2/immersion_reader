import 'dart:convert';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitle.dart';

const _getAllTextNodes = """
function getAllTextNodes() {
  const walker = document.createTreeWalker(
    document.body,
    NodeFilter.SHOW_TEXT,
    {
      acceptNode: function(node) {
        // Optionally ignore whitespace-only nodes:
        return node.textContent.trim() ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP;
      }
    },
    false
  );

  const textNodes = [];
  let node;
  while (node = walker.nextNode()) {
    textNodes.push(node);
  }
  return textNodes;
}
""";

const getTextNodes =
    """
  $_getAllTextNodes
  getAllTextNodes().map((node)=>node.textContent)
""";

const _getTTUParent = """
  function getTTUParent(node) {
      return node.parentElement.closest('div[id^="ttu-"]');
  }
""";

const _onMatchSubtitles = r"""
function calculatePercentage(x, y, roundDown = true) {
    if (!x || !y) {
        return 0;
    }

    if (roundDown) {
        return Math.floor((x / y) * 100);
    }

    return Math.round(((x / y) * 100 + Number.EPSILON) * 100) / 100;
}

var baseLineCSSClass = `ttu-whispersync-line-highlight-`;
var matchLineSimilarityThreshold = 0.9;
var matchLineMaxAttempts = 10;
var allIgnoredElements = new Set(['rp', 'rt']);
var singleIgnoredElements = new Set(['rt']);
var matchLineIgnoreRp = true;
var ignoredTags = matchLineIgnoreRp ? allIgnoredElements : singleIgnoredElements;
var ignoredTagsSelector = [...ignoredTags].join(',');

  function getTTUParent(node) {
      return node.parentElement.closest('div[id^="ttu-"]');
  }

function getBaseLineCSSSelectorForId(id) {
    return `${baseLineCSSClass}${id}`;
}

function throwIfAborted(cancelSignal) {
    if (!cancelSignal) {
        return;
    }

    if (typeof cancelSignal.throwIfAborted === 'function') {
        cancelSignal.throwIfAborted();
    } else if (cancelSignal.aborted) {
        throw new AbortError('user aborted');
    }
}

function throwMatchError(
    error,
    originalElement,
    matchedElement,
    ttuParent,
) {
    console.log(error, originalElement, matchedElement, ttuParent);

    throw new Error(error);
}

function parseHTML(domParser, hmtl) {
    let { body } = domParser.parseFromString(hmtl, 'text/html');

    if (!body.childNodes.length) {
        ({ body } = domParser.parseFromString(hmtl, 'text/xml'));
    }

    if (!body.childNodes.length) {
        throw new Error(`Failed to parse html`);
    }

    return body;
}

function normalizeString(value, toLowerCase) {
    const cleanValue = (value || '').replace(/\s/g, '').trim();
    return toLowerCase ? cleanValue.toLowerCase() : cleanValue;
}

function getNormalizedLength(value) {
    return [...normalizeString(value)].length;
}

function isPunctuationOrWhitespace(char) {
  const whitespaceChars = [' ', '\t', '\n', '\r', '\v', '\f'];
  const punctuationChars = [
    '!', '"', '#', '$', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/',
    ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', '`', '{', '|', '}', '~'
  ];

  return whitespaceChars.includes(char) || punctuationChars.includes(char);
}

function getTextForComparison(currentText, targetLength) {
    const characters = [...currentText];

    if (characters.length === targetLength) {
        return currentText;
    }

    let textForComparison = '';
    let textForComparisonLength = 0;

    for (let index = 0, { length } = characters; index < length; index += 1) {
        let character = characters[index];

        textForComparison += character;

        const trimmedCharacter = character.trim();

        if (trimmedCharacter && !isPunctuationOrWhitespace(trimmedCharacter)) {
            textForComparisonLength += 1;
        }

        if (textForComparisonLength === targetLength) {
            break;
        }
    }

    return textForComparison;
}

function getSubtitleIdFromElement(element) {
    return (
        [...element.classList]
            .find((cssClass) => cssClass.startsWith(baseLineCSSClass))
            ?.replace(baseLineCSSClass, '') || 'not existing'
    );
}

function addNodeContentToMap(map, node, textContent) {
    const parent =
        node.parentElement instanceof HTMLSpanElement &&
            getSubtitleIdFromElement(node.parentElement) !== 'not existing'
            ? node.parentElement.parentElement
            : node.parentElement;

    map.set(parent, `${map.get(parent) || ''}${textContent}`);
}

function getSimilarity(str1, str2) {
    const string1 = normalizeString(str1, true);
    const string2 = normalizeString(str2, true);
    const string1Length = [...string1].length;
    const string2Length = [...string2].length;
    const substringLength = string1Length < 5 ? 1 : 2;

    if (string1 === string2) {
        return 1;
    }

    if (string1Length < substringLength || string2Length < substringLength) {
        return 0;
    }

    const map = new Map();

    for (let i = 0; i < string1Length - (substringLength - 1); i += 1) {
        const substring1 = [...string1].slice(i, i + substringLength).join('');

        map.set(substring1, map.has(substring1) ? map.get(substring1) + 1 : 1);
    }

    let match = 0;

    for (let j = 0; j < string2Length - (substringLength - 1); j++) {
        const substring2 = [...string2].slice(j, j + substringLength).join('');
        const count = map.has(substring2) ? map.get(substring2) : 0;

        if (count > 0) {
            map.set(substring2, count - 1);

            match += 1;
        }
    }

    return (match * 2) / (string1Length + string2Length - (substringLength - 1) * 2);
}

function findBestSimilarity(
    currentSubtitle,
    currentSubtitleLength,
    textForComparison,
    textForComparisonLength,
    currentBestStartIndex,
    currentBestValue,
    currentNodes,
    textNodes,
    currentTextNodeIndex,
) {
    let bestLineSimiliarityStartIndex = currentBestStartIndex;
    let bestLineSimiliarityEndIndex = textForComparisonLength;
    let bestLineSimiliarityValue = currentBestValue;


    if (bestLineSimiliarityValue !== 1) {
        for (let index = bestLineSimiliarityEndIndex; index > currentBestStartIndex; index -= 1) {
            if (
                normalizeString(currentSubtitle) ===
                normalizeString([...textForComparison].slice(currentBestStartIndex, index).join(''))
            ) {
                bestLineSimiliarityStartIndex = currentBestStartIndex;
                bestLineSimiliarityEndIndex = index;
                bestLineSimiliarityValue = 1;
                break;
            }
        }
    }

    if (bestLineSimiliarityValue !== 1) {
        for (let index = currentBestStartIndex; index < bestLineSimiliarityEndIndex; index += 1) {
            const lineSimiliarityToCompare = getSimilarity(
                currentSubtitle,
                [...textForComparison].slice(index, bestLineSimiliarityEndIndex).join(''),
            );

            if (lineSimiliarityToCompare > bestLineSimiliarityValue) {
                bestLineSimiliarityStartIndex = index;
                bestLineSimiliarityEndIndex = textForComparisonLength;
                bestLineSimiliarityValue = lineSimiliarityToCompare;
            }
        }
    }


    if (
        currentBestStartIndex === bestLineSimiliarityStartIndex ||
        bestLineSimiliarityValue === 1 ||
        bestLineSimiliarityValue < matchLineSimilarityThreshold
    ) {
        if (bestLineSimiliarityValue !== 1) {
            bestLineSimiliarityValue = -1;

            for (let index = bestLineSimiliarityEndIndex; index > currentBestStartIndex; index -= 1) {
                const lineSimiliarityToCompare = getSimilarity(
                    currentSubtitle,
                    [...textForComparison].slice(currentBestStartIndex, index).join(''),
                );

                if (lineSimiliarityToCompare > bestLineSimiliarityValue) {
                    bestLineSimiliarityStartIndex = currentBestStartIndex;
                    bestLineSimiliarityEndIndex = index;
                    bestLineSimiliarityValue = lineSimiliarityToCompare;
                }
            }
        }


        if (bestLineSimiliarityValue < matchLineSimilarityThreshold || bestLineSimiliarityValue === 1) {
            return {
                bestLineSimiliarityStartIndex,
                bestLineSimiliarityEndIndex,
                bestLineSimiliarityValue,
                currentNodes,
                currentTextNodeIndex,
            };
        }

        const finalNodes = [];
        const originalLength = currentNodes.length;
        const targetCharacterLength = bestLineSimiliarityEndIndex - bestLineSimiliarityStartIndex;

        let characterCount = 0;

        while (characterCount < targetCharacterLength && currentNodes.length) {
            const nodeToCheck = currentNodes.shift();
            const nodeToCheckParent = nodeToCheck.parentElement;
            
            characterCount += nodeToCheckParent.closest(ignoredTagsSelector)
                ? 0
                : [...(nodeToCheck.textContent || '')].length;

            finalNodes.push(nodeToCheck);
        }

        return {
            bestLineSimiliarityStartIndex,
            bestLineSimiliarityEndIndex,
            bestLineSimiliarityValue,
            currentNodes: finalNodes,
            currentTextNodeIndex: currentTextNodeIndex - (originalLength - finalNodes.length),
        };
    }

    let sliceIndex = 0;
    let charactersSeen = 0;
    let startOffset = bestLineSimiliarityStartIndex;

    for (let index = 0, { length } = currentNodes; index < length; index += 1) {
        let nodeToCheck = currentNodes[index];
        let nodeToCheckParent = nodeToCheck.parentElement;
        let nodeToCheckLength = nodeToCheckParent.closest(ignoredTagsSelector)
            ? 0
            : [...(nodeToCheck.textContent || '')].length;

        const offsetDiff = startOffset - nodeToCheckLength;

        charactersSeen += nodeToCheckLength;
        startOffset = offsetDiff < 0 ? startOffset : offsetDiff;

        if (charactersSeen >= bestLineSimiliarityStartIndex) {
            sliceIndex = index + (charactersSeen === bestLineSimiliarityStartIndex ? 1 : 0);
            break;
        }
    }

    const newNodes = [];

    let currentText = '';
    let currentNormalizedTextLength = 0;
    let newTextNodeIndex = currentTextNodeIndex - (currentNodes.length - (sliceIndex + 1));

    while (currentNormalizedTextLength <= currentSubtitleLength && newTextNodeIndex < textNodes.length) {
        const nodeToCheck = textNodes[newTextNodeIndex];
        const nodeToCheckParent = nodeToCheck.parentElement;

        if (!nodeToCheckParent.closest(ignoredTagsSelector)) {
            currentText += nodeToCheck.textContent;
        }

        newNodes.push(nodeToCheck);

        newTextNodeIndex += 1;
        currentNormalizedTextLength = getNormalizedLength(currentText);
    }

    newTextNodeIndex = newTextNodeIndex - 1;

    currentText = getTextForComparison(currentText, currentSubtitleLength);

    return findBestSimilarity(
        currentSubtitle,
        currentSubtitleLength,
        currentText,
        [...currentText].length,
        startOffset,
        bestLineSimiliarityValue,
        newNodes,
        textNodes,
        newTextNodeIndex,
    );
}

function onMatchSubtitles({ subtitles = [], elementHtml = '', startHintNodeContent = '', startHintParentId = '' }) {

    var cancelToken = new AbortController();
    var cancelSignal = cancelToken.signal;
    var hasHint = true;

    let unmatchedSubtitles = [];
    let currentProgress = 0;
    let maxProgress = subtitles.length;
    let lineMatchRate = 'n/a';
    let bookSubtitleDiffRate = 'n/a';
    let matchedSubtitlesResult = 0;
    let subtitleDiffDetails = [];
    // let lastError = '';

    const textNodes = [];
    const maxMatchAttempts = Math.min(subtitles.length, matchLineMaxAttempts);
    const originalElementsMap = new Map();
    const matchedElementsMap = new Map();
    const allIgnoredSelector = [...allIgnoredElements].join(',');
    

    let currentNodes = [];
    let currentText = '';
    let textInScope = '';
    let currentSubtitleIndex = 0;
    let passedStartNode = hasHint ? false : true;

    // let { currentSubtitle, currentSubtitleLength } = getSubtitleData(subtitles, currentSubtitleIndex);

    var currentSubtitle = subtitles[0].text
    var currentSubtitleLength = subtitles[0].text.length;

    try {
        const htmlBackup = elementHtml;
        let bookHTML = parseHTML(new DOMParser(), elementHtml);

        const bookTextWalker = document.createTreeWalker(bookHTML, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (hasHint && !passedStartNode) {
                    passedStartNode =
                        startHintNodeContent === node.textContent && getTTUParent(node)?.id === startHintParentId;

                    if (passedStartNode) {
                        // console.log("parentElement", node.parentElement.textContent);
                        node.parentElement.dataset.ttuWhispersyncStartNode = '';
                    }
                }

                if (passedStartNode) {
                    const textContent = normalizeString(node.textContent);
                    addNodeContentToMap(originalElementsMap, node, textContent);

                    if (textContent) {
                        textNodes.push(node);
                    }
                }

                return NodeFilter.FILTER_ACCEPT;
            },
        });

        while (bookTextWalker.nextNode()) {}

        let matchedSubtitles = 0;
        let matchAttempt = 1;
        let currentTextNodeIndex = 0;
        let textNodeIndexAfterLastMatch = 0;
        let textNodeCount = textNodes.length;

        while (currentTextNodeIndex < textNodeCount && currentSubtitleIndex < subtitles.length) {
            throwIfAborted(cancelSignal);

            const newProgress = calculatePercentage(currentSubtitleIndex + 1, maxProgress);

            if (window.flutter_inappwebview != null) {
              window.flutter_inappwebview.callHandler('sendMatchSubtitleProgress', newProgress);
            }

            let node = textNodes[currentTextNodeIndex];
            let nodeParent = node.parentElement;

            if (newProgress !== currentProgress) {
                currentProgress = newProgress;
                // await new Promise((resolve) => setTimeout(resolve));
            }

            if (!nodeParent.closest(ignoredTagsSelector)) {
                currentText += node.textContent;
            }

  
            const currentNormalizedTextLength = getNormalizedLength(currentText);

            if (currentNormalizedTextLength >= currentSubtitleLength) {

                const textForComparison = getTextForComparison(currentText, currentSubtitleLength);
                const textForComparisonLength = [...textForComparison].length;


                let bestLineSimiliarityStartIndex = 0;
                let bestLineSimiliarityEndIndex = textForComparisonLength;
                let bestLineSimiliarityValue = getSimilarity(textForComparison, currentSubtitle);

                currentNodes.push(node);

                const similiarityResult = findBestSimilarity(
                    currentSubtitle,
                    currentSubtitleLength,
                    textForComparison,
                    textForComparisonLength,
                    bestLineSimiliarityStartIndex,
                    bestLineSimiliarityValue,
                    currentNodes,
                    textNodes,
                    currentTextNodeIndex,
                );

                                   

                const isThresholdMet = similiarityResult.bestLineSimiliarityValue >= matchLineSimilarityThreshold;

                if (isThresholdMet) {
                    ({
                        bestLineSimiliarityStartIndex,
                        bestLineSimiliarityEndIndex,
                        currentNodes,
                        currentTextNodeIndex,
                    } = similiarityResult);
                }

                node = textNodes[currentTextNodeIndex];
                nodeParent = node.parentElement;

                currentTextNodeIndex += 1;

                while (nodeParent.closest(ignoredTagsSelector) && currentTextNodeIndex < textNodeCount) {
                    node = textNodes[currentTextNodeIndex];
                    nodeParent = node.parentElement;

                    if (nodeParent.closest(ignoredTagsSelector)) {
                        currentNodes.push(node);
                    }

                    currentTextNodeIndex += 1;
                }

                currentTextNodeIndex -= 1;

                if (isThresholdMet) {
                    let charactersToProcess = bestLineSimiliarityEndIndex - bestLineSimiliarityStartIndex;
                    let charactersProcessed = 0;
                    let hadRemainingCharacters = false;

                    if (bestLineSimiliarityStartIndex !== 0) {
                        const nodeToProcess = currentNodes[0];
                        const nodeToProcessTextContent = nodeToProcess.textContent || '';
                        const ignoredTextNode = document.createTextNode(
                            [...nodeToProcessTextContent].slice(0, bestLineSimiliarityStartIndex).join(''),
                        );
                        const remainingTextNode = document.createTextNode(
                            [...nodeToProcessTextContent].slice(bestLineSimiliarityStartIndex).join(''),
                        );

                        nodeToProcess.parentElement.replaceChild(ignoredTextNode, nodeToProcess);
                        ignoredTextNode.after(remainingTextNode);

                        currentNodes[0] = remainingTextNode;
                    }

                    for (let index = 0, { length } = currentNodes; index < length; index += 1) {
                        const nodeToProcess = currentNodes[index];
                        const nodeToProcessParentElement = nodeToProcess.parentElement;
                        const nodeToProcessTextContent = nodeToProcess.textContent || '';
                        const nodeTextContentLength = [...nodeToProcessTextContent].length;
                        const isIgnoredParent = !!nodeToProcessParentElement.closest(ignoredTagsSelector);
                        const matchedContainer = document.createElement('span');
                        const matchedText = isIgnoredParent
                            ? [...nodeToProcessTextContent].slice(0).join('')
                            : [...nodeToProcessTextContent].slice(0, charactersToProcess).join('');
                        const matchedTextNode = document.createTextNode(matchedText);
                        const matchedTextLength = [...matchedText].length;
                        const remainingCharacters = nodeTextContentLength - matchedTextLength;

                        if (charactersToProcess) {
                            const subtitle = subtitles[currentSubtitleIndex];

                            matchedContainer.classList.add(getBaseLineCSSSelectorForId(subtitle.id));

                            matchedContainer.appendChild(matchedTextNode);
                            nodeToProcessParentElement.replaceChild(matchedContainer, nodeToProcess);

                            if (!nodeToProcessParentElement.closest(allIgnoredSelector)) {
                                textInScope += matchedText;
                            }
                            // console.log("matchedContainer", matchedContainer.textContent);
                        }

                             

                        charactersProcessed += isIgnoredParent ? 0 : matchedTextLength;
                        charactersToProcess =
                            bestLineSimiliarityEndIndex - bestLineSimiliarityStartIndex - charactersProcessed;


                        if (!charactersToProcess && remainingCharacters) {
                            const leftOverTextNodes = [];

                            index += matchedTextLength ? 0 : 1;

                            let leftOverLength = matchedTextLength;

    
                            while (index < length) {
                                const leftOverNode = currentNodes[index];
                                const leftOverNodeContent = leftOverNode.textContent || '';
                                const remainingTextNode = document.createTextNode(
                                    [...leftOverNodeContent].slice(leftOverLength).join(''),
                                );

                                if (!leftOverNodeContent) {
                                    throw new Error('charactersToProcess without remaining text found');
                                }

                                if (!leftOverNode.parentElement) {
                                    matchedContainer.after(remainingTextNode);
                                    leftOverTextNodes.push(remainingTextNode);
                                }

                                index += 1;
                                leftOverLength = 0;
                            }
              

                            if (leftOverTextNodes.length) {
                                textNodes.splice(
                                    currentTextNodeIndex,
                                    leftOverTextNodes.length,
                                    ...leftOverTextNodes,
                                );
                            }


                            hadRemainingCharacters = true;
                        }

                    }

                    currentText = '';
                    textInScope = '';


                    if (!hadRemainingCharacters) {
                        currentTextNodeIndex += 1;
                    }


                    textNodeIndexAfterLastMatch = currentTextNodeIndex;
                    currentSubtitleIndex += 1;
                    matchedSubtitles += 1;
                    matchAttempt = 1;

                    if (currentSubtitleIndex < subtitles.length) {
                        currentSubtitle = subtitles[currentSubtitleIndex].text;
                        currentSubtitleLength = currentSubtitle.length;
                    }



                } else {
                    currentTextNodeIndex = textNodeIndexAfterLastMatch + matchAttempt;
                    matchAttempt += 1;
                    currentText = '';
                    textInScope = '';

                    const isEndReached = currentTextNodeIndex > textNodes.length;
                    const maxAttemptsReached = matchAttempt > maxMatchAttempts;

                    if (maxAttemptsReached || isEndReached) {
                        console.log(
                            maxAttemptsReached
                                ? `Max match attempts for ${currentSubtitle} (${subtitles[currentSubtitleIndex].id}) reached - reset`
                                : `End of Text before max attempt for ${currentSubtitle} (${subtitles[currentSubtitleIndex].id}) reached - reset`,
                        );

                        unmatchedSubtitles.push(subtitles[currentSubtitleIndex]);

                        matchAttempt = 1;
                        currentSubtitleIndex += 1;

                        if (currentSubtitleIndex < subtitles.length) {
                            currentTextNodeIndex = textNodeIndexAfterLastMatch;

                            currentSubtitle = subtitles[currentSubtitleIndex].text;
                            currentSubtitleLength = currentSubtitle.length;
                        } else {
                            currentTextNodeIndex = textNodeCount;
                        }
                    }
                }

                currentNodes = [];
            } else {
                currentNodes.push(node);
                currentTextNodeIndex += 1;
            }

            textNodeCount = textNodes.length;
        }

        passedStartNode = hasHint ? false : true;

        const matchedWlker = document.createTreeWalker(bookHTML, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (hasHint && !passedStartNode) {
                    passedStartNode = !!node.parentElement?.closest('*[data-ttu-whispersync-start-node]');
                }

                if (passedStartNode) {
                    addNodeContentToMap(matchedElementsMap, node, normalizeString(node.textContent));
                }

                return NodeFilter.FILTER_ACCEPT;
            },
        });

        while (matchedWlker.nextNode()) { }

        const bookTextEntries = [...originalElementsMap.entries()];
        const matchedBookTextEntries = [...matchedElementsMap.entries()];

        for (let index = 0, { length } = bookTextEntries; index < length; index += 1) {
            const [originalElement, originalContent] = bookTextEntries[index];
            const [matchedElement, matchedContent] = matchedBookTextEntries[index] || [];
            
            const ttuParent = getTTUParent(originalElement);

            if (originalElement !== matchedElement) {
                throwMatchError(`element mismatch on index ${index}`, originalElement, matchedElement, ttuParent);
            }


            const bookTextCharacters = [...originalContent];
            const matchedBookTextCharacters = [...matchedContent];

            for (let index2 = 0, { length: length2 } = bookTextCharacters; index2 < length2; index2 += 1) {
                const bookCharacter = bookTextCharacters[index2];
                const matchCharacter = matchedBookTextCharacters[index2];

                if (bookCharacter !== matchCharacter) {
                    throwMatchError(
                        `mismatch on index ${index}, position ${index2}: ${[...originalContent]
                            .slice(Math.max(0, index2 - 10), Math.min(bookTextCharacters.length, index2 + 10))
                            .join('')} | vs | ${[...matchedContent]
                                .slice(
                                    Math.max(0, index2 - 10),
                                    Math.min(matchedBookTextCharacters.length, index2 + 10),
                                )
                                .join('')}`,
                        originalElement,
                        matchedElement,
                        ttuParent,
                    );
                }
            }
        }

        const lastSubtitle = subtitles[subtitles.length - 1];

        if (currentText) {
            unmatchedSubtitles.push(lastSubtitle);

            console.log(
                `End of Text before max attempt for ${lastSubtitle.text} (${lastSubtitle.id}) reached - reset`,
            );
        }

        lineMatchRate = `${matchedSubtitles} / ${subtitles.length
            } (${calculatePercentage(matchedSubtitles, subtitles.length, false)}%)`;

        matchedSubtitlesResult = matchedSubtitles;

        bookSubtitleDiffRate = `${subtitleDiffDetails.length} / ${matchedSubtitles} (${calculatePercentage(
            subtitleDiffDetails.length,
            matchedSubtitles,
            false,
        )}%)`;

        if (bookHTML.firstElementChild instanceof HTMLElement) {
            bookHTML.firstElementChild.dataset.ttuWhispersyncMatchedOn = `${Date.now()}`;
            bookHTML.firstElementChild.dataset.ttuWhispersyncMatchedSource = 'default';
        }

        // onSaveMatch({ htmlBackup, bookHTML });
        return {
             "htmlBackup": htmlBackup,
            "elementHtml": bookHTML.innerHTML,
            "bookSubtitleDiffRate": bookSubtitleDiffRate,
            "lineMatchRate": lineMatchRate,
            "matchedSubtitles": matchedSubtitlesResult,
            "lastBookModified": Date.now(),
        }
    } catch (error) {
        lineMatchRate = 'n/a';
        bookSubtitleDiffRate = 'n/a';
        subtitleDiffDetails = [];
        unmatchedSubtitles = [];

        if (!cancelToken.signal.aborted && error.name !== 'AbortError') {
            lastError = `Failed to match: ${error.message}`;
        }
    }

    currentProgress = 0;
    maxProgress = 0;
    cancelToken = new AbortController();
    cancelSignal = cancelToken.signal;
}
""";

String startMatch({
  required int nodeIndex,
  required String elementHtml,
  required List<Subtitle> subtitles,
}) {
  var elementHtmlEncoded = Uri.encodeFull(elementHtml);
  final subtitlesJson = jsonEncode(subtitles.map((s) => s.toJson()).toList());

  return """
  $_getAllTextNodes
  $_getTTUParent
  $_onMatchSubtitles
  var startHintNodeContent = '';
  var startHintParentId = '';


  var elementHtml = decodeURI('$elementHtmlEncoded');
  var subtitles = $subtitlesJson;

  var textNode = getAllTextNodes()[$nodeIndex];

  var ttuParent = getTTUParent(textNode);


    if (ttuParent?.id != null) {
    startHintNodeContent = textNode.textContent;
    startHintParentId = ttuParent.id;
  }
    var p = await onMatchSubtitles({
      subtitles: subtitles,
      elementHtml: elementHtml,
      startHintNodeContent: startHintNodeContent,
      startHintParentId: startHintParentId,
    })
await p;
return p;
""";
}
