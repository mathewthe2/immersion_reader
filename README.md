# Immersion Reader

<h3><a href="https://apps.apple.com/us/app/immersion-reader/id6443721334">Download on App Store</h3>

<h3><a href="https://play.google.com/store/apps/details?id=com.immersionkit.immersion_reader">Download on Play Store (Android)</h3>

<p float="left">
  <img src="https://user-images.githubusercontent.com/13146030/201500224-030caf5f-927c-423e-ac54-d84150c7f3fe.jpg" width="240" />
  <img src="https://user-images.githubusercontent.com/13146030/201500252-0affc16e-b81a-407a-9697-42ce780a9068.jpg" width="240" /> 
  <img src="https://user-images.githubusercontent.com/13146030/201500259-08b1be79-1628-4053-ad4e-4c39dff2a881.jpg" width="240" />
</p>

- Epub reader with popup dictionary for iPhone/iPad
- Custom dictionaries
- Dictionary search
- Save and export words to [AnkiDojo](https://ankiweb.net/shared/info/433778282)

## Develop

1. Build e-reader

```
cd resources/ebook-reader/apps/web
pnpm install
pnpm build
cp -r build/ ../../../../assets/ttu-ebook-reader/
```

If install fails, use `pnpm install --frozen-lockfile`.

1. Run Flutter app

```
flutter pub get
flutter run
```

## Distribution

- bump version in pubspec.yaml
- update bundle identifier with unique name (per app)
- (open Xcode )
- flutter build ipa
- open [Apple Transport](https://apps.apple.com/us/app/transporter/id1450874784) on MacOS. Drag and drop the build/ios/ipa/*.ipa app bundle into the app.

## Acknowledgements

- [Kanjium](https://github.com/mifunetoshiro/kanjium)
- JMDict
- [Jidoujisho](https://github.com/lrorpilla/jidoujisho)
- [Yomichan](https://github.com/FooSoft/yomichan)
