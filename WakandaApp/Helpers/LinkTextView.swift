//
//  LinkTextView.swift
//  UpperTeams
//
//  Created by SOTSYS302 on 02/04/22.
//

import UIKit

class LinkTextView: UITextView, UITextViewDelegate {
    
    typealias OnLinkTap = (String) -> ()
    
    var onLinkTap: OnLinkTap?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isEditable = false
        isSelectable = true
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        isEditable = false
        isSelectable = true
        delegate = self
    }
    
    func addAttributedText(_ words: [Word]) {
        guard attributedText.length > 0 else { return }
        let mText = NSMutableAttributedString(attributedString: attributedText)
        
        for word in words {
            guard word.originalText.count > 0 else { continue }
            let newOriginalText = word.originalText.replacingOccurrences(of: "\"", with: "^^").replacingOccurrences(of: "'", with: "^^^")
            let linkRange = mText.mutableString.range(of: newOriginalText)
            mText.addAttributes([.foregroundColor: UIColor.black], range: linkRange)
            mText.removeAttribute(.link, range: linkRange)
            mText.removeAttribute(.underlineColor, range: linkRange)
            mText.removeAttribute(.underlineStyle, range: linkRange)
            mText.removeAttribute(.strikethroughStyle, range: linkRange)
            mText.removeAttribute(.strikethroughColor, range: linkRange)
            if word.isWrongWord {
                mText.addAttribute(.link, value: word.originalText, range: linkRange)
                mText.addAttributes([
                    .foregroundColor: UIColor.black,
                    .underlineColor: UIColor.red,
                    .underlineStyle: NSUnderlineStyle.single.rawValue], range: linkRange)
            }
            if word.isAbusiveWord {
                mText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.thick.rawValue, range: linkRange)
                mText.addAttribute(.strikethroughColor, value: UIColor.red, range: linkRange)
            }
//            if !word.isWrongWord && !word.isAbusiveWord {
//                mText.addAttributes([.foregroundColor: UIColor.black], range: linkRange)
//                mText.removeAttribute(.link, range: linkRange)
//                mText.removeAttribute(.underlineColor, range: linkRange)
//                mText.removeAttribute(.underlineStyle, range: linkRange)
//                mText.removeAttribute(.strikethroughStyle, range: linkRange)
//                mText.removeAttribute(.strikethroughColor, range: linkRange)
//            }
        }
//        let linkAttributes: [NSAttributedString.Key : Any] = [
//            NSAttributedString.Key.foregroundColor: UIColor.black,
//            NSAttributedString.Key.underlineColor: UIColor.red,
//            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDash.rawValue
//        ]
//        linkTextAttributes = linkAttributes
        attributedText = mText
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let newOriginalText = URL.absoluteString.replacingOccurrences(of: "^^", with: "\"").replacingOccurrences(of: "^^^", with: "'")
        onLinkTap?(newOriginalText)
        return false
    }
    
    // to disable text selection
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
    
    func removeAllAttributedString() {
        let mText = NSMutableAttributedString(attributedString: attributedText)
        mText.setAttributes([:], range: NSRange(0..<attributedText.length))
        mText.addAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .regular)], range: NSRange(0..<attributedText.length))
        attributedText = mText
    }
    
    deinit { print(identifier, "deinit") }
}
