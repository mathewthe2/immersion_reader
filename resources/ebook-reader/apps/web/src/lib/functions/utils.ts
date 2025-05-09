import { getCharacterCount } from "./get-character-count";

function externalTargetFilterFunction(element: HTMLElement) {
    return !element.closest('rt') && getCharacterCount(element) > 0;
}

export function isMobile(window: Window) {
    const UA = window.navigator.userAgent;
    const userAgentRegex = /\b(BlackBerry|webOS|iPhone|IEMobile|Android|Windows Phone|iPad|iPod)\b/i;

    if (('maxTouchPoints' in window.navigator) as any) {
        return window.navigator.maxTouchPoints > 0;
    }

    if (('msMaxTouchPoints' in window.navigator) as any) {
        return window.navigator.msMaxTouchPoints > 0;
    }

    const mQ = window.matchMedia?.('(pointer:coarse)');
    if (mQ?.media === '(pointer: coarse)') {
        return !!mQ.matches;
    }

    if ('orientation' in window) {
        return true;
    }
    return userAgentRegex.test(UA);
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