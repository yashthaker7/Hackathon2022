//
//  TextDetectionForVideoController.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 02/04/22.
//

import UIKit
import AVFoundation
import Vision
import PryntTrimmerView
import Speech

class TextDetectionForVideoController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var PlayerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbSelectorView: ThumbSelectorView!
    @IBOutlet weak var textView: LinkTextView!
    
    @IBOutlet weak var sentimentContainerView: UIView!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var sentimentResultLabel: UILabel!
    @IBOutlet weak var sentimentPercentageLabel: UILabel!
    @IBOutlet weak var separatorLine1: UIView!
    @IBOutlet weak var separatorLine2: UIView!
    
    var dropDownMenu: DropDownMenu?
    
    var words = [Word]()
    
    var searchTimer: Timer?
    
    var demoVideoUrl: URL {
        return Bundle.main.url(forResource: "video", withExtension: "mp4")!
    }
    
    var videoUrl: URL?
    
    lazy var videoAsset: AVAsset = {
        return AVAsset(url: videoUrl ?? demoVideoUrl)
    }()
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    private var generator: AVAssetImageGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutSubviews()
        
        let shareBtnAction = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBtnAction(_:)))
        let speechToText = UIBarButtonItem(image: UIImage(named: "icn_speech_to_text"), style: .plain, target: self, action: #selector(speechToTextBtnAction(_:)))
        
        navigationItem.rightBarButtonItems = [shareBtnAction, speechToText]
        
        setPlayerViewHeight()
        setupVideoPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player.pause()
    }
    
    func setupVideoPlayer() {
        playerItem = AVPlayerItem(asset: videoAsset)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        
        setupThumbnailGenerator(with: videoAsset)
        setPlayerViewHeight()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.thumbSelectorView.asset = self.videoAsset
            self.thumbSelectorView.delegate = self
        }
    }
    
    private func setPlayerViewHeight() {
        guard let track = videoAsset.tracks(withMediaType: .video).first else { return }
        let videoSize = track.naturalSize.applying(track.preferredTransform)
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2))
        let aspectFitSize = AVMakeRect(aspectRatio: videoSize, insideRect: rect)
        PlayerViewHeightConstraint.constant = aspectFitSize.height
        view.layoutIfNeeded()
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
    
    @objc func speechToTextBtnAction(_ sender: UIButton) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechURLRecognitionRequest(url: videoUrl ?? demoVideoUrl)
        
        request.shouldReportPartialResults = true
        
        if (recognizer?.isAvailable)! {
            
            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else { print("Error: \(error!)"); return }
                guard let result = result else { print("No result!"); return }
                
                // print(result.bestTranscription.formattedString)
            
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.textChacker(result.bestTranscription.formattedString)
                    }
                }
                DispatchQueue.main.async {
                    self.textView.text = result.bestTranscription.formattedString
                }
                
            }
        } else {
            print("Device doesn't support speech recognition")
        }
    }
    
    @IBAction func playerViewTapped(_ sender: UITapGestureRecognizer) {
        player.isPlaying ? player.pause() : player.play()
    }
    
    deinit { print(identifier, "deinit") }
}

extension TextDetectionForVideoController {
    
    func predictUsingVision(_ image: UIImage?) {
        textView.text = ""
        textView.removeAllAttributedString()
        words.removeAll()
        sentimentContainerView.isHidden = true
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

extension TextDetectionForVideoController: ThumbSelectorViewDelegate {
    
    func didChangeThumbPosition(_ imageTime: CMTime) {
        player.seek(to: imageTime, toleranceBefore: .zero, toleranceAfter: .zero)
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] timer in
            if let imageRef = try? self?.generator?.copyCGImage(at: self?.player.currentTime() ?? imageTime, actualTime: nil) {
                let image = UIImage(cgImage: imageRef)
                self?.predictUsingVision(image)
            }
        })
    }
    
    private func setupThumbnailGenerator(with asset: AVAsset) {
        generator = AVAssetImageGenerator(asset: asset)
        generator?.appliesPreferredTrackTransform = true
        generator?.requestedTimeToleranceAfter = CMTime.zero
        generator?.requestedTimeToleranceBefore = CMTime.zero
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
