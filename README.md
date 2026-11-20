# Wikipedia Random Articles

A Flutter application that fetches and displays random Wikipedia articles using the Wikipedia REST API.

The project demonstrates the **Model-View-ViewModel (MVVM)** architectural pattern in Flutter, with a focus on separation of concerns, asynchronous programming, state management, and API integration.

## Features

- Fetch random Wikipedia articles.
- Display article titles and descriptions.
- Display article images when available.
- Navigate to another random article.
- Handle API errors and network failures.
- Display loading indicators while fetching data.
- Retry failed requests.

## Technologies

- **Flutter** – Cross-platform UI framework.
- **Dart** – Programming language.
- **HTTP** – HTTP requests and API communication.
- **Wikipedia REST API** – Random article data source.
- **ChangeNotifier** – Reactive state management.
- **ListenableBuilder** – Rebuild UI when ViewModel state changes.

## Architecture

The application follows the Model-View-ViewModel (MVVM) architectural pattern.

```text
                 ArticleView
                      |
                      | observes
                      v
               ArticleViewModel
                      |
                      | requests data
                      v
                 ArticleModel
                      |
                      | HTTP Request
                      v
              Wikipedia REST API
```

### Project Components

#### 1. ArticleModel

Responsible for data retrieval and communication with the Wikipedia API.

Responsibilities:

- Construct API requests.
- Perform HTTP GET requests.
- Handle HTTP response status codes.
- Decode JSON responses.
- Convert JSON data into `Summary` objects.

#### 2. ArticleViewModel

Acts as the intermediary between the Model and the View.

Responsibilities:

- Manage application state.
- Fetch random articles.
- Track loading status.
- Handle errors.
- Notify listeners when state changes.

It extends Flutter's `ChangeNotifier` to support reactive UI updates.

#### 3. ArticleView

The main application screen.

Responsibilities:

- Initialize and dispose of the ViewModel.
- Listen to ViewModel changes using `ListenableBuilder`.
- Display the appropriate UI based on the current state.

#### 4. ArticlePage

Responsible for the article page layout and navigation controls.

#### 5. ArticleWidget

A presentational widget responsible for displaying:

- Article title.
- Article description.
- Article image, when available.

## API

The application uses the Wikipedia REST API.

**Endpoint:**

```http
GET https://en.wikipedia.org/api/rest_v1/page/random/summary
```

The endpoint returns a random Wikipedia article summary in JSON format.

Official API documentation:

<https://en.wikipedia.org/api/rest_v1/>

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE such as Android Studio or Visual Studio Code
- Internet connection

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
```

1. Navigate to the project directory:

```bash
cd wikipedia_random_articles
```

1. Install dependencies:

```bash
flutter pub get
```

1. Run the application:

```bash
flutter run
```

## Dependencies

The project uses the following packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.0.0
```

See `pubspec.yaml` for the actual dependency versions used by the project.

## State Management

The application uses `ChangeNotifier` and `ListenableBuilder` for state management.

The ViewModel maintains three main state properties:

| Property | Purpose |
| --- | --- |
| `isLoading` | Indicates whether an API request is in progress. |
| `summary` | Stores the retrieved article. |
| `error` | Stores any error encountered during retrieval. |

When the ViewModel changes its state, it calls `notifyListeners()`, causing the listening UI to rebuild.

## Learning Objectives

This project explores several important Flutter and software development concepts:

- MVVM architecture.
- Separation of concerns.
- Asynchronous programming with `Future` and `async/await`.
- REST API integration.
- JSON serialization and deserialization.
- Reactive state management with `ChangeNotifier`.
- Widget composition and reusable UI components.
- Error handling and resource lifecycle management.

## Future Improvements

Potential improvements include:

- [ ] Add article categories and search functionality.
- [ ] Allow users to save favorite articles.
- [ ] Add article sharing functionality.
- [ ] Display article links and full Wikipedia content.
- [ ] Implement caching.
- [ ] Introduce explicit UI states using a sealed class.
- [ ] Add unit tests for the Model and ViewModel.
- [ ] Add widget tests for the UI.

## License

This project is intended for educational and learning purposes.

Article content and images are provided by Wikipedia and remain subject to their respective licenses.
