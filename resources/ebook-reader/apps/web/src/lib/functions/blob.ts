export function convertBase64ToBlob(base64Image: string) {
    // Split into two parts
    const parts = base64Image.split(';base64,');

    // Hold the content type
    const imageType = parts[0].split(':')[1];

    // Decode Base64 string
    const decodedData = window.atob(parts[1]);

    // Create UNIT8ARRAY of size same as row data length
    const uInt8Array = new Uint8Array(decodedData.length);

    // Insert all character code into uInt8Array
    for (let i = 0; i < decodedData.length; ++i) {
        uInt8Array[i] = decodedData.charCodeAt(i);
    }

    // Return BLOB image after conversion
    return new Blob([uInt8Array], { type: imageType });
}

export function convertBase64ToBlobMap(blobMap: Record<string, string>) {
    const newMap: Record<string, Blob> = {};

    for (const [key, base64String] of Object.entries(blobMap)) {
        try {
            const blob = convertBase64ToBlob(base64String);
            newMap[key] = blob;
        } catch (error) {
            console.error(`Error converting Base64 string to Blob for key ${key}:`, error);
        }
    }

    return newMap;
}

export function blobToBase64(blob: Blob) {
    return new Promise((resolve, _) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.readAsDataURL(blob);
    });
}
