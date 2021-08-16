//
//  MasterFileController.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 7/5/21.
//

import SwiftUI
import AVFoundation
import Buttery
import Combine
import QuickLookThumbnailing
import Network

class MasterFileController: NSObject, ObservableObject {
    
    @AppStorage("openSharingSeparately") var openSharingSeparately = false
    @AppStorage("viewLayout") var viewLayout: ViewLayout = .grid
    @AppStorage("autoPlayVideos") var autoPlayVideos = false
    
    enum FileType { case video, image, audio }
    private var cancellables = Set<AnyCancellable>()
    
    @Published var networkMonitor: NetworkMonitor
    @Published var openWindows: [NSWindow] = [] {
        didSet {
//            print("openWindows was set. Currently there are \(openWindows.count) open windows.")
//            openWindows.forEach({ print("\($0.identifier) is in openWindows")})
        }
    }
    
    @Published var files: [File] = []
    @Published var file: AVFile?
    @Published var player: AVPlayer?
    @Published var playerItem: AVPlayerItem?
    // Key-value observing context
    private var playerItemContext = 0
    @Published var frameRate: Float = 0
    @Published var shareFile = false
    @Published var sharingWindowIsOpen = false
    @Published var sharingControlsIsOpen = false
    
    @Published var name: String = ""
    @Published var additionalName: String = ""
    @Published var splashImage: Image?
    @Published var thumbnailImage: Image?
    
    @Published var previousFile: File?
    @Published var previousImage: Image?
    @Published var nextImage: Image?
    @Published var nextFile: File?
    
    @Published var isPlaying = false
    @Published var defaultSeek: (Double, String, String) = Constants.tenSecondsSeek
    @Published var startVideoSeconds:Double = 0.0
    @Published var backInSeconds:Double = 0.0
    @Published var forwardInSeconds:Double = 0.0
    @Published var lastPlayInSeconds:Double = 0.0
    @Published var showsControls = false
    @Published var videoGravity = AVLayerVideoGravity.resizeAspect
    @Published var loop = false
    @Published var isMuted = false
    
    @Published var sharingCode = ""
    static let shareWindowCode = String.Element(Unicode.Scalar(7))
    
    var unwrappedFrameRate: Float {
        player?.currentItem?.asset.tracks(withMediaType: .video).first?.nominalFrameRate ?? 0.00
    }
    @Published var unwrappedVideoFrameRate: Float = 0
    var unwrappedPlaybackRate: Float {
        player?.currentItem?.tracks.first(where: { $0.isEnabled })?.currentVideoFrameRate ?? 0.0
    }
    var videoFR: Float {
        let frameDuration = player?.currentItem?.asset.tracks(withMediaType: .video).first(where: { $0.isEnabled })?.minFrameDuration
        return Float(frameDuration?.timescale ?? .zero) / Float(frameDuration?.value ?? .zero)
    }
    var unwrappedTracksCount: Int {
        player?.currentItem?.tracks.count ?? 0
    }
    var unwrappedTime: Double {
        player?.currentItem?.duration.seconds ?? 0
    }
    var unwrappedSize: CGFloat {
        player?.currentItem?.presentationSize.height.rounded() ?? 0
    }
    var unwrappedWidth: CGFloat {
        return unwrappedAspectRatio.width
    }
    var unwrappedHeight: CGFloat {
        return unwrappedAspectRatio.height
    }
    var unwrappedVideoSize: CGSize {
        player?.currentItem?.presentationSize ?? .zero
    }
    var unwrappedImageSize: CGSize {
        if let url = file?.url, let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
            return image.size
        }
        return .zero
    }
    var unwrappedBitRate: Double {
        player?.currentItem?.preferredPeakBitRate ?? 0
    }
    @Published var unwrappedAspectRatio: CGSize = .zero
    
    init(_ file: AVFile? = nil) {
        networkMonitor = .init()
        super.init()
        self.file = file
        self.name = file?.name ?? ""
        
        if file != nil {
            generateThumbnailRepresentations()
        }
        
        $player
            .receive(on: RunLoop.main)
            .sink { player in
                self.objectWillChange.send()
                self.unwrappedVideoFrameRate = player?.currentItem?.tracks.first(where: { $0.isEnabled })?.currentVideoFrameRate ?? 0
            }
            .store(in: &cancellables)
        
        $networkMonitor
            .receive(on: RunLoop.main)
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        playbackRatePublisher
            .subscribe(on: DispatchQueue.main)
            .receive(on: RunLoop.main)
            .assign(to: \.unwrappedVideoFrameRate, on: self)
            .store(in: &cancellables)
        
    }
    
    private var playbackRatePublisher: AnyPublisher<Float, Never> {
        $player
            .receive(on: RunLoop.main)
            .map { player in
                self.unwrappedVideoFrameRate = player?.currentItem?.tracks.first(where: { $0.isEnabled })?.currentVideoFrameRate ?? 0
                return player?.currentItem?.tracks.first(where: { $0.isEnabled })?.currentVideoFrameRate ?? 0
            }
            .eraseToAnyPublisher()
    }
        
    func closeShareWindow() {
        self.sharingCode = String(Self.shareWindowCode)
    }
    
    func startSharing() {
        getAspectRatio()
        shareFile = true
        if file?.type == .video {
            if let url = file?.url {
                player = AVPlayer(url: url)
            }
        }
        analyzeSharingWindow()
        analyzeControlWindow()
    }
    
    func startSharing(_ file: AVFile) {
        shareFile = true
        self.file = file
        if file.type == .video {
            player = AVPlayer(url: file.url)
        }
        analyzeSharingWindow()
        analyzeControlWindow()
        
    }
    func analyzeSharingWindow() {
        if !sharingWindowIsOpen {
            Wnd.shareView.open()
            performSelector(onMainThread: #selector(activateShareWindow(_:)), with: nil, waitUntilDone: false)
        }
    }
    func analyzeControlWindow() {
        if !sharingControlsIsOpen, (openSharingSeparately || viewLayout == .list) {
            Wnd.controlsView.open()
            performSelector(onMainThread: #selector(activateControlWindow(_:)), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func activateShareWindow(_ sender: AnyObject) {
        Console("Attempting to activate share window")
        Console("For reference, there are\(openWindows.count) open windows ")
        openWindows.forEach({ Console("\(String(describing: $0.identifier)) is in openWindows")})
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.windows.forEach({ Console("Window: \($0.identifier?.rawValue ?? "N/A")") })
            Console("Current windows are: \(NSApp.windows)")
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue ?? "" == "ShareView" }) {
                Console("Share window frame is: \(window.frame)")
                Console("Share window aspect ratio is: \(window.contentAspectRatio)")
                window.orderFrontRegardless()
            }
        }
    }
    @objc func activateControlWindow(_ sender: AnyObject) {
        Console("Attempting to activate control window")
        Console("For reference, there are\(openWindows.count) open windows ")
        openWindows.forEach({ Console("\(String(describing: $0.identifier)) is in openWindows")})
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.windows.forEach({ Console("Window: \($0.identifier?.rawValue ?? "N/A")") })
            Console("Current windows are: \(NSApp.windows)")
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue ?? "" == "ControlsView" }) {
                Console("Control window frame is: \(window.frame)")
                Console("Control window aspect ratio is: \(window.contentAspectRatio)")
                window.orderFrontRegardless()
            }
        }
    }
    
    func stopSharing() {
        shareFile = false
        if player != nil {
            if isPlaying {
                player?.pause()
                isPlaying = false
            }
            player = nil
        }
        performSelector(onMainThread: #selector(removeShareWindow(_:)), with: nil, waitUntilDone: false)
    }
    
    @objc func removeShareWindow(_ sender: AnyObject) {
        Console("Attempting to remove share window")
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.windows.forEach({ Console("Window: \($0.identifier?.rawValue ?? "N/A")") })
            Console("Current windows are: \(NSApp.windows)")
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue ?? "" == "ShareView" }) {
                Console("Share window frame is: \(window.frame)")
                Console("Share window aspect ratio is: \(window.contentAspectRatio)")
                self.openWindows.removeAll(where: { $0.identifier == window.identifier })
                window.close()
                self.sharingWindowIsOpen = false
            }
            
        }
    }
    @objc func removeControlsWindow(_ sender: AnyObject) {
        Console("Attempting to remove control window")
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.windows.forEach({ Console("Window: \($0.identifier?.rawValue ?? "N/A")") })
            Console("Current windows are: \(NSApp.windows)")
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue ?? "" == "ControlsView" }) {
                Console("Control window frame is: \(window.frame)")
                self.openWindows.removeAll(where: { $0.identifier == window.identifier })
                window.close()
                self.sharingWindowIsOpen = false
            }
            
        }
    }
    
    func cycleTo(_ file: AVFile) {
        if self.file?.type == .video {
            player?.pause()
            player = nil
            isPlaying = false
        }
//        isPlaying = false
        self.file = file
        if file.type == .video {
            player = AVPlayer(url: file.url)
            playerItem = player?.currentItem

//            playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.tracks.currentVideoFrameRate), options: [.old, .new], context: &playerItemContext)
        }
        if viewLayout == .list {
            startSharing()
        }
        getAspectRatio()
        generateThumbnailRepresentations()
        
//        checkThumbnails()
    }
    
    func togglePlay() {
        if file?.type == .video {
            if isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
            isPlaying.toggle()
            
        }
    }
    
    func seekForward() {
        guard let player = self.player,
              let duration  = player.currentItem?.duration else {
            return
        }
        
        DispatchQueue.main.async {
            // resets the value to be tapped again.
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = playerCurrentTime + self.defaultSeek.0
            
            if newTime < (CMTimeGetSeconds(duration) - self.defaultSeek.0) {
                let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        }
    }
    
    func seekBackward() {
        guard let player = self.player else { return }
        
        DispatchQueue.main.async {
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            var newTime = playerCurrentTime - self.defaultSeek.0
            
            if newTime < 0 {
                newTime = 0
            }
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
//    func checkThumbnails() {
//        checkPreviousThumbnail()
//        checkNextThumbnail()
//    }
//
//    func checkPreviousThumbnail() {
//        guard let file = file else { return }
//        if files.first != file, files.count > 1 {
//            if let index = files.firstIndex(of: file) {
//                let previousFile = files[index - 1]
//                self.previousFile = previousFile
//                generatePreviousSplashRepresentations(for: previousFile.url)
//            }
//        }
//
//    }
//
//    func checkNextThumbnail() {
//        guard let file = file else { return }
//        if files.last != file, files.count > 1 {
//            if let index = files.firstIndex(of: file) {
//                let nextFile = files[index + 1]
//                self.nextFile = nextFile
//                generateNextSplashRepresentations(for: nextFile.url)
//            }
//        }
//    }
    
    func getAspectRatio() {
        print("Getting aspect ratio")
        if file?.type == .video {
            if let track = player?.currentItem?.asset.tracks(withMediaType: .video).first {
                print("Natural size is: \(track.naturalSize)")
                let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
                print("Size is: \(CGSize(width: abs(size.width), height: abs(size.height)))")
                unwrappedAspectRatio = CGSize(width: abs(size.width), height: abs(size.height))
                Console("unwrappedAspectRatio set to : \(unwrappedAspectRatio)")
            }
        }
        else if file?.type == .image {
            if let file = file {
                if let data = try? Data(contentsOf: file.url), let image = NSImage(data: data) {
                    unwrappedAspectRatio = image.size
                    Console("unwrappedAspectRatio set to : \(unwrappedAspectRatio)")
                }
            }
        }
        
    }
    
    func getScreenRatio(within size: CGSize) -> CGSize {
        // prep
        let maxWidth = size.width * 0.75,
            maxHeight = size.height * 0.75;
        let imgWidth = unwrappedWidth,
            imgHeight = unwrappedHeight;
        
        // calc
        let widthRatio = maxWidth / imgWidth,
            heightRatio = maxHeight / imgHeight;
        let bestRatio = min(widthRatio, heightRatio)
        
        // output
        let newWidth = imgWidth * bestRatio,
            newHeight = imgHeight * bestRatio;
        
        return .init(width: newWidth, height: newHeight)
    }
    
    @ViewBuilder
    func splashContent() -> some View {
        if file?.type == .image {
            file?.showSplashImage()
        }
        else {
            thumbnailImage
                .aspectRatio(contentMode: .fill)
                .animation(.interactiveSpring())
                .shadow(color: Color.accentGray, radius: 8)
        }
    }
    
    @ViewBuilder
    func videoContent(within size: CGSize, startVideoAtSeconds: Binding<Double>, isPlaying: Binding<Bool>, isMuted: Binding<Bool>, showControls: Bool, loop: Binding<Bool>, videoGravity: AVLayerVideoGravity, lastPlayInSeconds: Binding<Double>, backInSeconds: Binding<Double>, forwardInSeconds: Binding<Double>) -> some View {
        if file?.type == .video {
            file?.videoPlayer(within: size, startVideoAtSeconds: startVideoAtSeconds, isPlaying: isPlaying, isMuted: isMuted, showControls: showControls, loop: loop, videoGravity: videoGravity, lastPlayInSeconds: lastPlayInSeconds, backInSeconds: backInSeconds, forwardInSeconds: forwardInSeconds)
        }
    }
    
    func generateThumbnailRepresentations() {
        Console("Generating Thumbnail")
        // Set up the parameters of the request.
        guard let url = file?.url else {
            
            // Handle the error case.
            assert(false, "The URL can't be nil")
            return
        }
        
        let size: CGSize = CGSize(width: 1280, height: 700)
        //        let scale = NSScreen.main?.backingScaleFactor ?? 3840
        let scale:CGFloat = NSScreen.main?.backingScaleFactor ?? 1080
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    // Handle the error case gracefully.
                } else {
                    // Display the thumbnail that you created.
                    self.thumbnailImage = Image(nsImage: thumbnail?.nsImage)
                    Console("Thumbnail is now: \(self.thumbnailImage == nil)")
                }
            }
        }
    }
    
    func generateSplashRepresentations() {
        // Set up the parameters of the request.
        guard let url = file?.url else {
            
            // Handle the error case.
            assert(false, "The URL can't be nil")
            return
        }
        
//        let size: CGSize = CGSize(width: 500, height: 700)
//        let scale = NSScreen.main?.backingScaleFactor ?? 1080
        let size: CGSize = CGSize(width: 1280, height: 700)
        let scale:CGFloat = 2160
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)
        
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    // Handle the error case gracefully.
                } else {
                    // Display the thumbnail that you created.
                    self.splashImage = Image(nsImage: thumbnail?.nsImage)
                }
            }
        }
    }
    
    func generatePreviousSplashRepresentations(for url: URL) {
        // Set up the parameters of the request.
        
//        let size: CGSize = CGSize(width: 500, height: 700)
//        let scale = NSScreen.main?.backingScaleFactor ?? 1080
        let size: CGSize = CGSize(width: 1280, height: 700)
        let scale:CGFloat = 2160
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)
        
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    // Handle the error case gracefully.
                } else {
                    // Display the thumbnail that you created.
                    self.previousImage = Image(nsImage: thumbnail?.nsImage)
                }
            }
        }
    }
    func generateNextSplashRepresentations(for url: URL) {
        // Set up the parameters of the request.
        
//        let size: CGSize = CGSize(width: 500, height: 700)
//        let scale = NSScreen.main?.backingScaleFactor ?? 1080
        let size: CGSize = CGSize(width: 1280, height: 700)
        let scale:CGFloat = 2160
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)
        
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    // Handle the error case gracefully.
                } else {
                    // Display the thumbnail that you created.
                    self.nextImage = Image(nsImage: thumbnail?.nsImage)
                }
            }
        }
    }
        
}

extension MasterFileController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else { super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.tracks.currentVideoFrameRate) {
            if let frameRate = change?[.newKey] as? Float {
                self.frameRate = frameRate
            }
            if let tracks = change?[.newKey] as? [AVPlayerItemTrack] {
                print("Unwrapped tracks...")
                for track in tracks {
                    print("Track is \(track.currentVideoFrameRate)")
                }
            }
        }
    }
}
