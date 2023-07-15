import 'package:immersion_reader/data/settings/browser/dark_reader_setting.dart';

class BrowserDarkReaderControl {
  static const String disableDarkMode = 'DarkReader.disable();';

  static const String _enableDarkModeCORS = '''
    DarkReader.setFetchMethod(url => {
      let headers = new Headers()
      headers.append('Access-Control-Allow-Origin', '*')

      return window.fetch(url, {
        headers,
        mode: 'no-cors',
      })
    })
  ''';

  static String enableDarkMode(DarkReaderSetting darkReaderSetting) {
    return '''
    $_enableDarkModeCORS
    DarkReader.enable({
        brightness: ${darkReaderSetting.brightness},
        contrast: ${darkReaderSetting.contrast},
        sepia: ${darkReaderSetting.sepia}
    });
    ''';
  }
}
