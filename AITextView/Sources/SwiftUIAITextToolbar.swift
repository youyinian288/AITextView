import UIKit
import SwiftUI

@available(iOS 13.0, *)
public struct SwiftUIAITextToolbar: UIViewRepresentable {
    
    // MARK: - Properties
    private let options: [AITextOption]
    private let barTintColor: UIColor?
    private weak var editor: AITextView?
    private let onTextColorChange: (() -> Void)?
    private let onBackgroundColorChange: (() -> Void)?
    private let onImageInsert: (() -> Void)?
    private let onLinkInsert: (() -> Void)?
    
    // MARK: - Initializer
    
    /// Initialize toolbar
    /// - Parameters:
    ///   - options: Toolbar options array
    ///   - barTintColor: Toolbar background color
    ///   - editor: Associated editor
    ///   - onTextColorChange: Text color change callback
    ///   - onBackgroundColorChange: Background color change callback
    ///   - onImageInsert: Image insert callback
    ///   - onLinkInsert: Link insert callback
    public init(
        options: [AITextOption] = AITextDefaultOption.all,
        barTintColor: UIColor? = nil,
        editor: AITextView? = nil,
        onTextColorChange: (() -> Void)? = nil,
        onBackgroundColorChange: (() -> Void)? = nil,
        onImageInsert: (() -> Void)? = nil,
        onLinkInsert: (() -> Void)? = nil
    ) {
        self.options = options
        self.barTintColor = barTintColor
        self.editor = editor
        self.onTextColorChange = onTextColorChange
        self.onBackgroundColorChange = onBackgroundColorChange
        self.onImageInsert = onImageInsert
        self.onLinkInsert = onLinkInsert
    }
    
    // MARK: - UIViewRepresentable Implementation
    
    public func makeCoordinator() -> ToolbarCoordinator {
        ToolbarCoordinator(self)
    }
    
    public func makeUIView(context: Context) -> AITextToolbar {
        let toolbar = AITextToolbar()
        toolbar.options = options
        toolbar.delegate = context.coordinator
        toolbar.editor = editor
        
        if let barTintColor = barTintColor {
            toolbar.barTintColor = barTintColor
        }
        
        return toolbar
    }
    
    public func updateUIView(_ uiView: AITextToolbar, context: Context) {
        uiView.options = options
        uiView.editor = editor
        
        if let barTintColor = barTintColor {
            uiView.barTintColor = barTintColor
        }
    }
}

// MARK: - Toolbar Coordinator

@available(iOS 13.0, *)
extension SwiftUIAITextToolbar {
    public class ToolbarCoordinator: NSObject, AITextToolbarDelegate {
        var parent: SwiftUIAITextToolbar
        
        init(_ parent: SwiftUIAITextToolbar) {
            self.parent = parent
        }
        
        // MARK: - AITextToolbarDelegate Methods
        
        public func aiTextToolbarChangeTextColor(_ toolbar: AITextToolbar) {
            parent.onTextColorChange?()
        }
        
        public func aiTextToolbarChangeBackgroundColor(_ toolbar: AITextToolbar) {
            parent.onBackgroundColorChange?()
        }
        
        public func aiTextToolbarInsertImage(_ toolbar: AITextToolbar) {
            parent.onImageInsert?()
        }
        
        public func aiTextToolbarInsertLink(_ toolbar: AITextToolbar) {
            parent.onLinkInsert?()
        }
    }
}

