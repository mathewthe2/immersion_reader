const srtParser = r"""
// https://github.com/1c7/srt-parser-2
var srtParser2 = /** @class */ (function () {
    function Parser() {
        this.seperator = ",";
    }
    Parser.prototype.timestampToSeconds = function (srtTimestamp) {
        var _a = srtTimestamp.split(","), rest = _a[0], millisecondsString = _a[1];
        var milliseconds = parseInt(millisecondsString);
        var _b = rest.split(":").map(function (x) { return parseInt(x); }), hours = _b[0], minutes = _b[1], seconds = _b[2];
        var result = milliseconds * 0.001 + seconds + 60 * minutes + 3600 * hours;
        // fix odd JS roundings, e.g. timestamp '00:01:20,460' result is 80.46000000000001
        return Math.round(result * 1000) / 1000;
    };
    ;
    Parser.prototype.correctFormat = function (time) {
        // Fix the format if the format is wrong
        // 00:00:28.9670 Become 00:00:28,967
        // 00:00:28.967  Become 00:00:28,967
        // 00:00:28.96   Become 00:00:28,960
        // 00:00:28.9    Become 00:00:28,900
        // 00:00:28,96   Become 00:00:28,960
        // 00:00:28,9    Become 00:00:28,900
        // 00:00:28,0    Become 00:00:28,000
        // 00:00:28,01   Become 00:00:28,010
        // 0:00:10,500   Become 00:00:10,500
        var str = time.replace(".", ",");
        var hour = null;
        var minute = null;
        var second = null;
        var millisecond = null;
        // Handle millisecond
        var _a = str.split(","), front = _a[0], ms = _a[1];
        millisecond = this.fixed_str_digit(3, ms);
        // Handle hour
        var _b = front.split(":"), a_hour = _b[0], a_minute = _b[1], a_second = _b[2];
        hour = this.fixed_str_digit(2, a_hour, false);
        minute = this.fixed_str_digit(2, a_minute, false);
        second = this.fixed_str_digit(2, a_second, false);
        return "".concat(hour, ":").concat(minute, ":").concat(second, ",").concat(millisecond);
    };
    /*
    // make sure string is 'how_many_digit' long
    // if str is shorter than how_many_digit, pad with 0
    // if str is longer than how_many_digit, slice from the beginning
    // Example:
  
    Input: fixed_str_digit(3, '100')
    Output: 100
    Explain: unchanged, because "100" is 3 digit
  
    Input: fixed_str_digit(3, '50')
    Output: 500
    Explain: pad end with 0
  
    Input: fixed_str_digit(3, '50', false)
    Output: 050
    Explain: pad start with 0
  
    Input: fixed_str_digit(3, '7771')
    Output: 777
    Explain: slice from beginning
    */
    Parser.prototype.fixed_str_digit = function (how_many_digit, str, padEnd) {
        if (padEnd === void 0) { padEnd = true; }
        if (str.length == how_many_digit) {
            return str;
        }
        if (str.length > how_many_digit) {
            return str.slice(0, how_many_digit);
        }
        if (str.length < how_many_digit) {
            if (padEnd) {
                return str.padEnd(how_many_digit, "0");
            }
            else {
                return str.padStart(how_many_digit, "0");
            }
        }
    };
    Parser.prototype.tryComma = function (data) {
        data = data.replace(/\r/g, "");
        var regex = /(\d+)\n(\d{1,2}:\d{1,2}:\d{1,2},\d{1,3}) --> (\d{1,2}:\d{1,2}:\d{1,2},\d{1,3})/g;
        var data_array = data.split(regex);
        data_array.shift(); // remove first '' in array
        return data_array;
    };
    Parser.prototype.tryDot = function (data) {
        data = data.replace(/\r/g, "");
        var regex = /(\d+)\n(\d{1,2}:\d{1,2}:\d{1,2}\.\d{1,3}) --> (\d{1,2}:\d{1,2}:\d{1,2}\.\d{1,3})/g;
        var data_array = data.split(regex);
        data_array.shift(); // remove first '' in array
        this.seperator = ".";
        return data_array;
    };
    Parser.prototype.fromSrt = function (data) {
        var originalData = data;
        var data_array = this.tryComma(originalData);
        if (data_array.length == 0) {
            data_array = this.tryDot(originalData);
        }
        var items = [];
        for (var i = 0; i < data_array.length; i += 4) {
            var startTime = this.correctFormat(data_array[i + 1].trim());
            var endTime = this.correctFormat(data_array[i + 2].trim());
            var new_line = {
                id: data_array[i].trim(),
                startTime: startTime,
                startSeconds: this.timestampToSeconds(startTime),
                endTime: endTime,
                endSeconds: this.timestampToSeconds(endTime),
                text: data_array[i + 3].trim()
            };
            items.push(new_line);
        }
        return items;
    };
    Parser.prototype.toSrt = function (data) {
        var res = "";
        var end_of_line = "\r\n";
        for (var i = 0; i < data.length; i++) {
            var s = data[i];
            res += s.id + end_of_line;
            res += s.startTime + " --> " + s.endTime + end_of_line;
            res += s.text.replace("\n", end_of_line) + end_of_line + end_of_line;
        }
        return res;
    };
    return Parser;
}());
""";

String parseSubtitle(String subtitleString) {
  return """
$srtParser
var parser = new srtParser2();
parser.fromSrt("${subtitleString.replaceAll("\n", r"\n")}");
""";
}
