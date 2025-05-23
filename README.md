# Immersion Reader

<a href="https://apps.apple.com/us/app/immersion-reader/id6443721334"><img alt="Download on the App Store" src="https://github.com/user-attachments/assets/2a9f8719-942a-4b9b-9217-61ae4f676296" height="80"/></a><a href="https://play.google.com/store/apps/details?id=com.immersionkit.immersion_reader"><img alt="Get it on Playstore" src="https://github.com/user-attachments/assets/05932039-a91f-410e-b10a-b3085fda5947" height="80"/></a>

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

### iOS

- bump version in pubspec.yaml
- update bundle identifier with unique name (per app)
- (open Xcode )
- flutter build ipa
- open [Apple Transport](https://apps.apple.com/us/app/transporter/id1450874784) on MacOS. Drag and drop the build/ios/ipa/*.ipa app bundle into the app.

### Android

Create file `android/key.properties`.

```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/Users/<your-user>/upload-keystore.jks
```

- `flutter build appbundle` for playstore
- `flutter build apk` for github releases

## Acknowledgements

- [Kanjium](https://github.com/mifunetoshiro/kanjium)
- JMDict
- [Jidoujisho](https://github.com/lrorpilla/jidoujisho)
- [Yomichan](https://github.com/FooSoft/yomichan)
- [TTU Reader](https://github.com/ttu-ttu/ebook-reader)
