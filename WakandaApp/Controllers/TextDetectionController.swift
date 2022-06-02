//
//  TextDetectionController.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 02/04/22.
//

import UIKit
import AVFoundation
import Vision

class TextDetectionController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: LinkTextView!
    
    @IBOutlet weak var sentimentContainerView: UIView!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var sentimentResultLabel: UILabel!
    @IBOutlet weak var sentimentPercentageLabel: UILabel!
    @IBOutlet weak var separatorLine1: UIView!
    @IBOutlet weak var separatorLine2: UIView!
    
    var image: UIImage?
    
    var dropDownMenu: DropDownMenu?
    
    var words = [Word]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareBtnAction = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBtnAction(_:)))
        navigationItem.rightBarButtonItem = shareBtnAction
        
        predictUsingVision(image)
    }
    
    @objc func shareBtnAction(_ sender: UIBarButtonItem) {
        guard let finalText = textView.text, finalText.count > 0 else { return }
        let activityVC = UIActivityViewController(activityItems: [finalText], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: 150, y: self.view.frame.height/2, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = [.left, .right]
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    private func textChacker(_ text: String) {
        let textArray = text.replacingOccurrences(of: "\n", with: " ").components(separatedBy: " ")
        for word in textArray {
            let w = Word(originalText: word)
            let textChecker = UITextChecker()
            let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: NSRange(0..<word.utf16.count), startingAt: 0, wrap: false, language: "en_US")
            if misspelledRange.location != NSNotFound,
               let guesses = textChecker.guesses(forWordRange: misspelledRange, in: word, language: "en_US") {
                w.addSuggestions(guesses)
            }
            words.append(w)
        }
        print(words.count)
        self.textView.text = text
        self.textView.addAttributedText(words)
        self.textView.onLinkTap = { originalText in
            print("originalText: \(originalText)")
            guard let w = self.words.first(where: { $0.originalText == originalText }), w.suggestions.count > 0 else { return }
            if w.isWrongWord {
                self.dropDownMenu = DropDownMenu(title: originalText, list: w.suggestions)
            }
//            else if w.isAbusiveWord {
//                self.dropDownMenu = DropDownMenu(title: originalText, list: [AbusiveWordAction.censor.title, AbusiveWordAction.remove.title])
//            }
            self.dropDownMenu?.showMenu(on: self, summonView: self.textView, topSpacing: 0) { selectedNewText in
                print(selectedNewText)
                if selectedNewText == AbusiveWordAction.censor.title {
                    var censorText = ""
                    for i in 0..<w.originalText.count {
                        censorText += "*"
                    }
                    print(censorText)
                    w.isAbusiveWord = false
                    w.originalText = censorText
                    self.textView.text = self.textView.text.replacingOccurrences(of: selectedNewText, with: censorText)
                } else if selectedNewText == AbusiveWordAction.remove.title {
                    if let index = self.words.firstIndex(where: { $0.uuid == w.uuid }) {
                        self.words.remove(at: index)
                    }
                    self.textView.text = self.textView.text.replacingOccurrences(of: selectedNewText, with: "")
                } else {
                    w.isWrongWord = false
                    w.suggestions = []
                    w.originalText = selectedNewText
                    self.textView.text = self.textView.text.replacingOccurrences(of: originalText, with: selectedNewText)
                }
                self.textView.removeAllAttributedString()
                self.textView.addAttributedText(self.words)
                self.dropDownMenu = nil
                self.sentimentContainerView.isHidden = true
            }
        }
    }
    
    @IBAction func getSentimentBtnAction(_ sender: UIButton) {
        guard let text = textView.text, text.count > 0 else {
            AlertManager.showErrorAlert(message: "No Text Found.")
            return
        }
        TextDetectionController.getSentiment(text: text) { sentimentResponse in
            self.sentimentContainerView.backgroundColor = sentimentResponse.getBackgroundSentimentColor
            self.sentimentContainerView.borderColor = sentimentResponse.getSentimentColor
            self.sentimentLabel.textColor = sentimentResponse.getSentimentColor
            self.sentimentResultLabel.textColor = sentimentResponse.getSentimentColor
            self.sentimentPercentageLabel.textColor = sentimentResponse.getSentimentColor
            self.sentimentResultLabel.text = sentimentResponse.sentimentResult
            self.sentimentPercentageLabel.text = sentimentResponse.getPercentage
            self.sentimentContainerView.isHidden = false
            self.separatorLine1.backgroundColor = sentimentResponse.getSentimentColor
            self.separatorLine2.backgroundColor = sentimentResponse.getSentimentColor
        }
    }
    
    static func getSentiment(text: String, completion: @escaping (SentimentResponse) -> ()) {
        let parameters = SentimentRequest(text: text).parameters
        let service = Service()
        service.requestData(.analyze, method: .post, parameters: parameters, headers: service.headers) { (result: Result<SentimentResponse, ServiceError>) in
            switch result {
            case .success(let response):
                completion(response)
            case .failure(let serviceError):
                print(serviceError.localizedDescription)
            }
        }
    }
    
    deinit { print(identifier, "deinit") }
}

extension TextDetectionController {
    
    func predictUsingVision(_ image: UIImage?) {
        imageView.image = image
        if let image = image {
            let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2))
            let aspectFitSize = AVMakeRect(aspectRatio: image.size, insideRect: rect)
            imageViewHeightConstraint.constant = aspectFitSize.height
            view.layoutIfNeeded()
        }
        textView.text = ""
        words.removeAll()
        var handler: VNImageRequestHandler?
        if let cgImage = image?.cgImage {
            handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        } else if let ciImage = image?.ciImage {
            handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        }
        let request = VNRecognizeTextRequest { [unowned self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            let text = observations.compactMap({ $0.topCandidates(1).first?.string }).joined(separator: "\n")
            self.textView.text = text
            self.textChacker(text)
        }
        request.recognitionLanguages = ["en-US"]
        request.recognitionLevel = .accurate
        try? handler?.perform([request])
    }
}



