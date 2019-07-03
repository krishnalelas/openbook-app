The buzzing! (Useful) Social Media mobile app.

## Requirements

* [Flutter](https://flutter.io/get-started/install/)

## Project overview

The project is a [Flutter](https://flutter.dev) application.
 
It's dependent on the [buzzing-api] (buzzing-api) backend.


## Getting started

### 1. Install the `buzzing-api` backend.

Make sure the `buzzing-api` server is running.

### 2. Install Flutter

Visit the [Flutter Install website](https://flutter.io/docs/get-started/install) and follow instructions.

Once you're done, make sure everything works properly by running `flutter doctor`.

````sh
flutter doctor
````

### 3. Go to the root repository

```sh
cd buzzing-app
```

```
run_prod:
	flutter run --flavor production

run_dev:
	flutter run --flavor development

build_prod:
	flutter build --flavor production

build_ios_dev:
	flutter build ios --flavor development

build_apk_dev:
	flutter build apk --flavor development

build_ios_prod:
	flutter build ios --flavor production

build_apk_prod:
	flutter build apk --flavor production
```