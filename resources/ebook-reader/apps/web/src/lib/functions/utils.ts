import { getCharacterCount } from "./get-character-count";

function externalTargetFilterFunction(element: HTMLElement) {
    return !element.closest('rt') && getCharacterCount(element) > 0;
}

export function getExternalTargetElement(
    source: Document | Element,
    selector: string,
    uselast = true
) {

    const elements = [...source.querySelectorAll<HTMLSpanElement>(selector)].filter(
        externalTargetFilterFunction
    );

    return uselast ? elements[elements.length - 1] : elements[0];
}