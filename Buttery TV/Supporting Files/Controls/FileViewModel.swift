//
//  FileViewModel.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 7/5/21.
//

import SwiftUI
import AVFoundation
import Buttery
import Combine
import QuickLookThumbnailing

class FileViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    enum FileType { case video, image }
    
    @Published var file: AVFile
    @Published var player: AVPlayer?
    
    @Published var url = \File.url
    @Published var sharingWindowIsOpen = false
    
    @Published var thumbnailImage: Image?
    @Published var splashImage: Image?
    
    @Published var isPlaying = false
    @Published var defaultSeek: (Double, String, String) = Constants.tenSecondsSeek
    @Published var startVideoSeconds:Double = 0.0
    @Published var backInSeconds:Double = 0.0
    @Published var forwardInSeconds:Double = 0.0
    @Published var lastPlayInSeconds:Double = 0.0
    
    @Published var name: String = ""
    @Published var additionalName: String = ""
    @Published var position: Int16 = 0
    @Published var positionString = ""
    @Published var duration: Double = 0
    @Published var durationString = ""
    @Published var keyword: String = ""
    @Published var notes: String = ""
    
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
        return file.unwrappedAspectRatio.width
    }
    var unwrappedHeight: CGFloat {
        return file.unwrappedAspectRatio.height
    }
    var unwrappedVideoSize: CGSize {
        player?.currentItem?.presentationSize ?? .zero
    }
    var unwrappedBitRate: Double {
        player?.currentItem?.preferredPeakBitRate ?? 0
    }
    @Published var unwrappedAspectRatio: CGSize = .zero
    
    init(_ file: AVFile) {
        self.file = file
        self.name = file.name
        
        self.additionalName = file.additionalName ?? ""
        self.position = file.position
        self.positionString = String(file.position)
        self.duration = file.duration
        self.durationString = file.duration > 0 ? String(format: "%.2f", file.duration):""
        self.keyword = file.keyword ?? ""
        self.notes = file.notes ?? ""
        
        generateThumbnailRepresentations()
        
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
    
    func generateThumbnailRepresentations() {
        if file.type == .video {
            let size: CGSize = CGSize(width: 1280, height: 700)
            //        let scale = NSScreen.main?.backingScaleFactor ?? 3840
            let scale:CGFloat = NSScreen.main?.backingScaleFactor ?? 1080
            
            // Create the thumbnail request.
            let request = QLThumbnailGenerator.Request(fileAt: file.url,
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
                    }
                }
            }
        }
    }
    
    func togglePlay() {
        if file.type == .video {
            if isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
            isPlaying.toggle()
            
        }
    }
    
    func seekOnStartToSecondsIfNeeded(startVideoAtSeconds:Double?) {
        if let startVideoAtSeconds = startVideoAtSeconds {
            let myTime = CMTime(seconds: startVideoAtSeconds, preferredTimescale: 1000)
            DispatchQueue.main.async {
                self.player?.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
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
    
    @ViewBuilder
    func showThumbnail(with border: Color, for layout: ViewLayout) -> some View {
        if file.type == .image {
            file.showThumbnail(with: border, for: layout)
        }
        else {
            thumbnailImage?
                .resizable()
                .scaledToFill()
                //            .aspectRatio(contentMode: .fit)
                .frame(width: layout == .grid ? 150:30, height: layout == .grid ? 150:30)
                .border(border, width: 5)
                .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    func showThumbnail(with size: CGSize) -> some View {
        if file.type == .image {
            file.showThumbnail(with: size)
        }
        else {
            thumbnailImage?
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    func videoContent(within size: CGSize, startVideoAtSeconds: Binding<Double>, isPlaying: Binding<Bool>, isMuted: Binding<Bool>, showControls: Bool, loop: Binding<Bool>, videoGravity: AVLayerVideoGravity, lastPlayInSeconds: Binding<Double>, backInSeconds: Binding<Double>, forwardInSeconds: Binding<Double>) -> some View {
        if file.type == .video {
            file.videoPlayer(within: size, startVideoAtSeconds: startVideoAtSeconds, isPlaying: isPlaying, isMuted: isMuted, showControls: showControls, loop: loop, videoGravity: videoGravity, lastPlayInSeconds: lastPlayInSeconds, backInSeconds: backInSeconds, forwardInSeconds: forwardInSeconds)
        }
    }
    
}
