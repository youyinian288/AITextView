import SwiftUI
import AITextView

/// A state management class for the rich text editor, designed for use in SwiftUI environments.
@available(iOS 13.0, *)
public class AITextViewState: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The HTML content of the editor.
    @Published public var htmlContent: String
    
    /// A boolean value indicating whether the editor is currently focused.
    @Published public var isEditing: Bool = false
    
    /// The dynamic height of the editor content.
    @Published public var editorHeight: CGFloat = 200
    
    // MARK: - Properties
    
    /// A weak reference to the underlying AITextView instance.
    public var editor: AITextView?
    
    // MARK: - Initialization
    
    /// Initializes the state with optional initial HTML content.
    /// - Parameter htmlContent: The initial HTML content to load into the editor.
    public init(htmlContent: String = "") {
        self.htmlContent = htmlContent
    }
    
    // MARK: - Public Methods
    
    /// Clears the content of the editor.
    public func clearContent() {
        htmlContent = ""
        editor?.html = ""
    }
    
    /// Inserts sample HTML content into the editor for demonstration purposes.
    public func insertSampleContent() {
        let sampleHTML = """
        <h2>Welcome to the Rich Editor</h2>
        <p>This is a powerful rich text editor that supports:</p>
        <ul>
            <li><strong>Bold</strong> and <em>italic</em> text</li>
            <li><u>Underline</u> and <s>strikethrough</s></li>
            <li>Multiple heading levels</li>
            <li>Ordered and unordered lists</li>
            <li>Text alignment</li>
            <li>Text and background colors</li>
        </ul>
        <p>Start editing now!</p>
        """
        htmlContent = sampleHTML
        editor?.html = sampleHTML
    }
    
    /// Asynchronously retrieves the plain text content of the editor.
    /// - Parameter completion: A closure that receives the plain text string.
    public func getPlainText(completion: @escaping (String) -> Void) {
        guard let editor = editor else {
            completion("")
            return
        }
        editor.getText { text in
            completion(text)
        }
    }
    
    /// Asynchronously retrieves content statistics, such as character and word counts.
    /// - Parameter completion: A closure that receives the character count and word count.
    public func getContentStats(completion: @escaping (Int, Int) -> Void) {
        getPlainText { plainText in
            let characters = plainText.count
            let words = plainText.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }.count
            completion(characters, words)
        }
    }
    
    /// Saves the current HTML content to UserDefaults.
    public func autoSave() {
        UserDefaults.standard.set(htmlContent, forKey: "AITextViewAutoSave")
    }
    
    /// Restores the HTML content from UserDefaults if available.
    public func restoreFromAutoSave() {
        if let savedContent = UserDefaults.standard.string(forKey: "AITextViewAutoSave"),
           !savedContent.isEmpty {
            htmlContent = savedContent
            editor?.html = savedContent
        }
    }
    
    /// Saves the current HTML content to a file in the documents directory.
    /// - Parameter filename: The name of the file to save the content to.
    public func saveToFile(filename: String = "ai_text_view_content.html") {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to access documents directory.")
            return
        }
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try htmlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Content successfully saved to: \(fileURL.path)")
        } catch {
            print("Failed to save content: \(error)")
        }
    }
    
    /// Loads HTML content from a file in the documents directory.
    /// - Parameter filename: The name of the file to load the content from.
    public func loadFromFile(filename: String = "ai_text_view_content.html") {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to access documents directory.")
            return
        }
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            htmlContent = content
            editor?.html = content
            print("Content successfully loaded from file.")
        } catch {
            print("Failed to load content: \(error)")
        }
    }
}
