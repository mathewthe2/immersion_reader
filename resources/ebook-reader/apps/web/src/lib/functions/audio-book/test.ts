import srtParser2 from 'srt-parser-2';
import { between, calculatePercentage, getBaseLineCSSSelectorForId, getSubtitleIdFromElement, throwIfAborted, toTimeStamp } from '$lib/util';

export const test = async ({ htmlContent, startHintNodeContent, startHintParentId }: {
    htmlContent: string,
    startHintNodeContent: string | undefined,
    startHintParentId: string | undefined
}) => {
    // const fileContent = '1\n00:00:11,544 --> 00:00:12,682\nHello';
    const fileContent = '11\n00:00:29,640 --> 00:00:32,916\n戦場ヶ原ひたぎは、クラスにおいて、\n12\n00:00:32,916 --> 00:00:36,692\nいわゆる病弱な女の子という立ち位置を与えられている──';

    const subtitles = await updateSubtitles({ fileContent: fileContent, htmlContent: htmlContent, startHintNodeContent: startHintNodeContent, startHintParentId: startHintParentId });
    // console.log(htmlContent);
    console.log(subtitles);
};

interface DiffDetail {
    id: string;
    original: string;
    adjusted: string;
}

interface Subtitle {
    id: string;
    originalStartSeconds: number;
    adjustedStartSeconds?: number;
    startSeconds: number;
    startTime: string;
    originalEndSeconds: number;
    adjustedEndSeconds?: number;
    endSeconds: number;
    endTime: string;
    originalText: string;
    text: string;
    subIndex: number;
}

async function updateSubtitles({ fileContent, htmlContent, startHintNodeContent, startHintParentId }:
    {
        fileContent: string,
        htmlContent: string,
        startHintNodeContent: string | undefined,
        startHintParentId: string | undefined
    }) {
    const subtitles = new Map();

    console.log("startHintParentId", startHintParentId);

    let subUrl = '';

    try {
        // paused$.set(true);

        const subtitlesGlobalStartPadding = 0 / 1000;
        const subtitlesGlobalEndPadding = 0 / 1000;
        const duration = 0;

        const parser = new srtParser2();
        // const fileContent = await readFile(file);
        const parsingResults = [...parser.fromSrt(fileContent)];

        for (let index = 0, { length } = parsingResults; index < length; index += 1) {
            const parsingResult = parsingResults[index];
            const startSeconds = Math.max(0, parsingResult.startSeconds + subtitlesGlobalStartPadding);
            const endSeconds = duration
                ? between(0, duration, parsingResult.endSeconds + subtitlesGlobalEndPadding)
                : Math.max(0, parsingResult.endSeconds + subtitlesGlobalEndPadding);
            const text = parsingResult.text.trim();

            subtitles.set(parsingResult.id, {
                id: parsingResult.id,
                originalStartSeconds: parsingResult.startSeconds,
                startSeconds,
                startTime: toTimeStamp(startSeconds),
                originalEndSeconds: parsingResult.endSeconds,
                endSeconds,
                endTime: toTimeStamp(endSeconds),
                originalText: text,
                text,
                subIndex: index
            });
        }

        // if (updateContext) {
        //   setSubtitleContext(file, subtitles);
        // }

        const subtitleList: Subtitle[] = Array.from(subtitles.values());
        onMatchSubtitles({ elementHtml: htmlContent, subtitles: subtitleList, startHintNodeContent: startHintNodeContent, startHintParentId: startHintParentId });



        return subtitles;
    } finally {
        URL.revokeObjectURL(subUrl);
    }
}

const matchLineSimilarityThreshold = 0.9;
const matchLineMaxAttempts = 10;
const normalizeRegex = /[\p{punct}\s]/u;
const allIgnoredElements = new Set(['rp', 'rt']);
const singleIgnoredElements = new Set(['rt']);
const matchLineIgnoreRp = true;
const ignoredTags = matchLineIgnoreRp ? allIgnoredElements : singleIgnoredElements;
const ignoredTagsSelector = [...ignoredTags].join(',');
let cancelToken = new AbortController();
let cancelSignal = cancelToken.signal;
const hasHint = true;

async function onMatchSubtitles({ subtitles = [], elementHtml = '', startHintNodeContent = '', startHintParentId = '' }:
    { subtitles: Subtitle[], elementHtml: string, startHintNodeContent: string | undefined, startHintParentId: string | undefined }) {

    // console.log(elementHtml.substring(0, 500));

    let unmatchedSubtitles: Subtitle[] = [];
    let currentProgress = 0;
    let maxProgress = 0;
    let lineMatchRate = 'n/a';
    let bookSubtitleDiffRate = 'n/a';
    let subtitleDiffDetails = [];
    let lastError = '';

    // const startHintNodeContent = '';
    // const startHintParentId = '';


    const textNodes: Node[] = [];
    const maxMatchAttempts = Math.min(subtitles.length, matchLineMaxAttempts);
    const originalElementsMap = new Map<HTMLElement, string>();
    const matchedElementsMap = new Map<HTMLElement, string>();
    const allIgnoredSelector = [...allIgnoredElements].join(',');

    console.log("startHintParentId", startHintParentId);


    let currentNodes: Node[] = [];
    let currentText = '';
    let textInScope = '';
    let currentSubtitleIndex = 0;
    let passedStartNode = hasHint ? false : true;
    let { currentSubtitle, currentSubtitleLength } = getSubtitleData(subtitles, currentSubtitleIndex);

    try {
        const htmlBackup = elementHtml;
        let bookHTML = parseHTML(new DOMParser(), elementHtml);

        const bookTextWalker = document.createTreeWalker(bookHTML, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (hasHint && !passedStartNode) {
                    passedStartNode =
                        startHintNodeContent === node.textContent && getTTUParent(node)?.id === startHintParentId;

                    if (passedStartNode) {
                        node.parentElement!.dataset.ttuWhispersyncStartNode = '';
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

        while (bookTextWalker.nextNode()) { }

        let matchedSubtitles = 0;
        let matchAttempt = 1;
        let currentTextNodeIndex = 0;
        let textNodeIndexAfterLastMatch = 0;
        let textNodeCount = textNodes.length;

        while (currentTextNodeIndex < textNodeCount && currentSubtitleIndex < subtitles.length) {
            throwIfAborted(cancelSignal);

            const newProgress = calculatePercentage(currentSubtitleIndex + 1, maxProgress);

            let node = textNodes[currentTextNodeIndex];
            let nodeParent = node.parentElement!;

            if (newProgress !== currentProgress) {
                currentProgress = newProgress;

                await new Promise((resolve) => setTimeout(resolve));
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
                nodeParent = node.parentElement!;

                currentTextNodeIndex += 1;

                while (nodeParent.closest(ignoredTagsSelector) && currentTextNodeIndex < textNodeCount) {
                    node = textNodes[currentTextNodeIndex];
                    nodeParent = node.parentElement!;

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

                        nodeToProcess.parentElement!.replaceChild(ignoredTextNode, nodeToProcess);
                        ignoredTextNode.after(remainingTextNode);

                        currentNodes[0] = remainingTextNode;
                    }

                    for (let index = 0, { length } = currentNodes; index < length; index += 1) {
                        const nodeToProcess = currentNodes[index];
                        const nodeToProcessParentElement = nodeToProcess.parentElement!;
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
                            console.log("matchedContainer", matchedContainer);
                        }

                        charactersProcessed += isIgnoredParent ? 0 : matchedTextLength;
                        charactersToProcess =
                            bestLineSimiliarityEndIndex - bestLineSimiliarityStartIndex - charactersProcessed;

                        if (!charactersToProcess && remainingCharacters) {
                            const leftOverTextNodes: Text[] = [];

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

                    // updateSubtitlesForDownload(subtitles[currentSubtitleIndex], textInScope);

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
                        ({ currentSubtitle, currentSubtitleLength } = getSubtitleData(
                            subtitles,
                            currentSubtitleIndex,
                        ));
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

                        // updateSubtitlesForDownload(subtitles[currentSubtitleIndex], textInScope);

                        matchAttempt = 1;
                        currentSubtitleIndex += 1;

                        if (currentSubtitleIndex < subtitles.length) {
                            currentTextNodeIndex = textNodeIndexAfterLastMatch;

                            ({ currentSubtitle, currentSubtitleLength } = getSubtitleData(
                                subtitles,
                                currentSubtitleIndex,
                            ));
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

        console.log("originalElementsMap", originalElementsMap.entries())
        console.log("matchedBookTextEntries", matchedBookTextEntries)

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

        // if (
        // 	subtitlesForDownload.length &&
        // 	subtitlesForDownload[subtitlesForDownload.length - 1].id !== lastSubtitle.id
        // ) {
        // 	updateSubtitlesForDownload(lastSubtitle, textInScope);
        // }

        lineMatchRate = `${matchedSubtitles} / ${subtitles.length
            } (${calculatePercentage(matchedSubtitles, subtitles.length, false)}%)`;

        bookSubtitleDiffRate = `${subtitleDiffDetails.length} / ${matchedSubtitles} (${calculatePercentage(
            subtitleDiffDetails.length,
            matchedSubtitles,
            false,
        )}%)`;

        if (bookHTML.firstElementChild instanceof HTMLElement) {
            // bookHTML.firstElementChild.dataset.ttuWhispersyncMatchedBy = currentSubtitleFile!.name;
            bookHTML.firstElementChild.dataset.ttuWhispersyncMatchedOn = `${Date.now()}`;
            bookHTML.firstElementChild.dataset.ttuWhispersyncMatchedSource = 'default';
        }

        onSaveMatch({ htmlBackup, bookHTML });
    } catch (error: any) {
        lineMatchRate = 'n/a';
        bookSubtitleDiffRate = 'n/a';
        // bookHTML = undefined;
        // subtitlesForDownload = [];
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
    // isLoading = false;


}

async function onSaveMatch({ htmlBackup, bookHTML }: { htmlBackup: string, bookHTML: HTMLElement }) {
    // $isLoading$ = true;

    try {
        const newData = {
            // ...$bookData$,
            htmlBackup: htmlBackup,
            elementHtml: bookHTML!.innerHTML,
            lastBookModified: Date.now(),
        };

        // send the data back to flutter app

        console.log(newData);

        // await $booksDB$.put('data', newData);
        // window.location.reload();
    } catch ({ message }: any) {
        console.error(`Failed to save data: ${message}`);
        // $isLoading$ = false;
    }
}

function getSubtitleData(subtitles: Subtitle[], index: number) {
    console.log("subtitles", subtitles);
    const currentSubtitle = subtitles[index].text;
    const currentSubtitleLength = [...currentSubtitle].length;

    return { currentSubtitle, currentSubtitleLength };
}

function getTTUParent(node: Node) {
    return node.parentElement!.closest('div[id^="ttu-"]');
}

function normalizeString(value: string | null, toLowerCase = false) {
    const cleanValue = (value || '').replace(/\s/g, '').trim();
    return toLowerCase ? cleanValue.toLowerCase() : cleanValue;
}

function parseHTML(domParser: DOMParser, hmtl: string) {
    let { body } = domParser.parseFromString(hmtl, 'text/html');

    if (!body.childNodes.length) {
        ({ body } = domParser.parseFromString(hmtl, 'text/xml'));
    }

    if (!body.childNodes.length) {
        throw new Error(`Failed to parse html`);
    }

    return body;
}

function addNodeContentToMap(map: Map<HTMLElement, string>, node: Node, textContent: string) {
    const parent =
        node.parentElement instanceof HTMLSpanElement &&
            getSubtitleIdFromElement(node.parentElement) !== 'not existing'
            ? node.parentElement.parentElement!
            : node.parentElement!;

    map.set(parent, `${map.get(parent) || ''}${textContent}`);
}

function getNormalizedLength(value: string) {
    return [...normalizeString(value)].length;
}

function getTextForComparison(currentText: string, targetLength: number) {
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

        if (trimmedCharacter && !normalizeRegex.test(trimmedCharacter)) {
            textForComparisonLength += 1;
        }

        if (textForComparisonLength === targetLength) {
            break;
        }
    }

    return textForComparison;
}

function findBestSimilarity(
    currentSubtitle: string,
    currentSubtitleLength: number,
    textForComparison: string,
    textForComparisonLength: number,
    currentBestStartIndex: number,
    currentBestValue: number,
    currentNodes: Node[],
    textNodes: Node[],
    currentTextNodeIndex: number,
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
            const nodeToCheck = currentNodes.shift()!;
            const nodeToCheckParent = nodeToCheck.parentElement!;

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
        let nodeToCheckParent = nodeToCheck.parentElement!;
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
        const nodeToCheckParent = nodeToCheck.parentElement!;

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

function getSimilarity(str1: string, str2: string) {
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

function throwMatchError(
    error: string,
    originalElement: HTMLElement,
    matchedElement: HTMLElement,
    ttuParent: Element | null,
) {
    console.log(error, originalElement, matchedElement, ttuParent);

    throw new Error(error);
}