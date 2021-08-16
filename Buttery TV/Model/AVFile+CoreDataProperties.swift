//
//  AVFile+CoreDataProperties.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 8/3/21.
//
//

import Foundation
import CoreData
import SwiftUI
import QuickLookThumbnailing
import AVFoundation
import Buttery

extension AVFile {
    
    struct Name {
        static let imageData = "imageData"
        static let url = "url"
    }
    
    enum FileType { case video, image, audio }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AVFile> {
        return NSFetchRequest<AVFile>(entityName: "AVFile")
    }
    
    func create(from url: URL, position: Int16) {
        self.url = url
        uid = .init()
        name = url.lastPathComponent
        self.position = position
//        generateThumbnail(from: url)
    }

    @NSManaged public var additionalName: String?
    @NSManaged public var duration: Double
    @NSManaged public var keyword: String?
    @NSManaged public var name: String
    @NSManaged public var notes: String?
    @NSManaged public var position: Int16
    @NSManaged public var uid: UUID
    @NSManaged public var url: URL
    @NSManaged public var imageData: Data?
    
    var thumbnailImage: Image? {
        if let data = try? Data(contentsOf: url) {
            return Image(data: data)
        }
        return nil
    }
    
    var type: FileType {
        switch url.pathExtension {
            case "png", "pdf", "jpeg", "jpg":
                return .image
            default:
                return .video
        }
    }
    
    var unwrappedImageSize: CGSize {
        if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
            return image.size
        }
        return .zero
    }
    
    var player: AVPlayer? {
        return AVPlayer(url: url)
    }
    
    var unwrappedAspectRatio: CGSize {
        if type == .video {
            if let track = player?.currentItem?.asset.tracks(withMediaType: .video).first {
                print(track.naturalSize)
                let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
                print(CGSize(width: abs(size.width), height: abs(size.height)))
                return CGSize(width: abs(size.width), height: abs(size.height))
            }
        }
        else if type == .image {
            if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                return image.size
            }
        }
        
        return .zero
    }
    
//    @NSManaged private var primativeURL: URL?
//    @NSManaged private var primativeImageData: Data?
//
//    class func keyPathsForValuesAffectingImageData() -> Set<String> {
//        return [Name.url]
//    }
//
//    @objc public var url: URL? {
//        get {
//            willAccessValue(forKey: Name.url)
//            defer { didAccessValue(forKey: Name.url) }
//            return primativeURL
//        }
//        set {
//            willChangeValue(forKey: Name.url)
//            defer { didChangeValue(forKey: Name.url) }
//            primativeURL = newValue
//            primativeImageData = nil
//        }
//    }
//
//    @objc public var imageData: Data? {
//        willAccessValue(forKey: Name.imageData)
//        defer { didAccessValue(forKey: Name.imageData) }
//
//        guard primativeImageData == nil, let url = primativeURL else { return primativeImageData }
//
////        self.generateThumbnail(from: url)
//
//        primativeImageData = try? Data(contentsOf: url)
//
//        return primativeImageData
//
//    }
    
//    public func generateThumbnail(from url: URL) {
//        Console("Generating thumbnails...")
//        let size: CGSize = CGSize(width: 1280, height: 700)
//        let scale:CGFloat = NSScreen.main?.backingScaleFactor ?? 1080
//
//        // Create the thumbnail request.
//        let request = QLThumbnailGenerator.Request(fileAt: url,
//                                                   size: size,
//                                                   scale: scale,
//                                                   representationTypes: .thumbnail)
//
//        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
//        let generator = QLThumbnailGenerator.shared
//        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
//            DispatchQueue.main.async {
//                if thumbnail == nil || error != nil {
//                    // Handle the error case gracefully.
//                } else {
//                    // Display the thumbnail that you created.
//                    Image(nsImage: thumbnail?.nsImage)
//
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    func showThumbnail(with border: Color, for layout: ViewLayout) -> some View {
        thumbnailImage?
            .resizable()
            .scaledToFill()
//            .aspectRatio(contentMode: .fit)
            .frame(width: layout == .grid ? 150:30, height: layout == .grid ? 150:30)
            .border(border, width: 5)
            .cornerRadius(5)
    }
    
    @ViewBuilder
    func showThumbnail(with size: CGSize) -> some View {
        thumbnailImage?
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .cornerRadius(5)
    }
    
    @ViewBuilder
    func showSplashImage() -> some View {
        if type == .image, let data = try? Data(contentsOf: url), let image = Image(data: data) {
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .animation(.interactiveSpring())
                .shadow(color: Color.accentGray, radius: 8)
        }
    }
    
    @ViewBuilder
    func videoPlayer(within size: CGSize, startVideoAtSeconds: Binding<Double>, isPlaying: Binding<Bool>, isMuted: Binding<Bool>, showControls: Bool, loop: Binding<Bool>, videoGravity: AVLayerVideoGravity, lastPlayInSeconds: Binding<Double>, backInSeconds: Binding<Double>, forwardInSeconds: Binding<Double>) -> some View {
        if type == .video {
            VideoFile(url: url, startVideoAtSeconds: startVideoAtSeconds)
                .isPlaying(isPlaying)
                .isMuted(isMuted)
                .playbackControls(showControls)
                .loop(loop)
                .videoGravity(videoGravity)
                .lastPlayInSeconds(lastPlayInSeconds)
                .backInSeconds(backInSeconds)
                .forwardInSeconds(forwardInSeconds)
                .frame(width: size.width, height: size.height, alignment: .center)
        }
    }
    
}

extension AVFile : Identifiable {

}
