//
//  SwiftUIView.swift
//  AITextView
//
//  Created by yunning you on 2025/10/7.
//

import SwiftUI
import AITextView

@available(iOS 13.0, *)
public struct SwiftUIAITextView: UIViewRepresentable {
      
  // MARK: - Binding Properties
    @Binding private var htmlContent: String
    @Binding private var isEditing: Bool
    
    // MARK: - Configuration Properties
    private let placeholder: String
    private let isScrollEnabled: Bool
    private let editingEnabled: Bool
    private let backgroundColor: UIColor
    private let showsKeyboardToolbar: Bool
    private let keyboardToolbarDoneButtonText: String
    private let onContentChange: ((String) -> Void)?
    private let onHeightChange: ((Int) -> Void)?
    private let onFocusChange: ((Bool) -> Void)?
    private let onEditorReady: ((AITextView) -> Void)?
    
    // MARK: - Initializer
    
    /// Basic initializer
    /// - Parameters:
    ///   - htmlContent: HTML content binding
    ///   - isEditing: Editing state binding
    ///   - placeholder: Placeholder text
    ///   - isScrollEnabled: Whether scrolling is enabled
    ///   - editingEnabled: Whether editing is enabled
    ///   - backgroundColor: Background color
    ///   - showsKeyboardToolbar: Whether to show keyboard toolbar
    ///   - keyboardToolbarDoneButtonText: Keyboard toolbar Done button text
    ///   - onContentChange: Content change callback
    ///   - onHeightChange: Height change callback
    ///   - onFocusChange: Focus change callback
    ///   - onEditorReady: Editor ready callback
    public init(
        htmlContent: Binding<String>,
        isEditing: Binding<Bool> = .constant(false),
        placeholder: String = "Enter content...",
        isScrollEnabled: Bool = true,
        editingEnabled: Bool = true,
        backgroundColor: UIColor = .systemBackground,
        showsKeyboardToolbar: Bool = false,
        keyboardToolbarDoneButtonText: String = "Done",
        onContentChange: ((String) -> Void)? = nil,
        onHeightChange: ((Int) -> Void)? = nil,
        onFocusChange: ((Bool) -> Void)? = nil,
        onEditorReady: ((AITextView) -> Void)? = nil
    ) {
        self._htmlContent = htmlContent
        self._isEditing = isEditing
        self.placeholder = placeholder
        self.isScrollEnabled = isScrollEnabled
        self.editingEnabled = editingEnabled
        self.backgroundColor = backgroundColor
        self.showsKeyboardToolbar = showsKeyboardToolbar
        self.keyboardToolbarDoneButtonText = keyboardToolbarDoneButtonText
        self.onContentChange = onContentChange
        self.onHeightChange = onHeightChange
        self.onFocusChange = onFocusChange
        self.onEditorReady = onEditorReady
    }
    
    // MARK: - UIViewRepresentable Implementation
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> AITextView {
        let editor = AITextView()
        
        // Basic configuration
        editor.delegate = context.coordinator
        editor.placeholder = placeholder
        editor.isScrollEnabled = isScrollEnabled
        editor.editingEnabled = editingEnabled
        editor.setEditorBackgroundColor(backgroundColor)
        
        // Keyboard toolbar configuration
        editor.showsKeyboardToolbar = showsKeyboardToolbar
        editor.keyboardToolbarDoneButtonText = keyboardToolbarDoneButtonText
        
        // Set initial content
        if !htmlContent.isEmpty {
            editor.html = htmlContent
        }
        
        // Notify that editor is ready
        onEditorReady?(editor)
        
        return editor
    }
    
    public func updateUIView(_ uiView: AITextView, context: Context) {
        // Update content (avoid circular updates)
        if uiView.contentHTML != htmlContent {
            uiView.html = htmlContent
        }
        
        // Update editing state
        if uiView.editingEnabled != editingEnabled {
            uiView.editingEnabled = editingEnabled
        }
        
        // Update placeholder
        if uiView.placeholder != placeholder {
            uiView.placeholder = placeholder
        }
        
        // Update keyboard toolbar configuration
        if uiView.showsKeyboardToolbar != showsKeyboardToolbar {
            uiView.showsKeyboardToolbar = showsKeyboardToolbar
        }
        
        if uiView.keyboardToolbarDoneButtonText != keyboardToolbarDoneButtonText {
            uiView.keyboardToolbarDoneButtonText = keyboardToolbarDoneButtonText
        }
    }
}

// MARK: - Coordinator
@available(iOS 13.0, *)
extension SwiftUIAITextView {
    public class Coordinator: NSObject, AITextViewDelegate {
        var parent: SwiftUIAITextView
        
        init(_ parent: SwiftUIAITextView) {
            self.parent = parent
        }
        
        // MARK: - AITextViewDelegate Methods
        
        public func aiTextView(_ editor: AITextView, contentDidChange content: String) {
            // Update bound HTML content
            DispatchQueue.main.async {
                self.parent.htmlContent = content
                self.parent.onContentChange?(content)
            }
        }
        
        public func aiTextView(_ editor: AITextView, heightDidChange height: Int) {
            DispatchQueue.main.async {
                self.parent.onHeightChange?(height)
            }
        }
        
        public func aiTextViewTookFocus(_ editor: AITextView) {
            DispatchQueue.main.async {
                self.parent.isEditing = true
                self.parent.onFocusChange?(true)
            }
        }
        
        public func aiTextViewLostFocus(_ editor: AITextView) {
            DispatchQueue.main.async {
                self.parent.isEditing = false
                self.parent.onFocusChange?(false)
            }
        }
        
        public func aiTextViewDidLoad(_ editor: AITextView) {
            // Editor loading completed
        }
        
        public func aiTextView(_ editor: AITextView, shouldInteractWith url: URL) -> Bool {
            return true
        }
        
        public func aiTextView(_ editor: AITextView, handle action: String) {
            // Handle custom actions
        }
    }
}