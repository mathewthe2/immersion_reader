import { between, toTimeStamp } from '$lib/util';
import srtParser2 from 'srt-parser-2';

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

export async function updateSubtitles(file: File, document: Document, updateContext = false) {
    const subtitles = new Map<string, Subtitle>();

    let subUrl = '';

    try {
        // paused$.set(true);

        // configurable from stores
        var globalStartPadding = 0;
        var globalEndPadding = 0;
        var storeDuration = 0;

        const subtitlesGlobalStartPadding = globalStartPadding / 1000;
        const subtitlesGlobalEndPadding = globalEndPadding / 1000;
        const duration = storeDuration;

        if (file.name.endsWith('.srt') || file.name.endsWith('.txt')) {
            const parser = new srtParser2();

            // TODO: read file content as string
            const fileContent = '' // await readFile(file);


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
                    subIndex: index,
                });
            }
        } else if (file.name.endsWith('.vtt')) {
            subUrl = URL.createObjectURL(file);

            const cues = await getVTTCues(subUrl, document);

            for (let index = 0, { length } = cues; index < length; index += 1) {
                const cue = cues[index];
                const id = `${index + 1}`;
                const startSeconds = Math.max(0, cue.startTime + subtitlesGlobalStartPadding);
                const endSeconds = duration
                    ? between(0, duration, cue.endTime + subtitlesGlobalEndPadding)
                    : Math.max(0, cue.endTime + subtitlesGlobalEndPadding);
                const text = cue.text.trim();

                subtitles.set(id, {
                    id,
                    originalStartSeconds: cue.startTime,
                    startSeconds,
                    startTime: toTimeStamp(startSeconds),
                    originalEndSeconds: cue.endTime,
                    endSeconds,
                    endTime: toTimeStamp(endSeconds),
                    originalText: text,
                    text,
                    subIndex: index,
                });
            }
        } else {
            throw new Error('File needs to be .srt,.txt or .vtt');
        }

        // if (updateContext) {
        // 	setSubtitleContext(file, subtitles);
        // }

        return subtitles;
    } finally {
        URL.revokeObjectURL(subUrl);
    }
}

function getVTTCues(url: string, document: Document) {
    const audio = document.createElement('audio');
    const track = document.createElement('track');

    track.default = true;

    audio.append(track);

    return new Promise<VTTCue[]>((resolve, reject) => {
        track.addEventListener('load', () => resolve([...((audio.textTracks[0].cues || []) as VTTCue[])]));
        track.addEventListener('error', () => reject(new Error('Failed to load vtt track')));
        track.src = url;
    });
}