# AITextView - Powerful iOS Rich Text Editor & AI Output Component

> A feature-complete iOS rich text editor framework supporting both UIKit and SwiftUI, perfect for AI streaming output display

[![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)](https://github.com/youyinian288/AITextView)
[![Platform](https://img.shields.io/badge/platform-iOS%2012.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.7+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-BSD%203--clause-green.svg)](LICENSE.md)

## 📋 Table of Contents

- [Feature Demo](#-feature-demo)
- [Project Overview](#-project-overview)
  - [Dual UI Framework Support](#-dual-ui-framework-support)
  - [AI Content Generation Platform](#-ai-content-generation-platform)
- [Core Features](#️-core-features)
- [Dual Purpose](#-dual-purpose)
- [Project Architecture](#-project-architecture)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
- [AI Integration Guide](#-ai-integration-guide)
- [Performance Analysis](#-performance-analysis)
- [Installation](#-installation)
- [API Documentation](#-api-documentation)
- [Contributing](#-contributing)
- [License](#-license)

## 🎥 Feature Demo

### Rich Text Editing Features
![Rich Text Editing Demo](docs/富文本.gif)

### AI Output Feature Demo
![AI Output Demo](docs/AI生成.gif)

## 🎯 Project Overview

AITextView is a powerful rich text editor framework designed specifically for iOS applications, built on WebKit technology and providing complete rich text editing capabilities. The framework adopts a hybrid architecture design that maintains the powerful editing capabilities of web technology while ensuring the performance and user experience of native iOS applications.

### 🎨 Dual UI Framework Support
- **UIKit Integration**: Provides complete UIKit components for seamless integration into traditional iOS projects
- **SwiftUI Support**: Native SwiftUI components that perfectly adapt to modern iOS development architecture
- **Unified API**: Both UI frameworks share the same core functionality, ensuring consistent development experience

### 🤖 AI Content Generation Platform
- **Streaming Output**: Optimized for AI content generation with real-time streaming text output support
- **Format Preservation**: AI-generated content automatically maintains rich text formatting, supporting code highlighting, lists, etc.
- **Interactive Editing**: Users can continue editing and modifying based on AI-generated content
- **Smart Integration**: Built-in AI integration interfaces for easy connection to various AI services

### Key Advantages

- 🚀 **High Performance**: Based on WebKit, supports large amounts of text and complex formats
- 🎨 **Feature Rich**: Supports all mainstream rich text formats and editing operations
- 🔄 **Dual Framework Support**: Simultaneously supports UIKit and SwiftUI
- 📱 **Native Experience**: Perfect integration with iOS keyboard and system features
- 🛠️ **Highly Customizable**: Flexible configuration options and extensibility
- 🌙 **Dark Mode**: Complete support for iOS dark mode
- 🤖 **AI Friendly**: Perfect adaptation for AI streaming output scenarios

## 🛠️ Core Features

### Text Formatting
- ✅ **Basic Formatting**: Bold, italic, underline, strikethrough
- ✅ **Text Styles**: Font size, color, background color
- ✅ **Text Alignment**: Left, center, right, justify
- ✅ **Indentation Control**: Increase/decrease indentation

### Structured Content
- ✅ **Heading Levels**: H1-H6 six-level headings
- ✅ **List Support**: Ordered lists, unordered lists, nested lists
- ✅ **Blockquotes**: Support for quote formatting
- ✅ **Code Blocks**: Inline code and code blocks

### Media Support
- ✅ **Image Insertion**: Support for album selection and camera capture
- ✅ **Link Insertion**: Automatic link recognition and formatting
- ✅ **Table Support**: Create and edit tables

### Editing Features
- ✅ **Undo/Redo**: Complete operation history management
- ✅ **Copy/Paste**: Support for rich text format preservation
- ✅ **Select All/Clear**: Quick selection operations
- ✅ **Adaptive Height**: Automatically adjusts height based on content

### User Experience
- ✅ **Keyboard Toolbar**: Customizable toolbar above keyboard
- ✅ **Focus Management**: Smart focus switching and maintenance
- ✅ **Scroll Optimization**: Smooth scrolling experience
- ✅ **Touch Optimization**: Responsive touch interactions

## 🎭 Dual Purpose

### 1. Rich Text Editor
AITextView can be used as a fully-featured rich text editor, supporting:
- WYSIWYG editing
- Rich formatting options
- Media content insertion
- Real-time preview

### 2. AI Output Component
AITextView is particularly suitable as an output display component for AI applications:
- **Streaming Output Support**: Real-time display of AI-generated content
- **HTML Format Rendering**: Perfect support for AI-returned HTML format content
- **Rich Text Display**: Supports various formats generated by AI (headings, lists, code blocks, etc.)
- **Read-only Mode**: Can be set to read-only mode specifically for content display
- **Dynamic Updates**: Supports dynamic content appending and updating

## 🏗️ Project Architecture

### Architecture Layer Description

#### 1. **User Interface Layer**
- Supports both **UIKit** and **SwiftUI** usage patterns
- Provides flexible integration choices

#### 2. **SwiftUI Wrapper Layer**
- `SwiftUIAITextView`: SwiftUI version of the editor wrapper
- `SwiftUIAITextToolbar`: SwiftUI version of the toolbar wrapper  
- `AITextViewState`: ObservableObject for state management

#### 3. **UIKit Core Layer**
- `AITextView`: Core editor component, inherits from UIView
- `AITextToolbar`: Scrollable toolbar containing various editing operation buttons
- `AITextWebView`: Simple wrapper for WKWebView

#### 4. **Frontend Implementation Layer**
- `rich_editor.html`: Basic HTML structure containing editable div
- `rich_editor.js`: JavaScript logic implementing all rich text editing functionality
- `style.css + normalize.css`: Style definitions and browser compatibility

### 🔄 Key Working Principles

#### JavaScript-Native Communication Mechanism
1. **Swift → JavaScript**: Calls JS functions through `webView.evaluateJavaScript()`
2. **JavaScript → Swift**: Triggers Swift delegate methods through callback URL (`re-callback://`)
3. **Command Queue**: JS packages multiple operations into JSON command queue, Swift processes in batches

#### Delegate Pattern
- `AITextViewDelegate`: Handles editor events (content changes, focus changes, height changes)
- `AITextToolbarDelegate`: Handles operations requiring native UI (color selection, image insertion)

## 🚀 Quick Start

### System Requirements

- iOS 12.0+
- Swift 5.7+
- Xcode 14.0+

### Installation

#### Swift Package Manager (Recommended)

1. In Xcode, select `File` → `Add Package Dependencies`
2. Enter repository URL: `https://github.com/youyinian288/AITextView.git`
3. Select version and add to project

#### CocoaPods

```ruby
pod 'AITextView', '~> 4.3.0'
```

#### Manual Installation

1. Download project source code
2. Drag the `AITextView/Sources` folder into your project
3. Ensure all resource files are added

## 📱 Usage Examples

### UIKit Usage

```swift
import UIKit
import AITextView

class ViewController: UIViewController {
    @IBOutlet var editorView: AITextView!
    @IBOutlet var toolbar: AITextToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup editor
        editorView.delegate = self
        editorView.placeholder = "Enter content..."
        editorView.html = "<p>Hello <b>World</b>!</p>"
        
        // Setup toolbar
        toolbar.editor = editorView
        toolbar.options = AITextDefaultOption.all
    }
}

extension ViewController: AITextViewDelegate {
    func aiTextView(_ editor: AITextView, contentDidChange content: String) {
        print("Content changed: \(content)")
    }
    
    func aiTextView(_ editor: AITextView, heightDidChange height: Int) {
        print("Height changed: \(height)")
    }
}
```

### SwiftUI Usage

```swift
import SwiftUI
import AITextView

struct ContentView: View {
    @StateObject private var editorState = AITextViewState(
        htmlContent: "<p>Hello <b>World</b>!</p>",
        placeholder: "Enter content..."
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor
            SwiftUIAITextView(
                state: editorState,
                onContentChange: { content in
                    print("Content changed: \(content)")
                },
                onHeightChange: { height in
                    print("Height changed: \(height)")
                }
            )
            .frame(minHeight: 200)
            
            // Toolbar
            SwiftUIAITextToolbar(
                state: editorState,
                options: AITextDefaultOption.all
            )
            .frame(height: 44)
            
            // HTML Preview
            ScrollView {
                Text(editorState.htmlContent)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .background(Color(.systemGray6))
        }
    }
}
```

### Custom Toolbar Options

```swift
// Create custom toolbar options
let customOptions: [AITextOption] = [
    AITextDefaultOption.bold,
    AITextDefaultOption.italic,
    AITextDefaultOption.underline,
    AITextDefaultOption.strikeThrough,
    AITextDefaultOption.undo,
    AITextDefaultOption.redo
]

toolbar.options = customOptions
```

### Handling Image Insertion

```swift
extension ViewController: AITextToolbarDelegate {
    func aiTextToolbar(_ toolbar: AITextToolbar, shouldInsertImage image: UIImage) {
        // Handle image insertion logic
        let imageData = image.jpegData(compressionQuality: 0.8)
        let base64String = imageData?.base64EncodedString() ?? ""
        let html = "<img src='data:image/jpeg;base64,\(base64String)' />"
        
        editorView.insertHTML(html)
    }
}
```

## 🤖 AI Integration Guide

### Using as AI Output Component

AITextView is particularly suitable as an output display component for AI applications, supporting streaming output and rich text rendering:

#### 1. Basic AI Output Setup

```swift
class AIViewController: UIViewController {
    @IBOutlet var aiOutputView: AITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set to read-only mode specifically for AI output display
        aiOutputView.editingEnabled = false
        aiOutputView.placeholder = "AI is thinking..."
        
        // Set initial content
        aiOutputView.html = "<h2>🤖 AI Assistant</h2><p>Please ask your question...</p>"
    }
}
```

#### 2. Streaming Output Implementation

```swift
import SwiftOpenAI

class AIStreamController: UIViewController {
    private var aiOutputView: AITextView!
    private var currentMessage: String = ""
    
    private func startAIStream(prompt: String) {
        // Clear previous content
        currentMessage = ""
        aiOutputView.html = "<h3>💬 AI Response</h3><p>Generating response...</p>"
        
        // Create OpenAI service
        let service = OpenAIServiceFactory.service(
            apiKey: "your-api-key",
            overrideBaseURL: "https://api.deepseek.com"
        )
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text("Please return rich text content in HTML format, question: " + prompt))],
            model: .custom("deepseek-chat")
        )
        
        Task {
            do {
                let stream = try await service.startStreamedChat(parameters: parameters)
                
                for try await result in stream {
                    await MainActor.run {
                        let content = result.choices?.first?.delta?.content ?? ""
                        self.currentMessage += content
                        
                        // Real-time display update
                        self.updateAIOutput()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateAIOutput() {
        let htmlContent = """
        <div style="background-color: #f8f9fa; border-left: 4px solid #28a745; padding: 12px; margin: 8px 0; border-radius: 4px;">
            <h4 style="color: #28a745; margin: 0 0 8px 0;">💬 AI Response</h4>
            <div style="margin: 0; color: #333; line-height: 1.6;">\(currentMessage)</div>
        </div>
        """
        
        aiOutputView.html = htmlContent
    }
}
```

#### 3. SwiftUI AI Output Component

```swift
struct AIOutputView: View {
    @StateObject private var aiState = AITextViewState(
        htmlContent: "<h2>🤖 AI Assistant</h2>",
        placeholder: "AI is thinking..."
    )
    
    var body: some View {
        SwiftUIAITextView(
            state: aiState,
            editingEnabled: false, // Read-only mode
            onContentChange: { content in
                // Handle content changes
            }
        )
        .frame(minHeight: 300)
        .background(Color(.systemBackground))
    }
    
    func updateAIResponse(_ response: String) {
        aiState.htmlContent = """
        <div style="padding: 16px; background-color: #f8f9fa; border-radius: 8px;">
            <h3 style="color: #28a745;">🤖 AI Response</h3>
            <div style="margin-top: 12px; line-height: 1.6;">\(response)</div>
        </div>
        """
    }
}
```

### Supported AI Services

AITextView can integrate with various AI services:

- ✅ **OpenAI GPT Series**
- ✅ **DeepSeek**
- ✅ **Claude (via OpenRouter)**
- ✅ **Gemini**
- ✅ **Local Models (Ollama)**
- ✅ **Other OpenAI API Compatible Services**

## 🤝 Contributing

We welcome community contributions! Please follow these steps:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Environment Setup

1. Clone the repository
2. Open `AITextView.xcodeproj`
3. Select target device or simulator
4. Run the project

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Thanks to all contributors for their efforts
- Based on the [RichEditorView](https://github.com/T-Pro/AITextView) project with improvements
- Thanks to the open source community for support
- Special thanks to the [SwiftOpenAI](https://github.com/youyinian288/SwiftOpenAI) project for AI integration support

## 📞 Contact

- Project Homepage: [https://github.com/youyinian288/AITextView](https://github.com/youyinian288/AITextView)
- Issue Reports: [Issues](https://github.com/youyinian288/AITextView/issues)
- Discussions: [Discussions](https://github.com/youyinian288/AITextView/discussions)

---

**AITextView** - Making rich text editing and AI output simple and powerful! 🚀

## 🎯 Use Cases

### Rich Text Editor Scenarios
- 📝 Note-taking applications
- 📰 Content management systems
- 📧 Email editors
- 📄 Document editors
- 💬 Chat applications (rich text messages)

### AI Output Component Scenarios
- 🤖 AI chat applications
- 📊 AI content generation tools
- 🎓 AI education applications
- 💡 AI writing assistants
- 🔍 AI search result display

Choose AITextView to provide powerful rich text editing and AI output capabilities for your iOS applications!
