# Cosmo Pic

## Introduction
Cosmo Pic is a captivating and educational mobile application that offers astronomy enthusiasts and space lovers a daily journey through the cosmos. This app brings the fascinating world of space right to your fingertips, featuring the Astronomy Picture of the Day (APOD) provided by NASA. Each day, users are treated to a stunning new image or photograph of our fascinating universe, along with a brief explanation.

## Features
- **Daily Astronomy Picture**: Discover a new and awe-inspiring image of space every day, complete with detailed descriptions that unravel the mysteries and science behind each picture.

- **Favorites Gallery**: Curate your own collection of favorite space images. Save the ones that inspire you the most and build a personalized gallery of cosmic wonders.

- **1-Month History**: Delve into the recent past with a visual history of the last 30 days. This feature ensures you never miss out on any celestial spectacle and allows you to revisit your favorite cosmic moments.

## Requirements Compliance

### General
| Feature                         | Description | Status |
|---------------------------------|-------------|:------:|
| **Xcode and iOS Version**       | Used Xcode 15 with iOS 17.x | ✅ |
| **No Third-party Frameworks**   | The app does not use any third-party frameworks | ✅ |
| **Launch Screen**               | Launch screen featuring the App Icon in a bigger version | ✅ |
| **Completed Features**          | All features in the app are completed and fully functional | ✅ |
| **List Screen**                 | The history is loaded as a list | ✅ |
| **Detail View Navigation**      | Details of how tapping an item navigates to a detailed view | ✅ |
| **Network Calls**               | Explanation of the network calls implemented using URLSession | ✅ |
| **Error Handling**              | Cusom Error Handlers for Network and Decoding errors | ✅ |
| **Data Saving Method**          | Use UserDefaults and files to store data | ✅ |
| **Concurrency**                 | Usage of Swift Modern Concurrency, async/await, and MainActor | ✅ |
| **User Communication**          | Strategies used to communicate with the user when data is missing or empty | ✅ |
| **UI Design Compliance**        | Assurance of no UI issues and adaptability to different orientations and themes | ✅ |
| **Code Organization and Readability** | Code is plit up in small chunks and reusable functions and follows common architecture styles | ✅ |
| **MVVM Architecture**           | MVVM is used | ✅ |
| **SwiftLint**                   | Confirmation of using SwiftLint with Kodeco’s configuration | ✅ |
| **Build Status**                | The app builds without warnings or errors | ✅ |
| **Testing**                     | Test plan, including UI and unit tests, and code coverage | ✅ |
| **Additional Elements**         | Custom app icon, onboarding screen, custom display name, SwiftUI animations, styled text properties | ✅ |

### Specific File Locations

| Requirement | File Location |
|-------------|---------------|
| Launch Screen Implementation | CosmoPic.xcodeproj |
| List Screen Implementation | HistoryView.swift |
| Detail View Navigation Implementation | HistoryView.swift, PhotoDetaulView.swift |
| URLSession Network Calls Implementation | PhotoAPIService.swift, HistoryAPIService.swift |
| Network Error Handling Implementation | PhotoAPIService.swift, HistoryAPIService.swift, FetchPhotoError.swift, FetchHistoryError.swift, JSONDecoderErrorHandler.swift |
| Data Saving Method Implementation | PhotoAPIService.swift, HistoryAPIService.swift |
| Modern Concurrency Usage Implementation | DataStore.swift, PhotoAPIService.swift, HistoryAPIService.swift |
| User Communication for Missing Data Implementation | APODView.swift, PhotoDetailView.swift, HistoryView.swift |
| UI Design Compliance for Different Orientations and Themes | All views |
| Code Organization (Views, Models, Networking, etc.) | All files are organized in following categories: Views, Models, ViewModels, Services and Extensions |
| SwiftLint Configuration and Usage | All files |
| Testing Plan and Code Coverage | CosmoPicDataStoreTests.swift, CosmoPicUITests.swift |
| Custom App Icon Implementation | Assets.xcassets |
| Onboarding Screen Implementation | WelcomeView.swift |
| Custom Display Name Implementation | CosmoPic.xcodeproj |
| SwiftUI Animation Implementation | APODView.swift |
| Styled Text Properties Implementation | WelcomeView.swift |

## Development
- In order to run the app you need an API-Key you can really easy get at https://api.nasa.gov/
- The API Key is limited to a maximum of 100 requests per hour. Thats why every file I download in the app get's cached in the Documents Directory of the app
- Just copy / paste and rename ```APOD-Info-sample.plist``` to ```APOD-Info.plist``` and paste your API-Key
- The app should build, run and work without an ```APOD-Info.plist``` and your own API-Key too for your convenience, because the DEMO_KEY included in the ```APOD-Info-sample.plist``` is actually a valid API-Key too. Though I can not guarantee that it will work forever I still advice you, to get your own key
- To run the Autogenerated test plan which includes unit and UI test just press cmd + U